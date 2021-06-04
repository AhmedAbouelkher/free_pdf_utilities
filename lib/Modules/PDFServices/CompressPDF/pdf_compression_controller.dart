import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/command_line_tools.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/exception.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';

//TODO: Create more effient image compression alogrithm (Dart)

const String kPDFLabel = '@_kPDFLabel';

List<String> _pdfExtensions() {
  return ['pdf'];
}

class _PDFCompressionControllerThreading {
  final List<Uint8List> images;
  final PDFCompressionExportOptions exportOptions;
  final CxFile? file;
  final Map<String, dynamic?>? metaData;
  const _PDFCompressionControllerThreading({
    required this.images,
    required this.exportOptions,
    this.file,
    this.metaData,
  });
}

Future<List<Uint8List>> _compressImages(List<Uint8List> images, PDFCompressionExportOptions exportOptions) async {
  List<Uint8List> _compressedImages = [];
  final _imageType = exportOptions.imageType ?? ImageType.PNG;
  final _level = exportOptions.level ?? CompressionLevel.level2;
  for (var _image in images) {
    img.Image image = img.decodeImage(_image)!;

    List<int> _generatedImage;

    if (_imageType == ImageType.PNG) {
      _generatedImage = img.encodePng(image, level: (6 - _level.clamp(1, 6)));
    } else {
      _generatedImage = img.encodeJpg(image, quality: 100 - (_level * 15));
    }

    _compressedImages.add(Uint8List.fromList(_generatedImage));
  }
  return Future.value(_compressedImages);
}

/// Use to generate new PDF file in another isolate thread.
///
///Parameters
///- `_PDFCompressionControllerThreading({required this.compressedImages, required this.exportOptions})`.
///
Future<Uint8List> _generatePDFDocument(_PDFCompressionControllerThreading dataLoader) async {
  //? Compress every image
  final _compressedImages = await _compressImages(dataLoader.images, dataLoader.exportOptions);

  //? Regenerate the new PDF document

  //*Creating new document
  final _doc = pw.Document();
  for (Uint8List imageAsBytes in _compressedImages) {
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

class PDFCompressionController extends AssetsController {
  CxFile? _pdfFile;
  late StreamController<CxFile> _streamController;

  Stream<CxFile> get pdfFileStream => _streamController.stream.asBroadcastStream();

  String? _documentName;

  String? get documentName => _documentName;

  PDFCompressionController() {
    _streamController = StreamController.broadcast();
  }

  @override
  Future<String> exportDocument(XFile file) async {
    print(_documentName);
    var _generatedFileName = "${fileName(_documentName!)}-compressed.pdf";
    String? path = await getSavePath(suggestedName: _generatedFileName, confirmButtonText: "Save PDF");

    if (path == null) throw Exception("User Canceled");

    await file.saveTo(path);
    return Future.value(path);
  }

  @override
  Future<void> pickFiles() async {
    final typeGroup = XTypeGroup(label: kImagesLabel, extensions: _pdfExtensions());
    final _file = await openFile(
      acceptedTypeGroups: [typeGroup],
      confirmButtonText: "Choose PDF",
    );
    if (_file == null) return null;
    _pdfFile = await _file.toCxFile();

    _documentName = _pdfFile!.name!;
    _streamController.sink.add(_pdfFile!);
  }

  @override
  Future<XFile> generateDoument(ExportOptions exportOptions, {CxFile? origin}) async {
    final _options = exportOptions as PDFCompressionExportOptions;

    //* Checks whether the compression feature can be available or not.
    bool _isExportMethodPython = (_options.exportMethod ?? ExportMethod.Python) == ExportMethod.Python;
    if (!_isExportMethodPython && !(await isFeatureAvailable())) throw PDFRasterNotSupport();

    if (_pdfFile == null && origin == null) throw InvalidFile();

    final _tempPDFFile = _pdfFile ?? origin;
    _documentName = fileName(_tempPDFFile!.path);

    //? Python Compression
    if (_isExportMethodPython) {
      try {
        final _level = _options.level ?? CompressionLevel.level2;
        final file = await CompressionCLController.compress(_tempPDFFile, level: _level);
        return Future.value(file.internal);
      } catch (e) {
        rethrow;
      }
    }
    //? Dart Compression
    try {
      //? Convert PDF to images
      final _images = await _convertPDFToImages(_tempPDFFile);
      final _dataLoader = _PDFCompressionControllerThreading(exportOptions: _options, images: _images);
      final _generatedData =
          await compute<_PDFCompressionControllerThreading, Uint8List>(_generatePDFDocument, _dataLoader);

      final _mimeType = "application/pdf";

      final file = XFile.fromData(_generatedData, mimeType: _mimeType);

      return Future.value(file);
    } catch (e) {
      throw UnkownDartCompressionException(e);
    }
  }

  Future<bool> isFeatureAvailable() async {
    var printingInfo = await Printing.info();
    return printingInfo.canRaster;
  }

  @override
  Future<void> dispose() {
    return _streamController.close();
  }

  Future<List<Uint8List>> _convertPDFToImages(CxFile file) async {
    final _fileUnit8ListData = await file.internal.readAsBytes();

    List<Uint8List> _unCompressedImages = [];

    await for (var page in Printing.raster(_fileUnit8ListData)) {
      final _image = await page.toPng();
      _unCompressedImages.add(_image);
    }
    return Future.value(_unCompressedImages);
  }
}
