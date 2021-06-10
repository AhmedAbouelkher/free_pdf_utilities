import 'dart:async';
import 'dart:typed_data';

import 'package:date_time_format/date_time_format.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/exception.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';

export 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
export 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
export 'package:pdf/src/pdf/page_format.dart' show PdfPageFormat;

//TODO: [Bug] the memory usage become very high when picking files and does't decrease after releasing files.
//TODO: document

const String kImagesLabel = '@_kImagesLabel';

/// JPEG (or JPG) - Joint Photographic Experts Group.
///
/// PNG - Portable Network Graphics.
List<String> _imagesExtensions() {
  return ['jpg', 'png', 'jpeg'];
}

class _PDFAssetsControllerThreading {
  final List<CxFile> images;
  final PDFExportOptions pdfExportOptions;
  const _PDFAssetsControllerThreading({required this.images, required this.pdfExportOptions});
}

/// Use to generate new PDF file in another isolate thread.
///
///Parameters
///- `_PDFAssetsControllerThreading({required this.images, required this.pdfExportOptions})`.
///
Future<Uint8List> _generatePDFOnAnotherThread(_PDFAssetsControllerThreading dataLoader) async {
  //*Creating new document
  final _doc = pw.Document();
  for (var image in dataLoader.images) {
    //Generating memory image
    final _file = await image.internal.readAsBytes();
    final _memoryImage = pw.MemoryImage(_file);

    //Generating new page with `orientation`and `pageFormat`, then adding it to the document.
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
  //Generating the acual PDF data as `Uint8List`
  final _data = await _doc.document.save();
  return _data;
}

class PDFAssetsController extends AssetsController {
  late List<CxFile>? _docImages;
  late StreamController<List<CxFile>> _streamController;
  String? _savedDocumentName;

  String get documentName => _savedDocumentName!;
  Stream<List<CxFile>> get imageStream => _streamController.stream.asBroadcastStream();

  bool get isEmptyDocument => docImages!.isEmpty;
  bool get isNotEmptyDocument => !isEmptyDocument;

  @protected
  List<CxFile>? get docImages => _docImages;

  PDFAssetsController() {
    _streamController = StreamController.broadcast();
    _docImages = [];
    _streamController.sink.add(<CxFile>[]);
    _generateDocumentExportName();
  }

  void _generateDocumentExportName() {
    final String _time = DateTime.now().format(DateTimeFormats.europeanAbbr);
    _savedDocumentName = 'Free PDF Utilities-$_time.pdf';
  }

  @override
  Future<String> exportDocument(XFile file) async {
    String? path = await getSavePath(suggestedName: _savedDocumentName, confirmButtonText: "Save PDF");

    if (path == null) throw UserCancelled();

    await file.saveTo(path);
    return Future.value(path);
  }

  @override
  Future<XFile> generateDocument(ExportOptions exportOptions) async {
    final _options = exportOptions as PDFExportOptions;
    final _dataLoader = _PDFAssetsControllerThreading(images: _docImages!, pdfExportOptions: _options);
    //* Generating PDF file on another isolate thread
    final _generatedData =
        await compute<_PDFAssetsControllerThreading, Uint8List>(_generatePDFOnAnotherThread, _dataLoader);

    final _mimeType = "application/pdf";
    final file = XFile.fromData(_generatedData, name: _savedDocumentName, mimeType: _mimeType);
    return Future.value(file);
  }

  int totalSize = 0;

  @override
  Future<void> pickFiles() async {
    final List<XFile> _images = await _pickImagesFromSystem();
    if (_images.isEmpty) return;

    _docImages!.addAll(_images.map((e) => e.toCxFileSync()));

    _docImages!.forEach((file) async {
      totalSize += await file.internal.sizeInBytes();
    });

    _streamController.sink.add(_docImages!);
  }

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

  @override
  Future<void> dispose() async {
    _docImages?.clear();
    _docImages = null;
    _savedDocumentName = null;
    await _streamController.close();
  }
}
