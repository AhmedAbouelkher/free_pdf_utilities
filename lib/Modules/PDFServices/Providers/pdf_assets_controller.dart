import 'dart:async';
import 'dart:io';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/widgets.dart' as pw;

import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';

import 'pdf_controller.dart';

export 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
export 'package:pdf/src/pdf/page_format.dart' show PdfPageFormat;
export 'package:pdf/widgets.dart' show PageOrientation;

extension XfileToFile on XFile {
  File toFile() => File(this.path);

  PDFFile toPDFFile([Map<String, dynamic>? metaData, String? name]) {
    String? _name = name;
    if (_name == null) {
      //Remove the file extension
      List<String> _splittedBaseName = path.basename(this.path).split(".");
      _name = _splittedBaseName.getRange(0, _splittedBaseName.length - 1).join(".");
    }
    return PDFFile(file: this, metaData: metaData, name: _name);
  }
}

const String kImagesLabel = '@_kImagesLabel';
const String kLastSavedLocationKey = '@_kLastSavedLocationKey';
const String kLastPickedLocationKey = '@_kLastPickedLocationKey';

/// JPEG (or JPG) - Joint Photographic Experts Group.
///
/// PNG - Portable Network Graphics.
List<String> _imagesExtensions() {
  return ['jpg', 'png', 'jpeg'];
}

class PDFAssetsController {
  late List<PDFFile>? _docImages;
  late PDFDocumentsController _pdfDocumentsController;
  late StreamController<List<PDFFile>> _streamController;
  late String _savedDocumentName;
  Stream<List<PDFFile>> get imageStream => _streamController.stream.asBroadcastStream();

  bool get isEmptyDocument => _docImages!.isEmpty;
  bool get isNotEmptyDocument => !isEmptyDocument;

  void _generateDocumentExportName(PDFExportOptions options) {
    final String _time = DateTime.now().format(DateTimeFormats.europeanAbbr);
    final String _pageFormat = options.pageFormat!.toString().split(".").last;
    final String _pageOrientation = options.pageOrientation.toString().split(".").last;
    _savedDocumentName = 'Free PDF Utilities-$_time-$_pageFormat-$_pageOrientation';
  }

  PDFAssetsController() {
    _streamController = StreamController.broadcast();
    _pdfDocumentsController = PDFDocumentsController();
    _docImages = [];
    _streamController.sink.add(<PDFFile>[]);
  }

  Future<String> exportPDFDocument(XFile file) async {
    String? path = await getSavePath(suggestedName: _savedDocumentName, confirmButtonText: "Save PDF");

    if (path == null) throw "User Canceled";

    await file.saveTo(path);
    return _savedDocumentName;
  }

  Future<XFile> generatePDFDocument(PDFExportOptions options) async {
    for (PDFFile _image in _docImages!) {
      final _memoryImage = await _pdfDocumentsController.getImageFromFile(_image.file);
      final _page = pw.Page(
        orientation: getPageOrientation(options.pageOrientation!),
        pageFormat: getPdfPageFormat(options.pageFormat!),
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(_memoryImage));
        },
      );
      _pdfDocumentsController.addNewPage(_page);
    }
    _generateDocumentExportName(options);
    final file = await _pdfDocumentsController.generatePDFFile(_savedDocumentName);
    if (file == null) throw 'Invalid generated file';
    return file;
  }

  List removeAt(int index) {
    final _file = _docImages!.removeAt(index);
    _streamController.sink.add(_docImages!);
    return [_file];
  }

  Future<void> pickImages() async {
    final List<XFile> _images = await _pickImagesFromSystem();
    if (_images.isEmpty) return;

    _docImages!.addAll(_images.map((e) => e.toPDFFile()));
    _streamController.sink.add(_docImages!);
  }

  Future<List<XFile>> _pickImagesFromSystem() async {
    final typeGroup = XTypeGroup(label: kImagesLabel, extensions: _imagesExtensions());
    final _files = await openFiles(
      acceptedTypeGroups: [typeGroup],
      confirmButtonText: "Choose Images",
    );
    return _files;
  }

  void dispose() {
    _streamController.close();
  }
}

class PDFFile {
  final XFile file;
  final String? name;
  final Map<String, dynamic>? metaData;
  final PDFExportOptions? exportOptions;
  const PDFFile({
    required this.file,
    this.name,
    this.metaData,
    this.exportOptions,
  });
}
