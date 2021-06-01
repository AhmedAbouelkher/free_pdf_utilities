import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

abstract class AssetsController {
  List<CxFile>? get docImages;
  Future<String> exportDocument(XFile file);
  Future<XFile> generateDoument(ExportOptions exportOptions);
  CxFile removeAt(int index);
  Future<void> pickFiles();
  Future<void> dispose();
  bool get isEmptyDocument => docImages!.isEmpty;
  bool get isNotEmptyDocument => !isEmptyDocument;
}

abstract class ExportOptions {
  const ExportOptions();
}

class CxFile {
  final XFile file;
  final String? name;
  final Map<String, dynamic>? metaData;
  final ExportOptions? exportOptions;

  String get path => file.path;

  const CxFile({
    required this.file,
    this.name,
    this.metaData,
    this.exportOptions,
  });
}

extension XfileToFile on XFile {
  File toFile() => File(this.path);

  CxFile toCxFile([Map<String, dynamic>? metaData, String? name]) {
    String? _name = name;
    if (_name == null) {
      //Remove the file extension
      List<String> _splittedBaseName = path.basename(this.path).split(".");
      _name = _splittedBaseName.getRange(0, _splittedBaseName.length - 1).join(".");
    }
    return CxFile(file: this, metaData: metaData, name: _name);
  }
}
