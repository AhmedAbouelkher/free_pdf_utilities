import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/exception.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';

const String kPDFLabel = '@_kPDFLabel';

List<String> _pdfExtensions() {
  return ['pdf'];
}

class _PDFCompressionControllerThreading {
  final List<Uint8List> compressedImages;
  final PDFCompressionExportOptions exportOptions;
  _PDFCompressionControllerThreading({required this.compressedImages, required this.exportOptions});
}

//************************************************ */
Future<List<Uint8List>> _convertPDFToImages(CxFile file) async {
  final _fileUnit8ListData = await file.file.readAsBytes();

  List<Uint8List> _unCompressedImages = [];

  await for (var page in Printing.raster(_fileUnit8ListData, dpi: 150)) {
    final _image = await page.toPng();
    _unCompressedImages.add(_image);
  }
  return Future.value(_unCompressedImages);
}

//************************************************ */
Future<List<Uint8List>> _compressImages(List<Uint8List> images, {int? quality}) async {
  List<Uint8List> _compressedImages = [];
  for (var _image in images) {
    img.Image image = img.decodeImage(_image)!;

    // var encodeJpg = img.encodeJpg(image, quality: quality ?? 100);
    var encodeJpg = img.encodeJpg(image, quality: 100);
    // var encodeJpg = img.encodePng(image, level: 1);
    _compressedImages.add(Uint8List.fromList(encodeJpg));
  }
  return Future.value(_compressedImages);
}

//************************************************ */
/// Use to generate new PDF file in another isolate thread.
///
///Parameters
///- `_PDFCompressionControllerThreading({required this.compressedImages, required this.exportOptions})`.
///
Future<Uint8List> _generatePDFDocument(_PDFCompressionControllerThreading dataLoader) async {
  //*Creating new document
  final _doc = pw.Document();
  for (Uint8List imageAsBytes in dataLoader.compressedImages) {
    //Generating memory image
    final _memoryImage = pw.MemoryImage(imageAsBytes);

    //Generating new page with `orientation`and `pageFormat`, then adding it to the document.
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(child: pw.Image(_memoryImage));
      },
    )
      ..generate(_doc)
      ..postProcess(_doc);
  }
  //Generating the acual PDF data as `Uint8List`
  final _data = await _doc.document.save();
  return _data;
}

//************************************************ */
class PDFCompressionController extends AssetsController {
  CxFile? _pdfFile;
  late StreamController<CxFile> _streamController;

  Stream<CxFile> get pdfFile => _streamController.stream.asBroadcastStream();

  late String _savedDocumentName;

  String get documentName => _savedDocumentName;

  PDFCompressionController() {
    _streamController = StreamController.broadcast();
  }

  @override
  Future<void> pickFiles() async {
    final typeGroup = XTypeGroup(label: kImagesLabel, extensions: _pdfExtensions());
    final _file = await openFile(
      acceptedTypeGroups: [typeGroup],
      confirmButtonText: "Choose PDF",
    );
    if (_file == null) return null;
    _pdfFile = _file.toCxFile();
    _savedDocumentName = _pdfFile!.name!;
    _streamController.sink.add(_pdfFile!);
  }

  @override
  Future<XFile> generateDoument(ExportOptions exportOptions) async {
    final _options = exportOptions as PDFCompressionExportOptions;

    if (_pdfFile == null) throw InvalidFile();

    if (!(await isFeatureAvailable())) throw PDFRasterNotSupport();

    //? Convert PDF to images
    final _images = await _convertPDFToImages(_pdfFile!);

    //? Compress every image
    final _compressedImages = await _compressImages(_images, quality: _options.compression);

    //? Regenerate the new PDF document
    final _generatedData = await _generatePDFDocument(
      _PDFCompressionControllerThreading(
        compressedImages: _compressedImages,
        exportOptions: _options,
      ),
    );
    final _mimeType = "application/pdf";
    final file = XFile.fromData(_generatedData, name: _savedDocumentName, mimeType: _mimeType);
    return Future.value(file);
  }

  Future<bool> isFeatureAvailable() async {
    var printingInfo = await Printing.info();
    return printingInfo.canRaster;
  }

  @override
  Future<void> dispose() {
    return _streamController.close();
  }
}
