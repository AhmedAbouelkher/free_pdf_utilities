import 'dart:async';
import 'dart:io';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_selector/file_selector.dart';
// ignore: implementation_imports
import 'package:pdf/src/pdf/page_format.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:free_pdf_utilities/Modules/Common/Utils/cach_controller.dart';

import 'pdf_controller.dart';

export 'package:pdf/src/pdf/page_format.dart' show PdfPageFormat;
export 'package:pdf/widgets.dart' show PageOrientation;

extension XfileToFile on XFile {
  File toFile() {
    return File(this.path);
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
  late List<XFile>? _docImages;
  late PDFDocumentsController _pdfDocumentsController;
  late StreamController<List<XFile>> _streamController;
  late String _savedDocumentName;
  Stream<List<XFile>> get imageStream => _streamController.stream.asBroadcastStream();

  bool get isEmptyDocument => _docImages!.isEmpty;
  bool get isNotEmptyDocument => !isEmptyDocument;

  void _generateDocumentExportName(PDFExportOptions options) {
    final String _time = DateTime.now().format(DateTimeFormats.europeanAbbr);
    final String _pageFormat = options.pageFormat!.toEnum().toString().split(".").last;
    final String _pageOrientation = options.pageOrientation.toString().split(".").last;
    _savedDocumentName = 'Free PDF Utilities-$_time-$_pageFormat-$_pageOrientation';
  }

  PDFAssetsController() {
    _streamController = StreamController.broadcast();
    _pdfDocumentsController = PDFDocumentsController();
    _docImages = [];
    _streamController.sink.add([XFile("path")]);
  }

  Future<String> exportPDFDocument(XFile file) async {
    var lastSavedLocation = CachController.instance.lastSavedLocation();
    String? path = await getSavePath(
      suggestedName: _savedDocumentName,
      confirmButtonText: "Save PDF",
      initialDirectory: lastSavedLocation,
    );
    if (path == null) throw "User Canceled";
    CachController.instance.setLastSaveLocation(path: FileSystemEntity.parentOf(path));

    await file.saveTo(path);
    return _savedDocumentName;
  }

  Future<XFile> generatePDFDocument(PDFExportOptions options) async {
    for (XFile _image in _docImages!) {
      final _memoryImage = await _pdfDocumentsController.getImageFromFile(_image);
      final _page = pw.Page(
        orientation: options.pageOrientation,
        pageFormat: options.pageFormat,
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

    _docImages!.addAll(_images);
    _streamController.sink.add(_docImages!);
    CachController.instance.setLastPickedLocation(
      path: _images.first.toFile().parent.path,
    );
  }

  Future<List<XFile>> _pickImagesFromSystem() async {
    final typeGroup = XTypeGroup(label: kImagesLabel, extensions: _imagesExtensions());
    final _location = CachController.instance.lastPickedLocation();
    final _files = await openFiles(
      acceptedTypeGroups: [typeGroup],
      initialDirectory: _location,
      confirmButtonText: "Choose Images",
    );
    return _files;
  }

  void dispose() {
    _streamController.close();
  }
}

enum PdfPageFormatEnum { A3, A4, A5, Letter }

extension pageFormat on PdfPageFormat {
  PdfPageFormatEnum toEnum() {
    if (this.height == PdfPageFormat.a3.height) {
      return PdfPageFormatEnum.A3;
    } else if (this.height == PdfPageFormat.a4.height) {
      return PdfPageFormatEnum.A3;
    } else if (this.height == PdfPageFormat.a5.height) {
      return PdfPageFormatEnum.A5;
    } else {
      return PdfPageFormatEnum.Letter;
    }
  }
}

class PDFExportOptions {
  final PdfPageFormat? pageFormat;
  final pw.PageOrientation? pageOrientation;

  const PDFExportOptions({
    this.pageFormat = PdfPageFormat.a4,
    this.pageOrientation = pw.PageOrientation.portrait,
  });

  PDFExportOptions copyWith({
    PdfPageFormat? pageFormat,
    pw.PageOrientation? pageOrientation,
  }) {
    return PDFExportOptions(
      pageFormat: pageFormat ?? this.pageFormat,
      pageOrientation: pageOrientation ?? this.pageOrientation,
    );
  }

  PDFExportOptions merge({
    PDFExportOptions? other,
  }) {
    if (other == null) return this;
    return copyWith(
      pageFormat: other.pageFormat,
      pageOrientation: other.pageOrientation,
    );
  }

  @override
  String toString() => 'PDFExportOptions(pageFormat: $pageFormat, pageOrientation: $pageOrientation)';
}
