import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFDocumentsController {
  late pw.Document _document;
  late List<pw.Page> _pages;

  PDFDocumentsController() {
    _document = pw.Document();
    _pages = [];
  }

  pw.Document get currentDocument => _document;
  List<pw.Page> get documentPages => _pages;

  void addNewPage(pw.Page newPage) {
    _pages.add(newPage);
    return _document.addPage(newPage);
  }

  void addPages(List<pw.Page> pages) {
    for (pw.Page page in pages) {
      _pages.add(page);
      _document.addPage(page);
    }
  }

  void editPageAt(int index, pw.Page oldPage) {
    return _document.editPage(index, oldPage);
  }

  pw.Page? removePageAt(int index) {
    _document.pages.removeAt(index);

    return _pages.removeAt(index);
  }

  Future<Uint8List?> generatePDFDocument() async {
    return await _document.save();
  }

  Future<XFile?> generatePDFFile([String name = ""]) async {
    final _data = await generatePDFDocument();
    if (_data == null) return null;
    final _mimeType = "application/pdf";
    final _pdfDocFile = XFile.fromData(_data, name: name, mimeType: _mimeType);
    return _pdfDocFile;
  }

  Future<pw.MemoryImage> getImageFromFile(XFile file) async {
    final _file = await file.readAsBytes();
    final image = pw.MemoryImage(_file);
    return image;
  }
}
