import 'dart:async';
import 'dart:typed_data';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';

export 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
export 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
export 'package:pdf/src/pdf/page_format.dart' show PdfPageFormat;

const String kImagesLabel = '@_kImagesLabel';
const String kLastSavedLocationKey = '@_kLastSavedLocationKey';
const String kLastPickedLocationKey = '@_kLastPickedLocationKey';

/// JPEG (or JPG) - Joint Photographic Experts Group.
///
/// PNG - Portable Network Graphics.
List<String> _imagesExtensions() {
  return ['jpg', 'png', 'jpeg'];
}

class _PDFAssetsControllerThreading {
  final List<CxFile> images;
  final PDFExportOptions pdfExportOptions;
  const _PDFAssetsControllerThreading({
    required this.images,
    required this.pdfExportOptions,
  });
}

Future<Uint8List> _generatePDFOnAnotherThread(_PDFAssetsControllerThreading dataLoader) async {
  final _doc = pw.Document();
  for (var image in dataLoader.images) {
    final _file = await image.file.readAsBytes();
    final _memoryImage = pw.MemoryImage(_file);
    pw.Page(
      orientation: getPageOrientation(dataLoader.pdfExportOptions.pageOrientation),
      pageFormat: getPdfPageFormat(dataLoader.pdfExportOptions.pageFormat),
      build: (pw.Context context) {
        return pw.Center(child: pw.Image(_memoryImage));
      },
    )
      ..generate(_doc)
      ..postProcess(_doc);
  }
  final _data = await _doc.document.save();
  return _data;
}

class PDFAssetsController extends AssetsController {
  @protected
  @override
  List<CxFile>? get docImages => _docImages;
  late List<CxFile>? _docImages;
  late StreamController<List<CxFile>> _streamController;
  late String _savedDocumentName;
  Stream<List<CxFile>> get imageStream => _streamController.stream.asBroadcastStream();

  PDFAssetsController() {
    _streamController = StreamController.broadcast();
    _docImages = [];
    _streamController.sink.add(<CxFile>[]);
  }

  @override
  Future<String> exportDocument(XFile file) async {
    String? path = await getSavePath(suggestedName: _savedDocumentName, confirmButtonText: "Save PDF");

    if (path == null) throw Exception("User Canceled");

    await file.saveTo(path);
    return Future.value(path);
  }

  @override
  Future<XFile> generateDoument(ExportOptions exportOptions) async {
    final _options = exportOptions as PDFExportOptions;
    final _dataLoader = _PDFAssetsControllerThreading(images: _docImages!, pdfExportOptions: _options);
    final _generatedData =
        await compute<_PDFAssetsControllerThreading, Uint8List>(_generatePDFOnAnotherThread, _dataLoader);
    _generateDocumentExportName(exportOptions);
    final _mimeType = "application/pdf";
    final file = XFile.fromData(_generatedData, mimeType: _mimeType);
    return Future.value(file);
  }

  @override
  Future<void> pickFiles() async {
    final List<XFile> _images = await _pickImagesFromSystem();
    if (_images.isEmpty) return;

    _docImages!.addAll(_images.map((e) => e.toCxFile()));
    _streamController.sink.add(_docImages!);
  }

  @override
  CxFile removeAt(int index) {
    final _file = _docImages!.removeAt(index);
    _streamController.sink.add(_docImages!);
    return _file;
  }

  Future<List<XFile>> _pickImagesFromSystem() async {
    final typeGroup = XTypeGroup(label: kImagesLabel, extensions: _imagesExtensions());
    final _files = await openFiles(
      acceptedTypeGroups: [typeGroup],
      confirmButtonText: "Choose Images",
    );
    return _files;
  }

  //TODO: Make the export date is at which the initial images was added
  void _generateDocumentExportName(PDFExportOptions options) {
    final String _time = DateTime.now().format(DateTimeFormats.europeanAbbr);
    final String _pageFormat = options.pageFormat!.toString().split(".").last;
    final String _pageOrientation = options.pageOrientation.toString().split(".").last;
    _savedDocumentName = 'Free PDF Utilities-$_time-$_pageFormat-$_pageOrientation.pdf';
  }

  @override
  Future<void> dispose() {
    return _streamController.close();
  }
}
