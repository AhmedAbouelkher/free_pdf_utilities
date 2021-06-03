import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:filesize/filesize.dart';
import 'package:path/path.dart' as path;

abstract class AssetsController {
  List<CxFile>? get docImages {
    throw UnimplementedError();
  }

  Future<String> exportDocument(XFile file) {
    throw UnimplementedError();
  }

  Future<XFile> generateDoument(ExportOptions exportOptions) {
    throw UnimplementedError();
  }

  CxFile removeAt(int index) {
    throw UnimplementedError();
  }

  Future<void> pickFiles() {
    throw UnimplementedError();
  }

  Future<void> dispose() {
    throw UnimplementedError();
  }
}

abstract class ExportOptions {
  const ExportOptions();
}

class CxFile {
  final XFile internal;
  final String? name;
  final Map<String, dynamic>? metaData;
  final ExportOptions? exportOptions;

  final DateTime? updatedAt;
  final int? size;
  String get path => internal.path;

  String? get fileSize => size != null ? filesize(size) : null;

  const CxFile({
    required this.internal,
    this.name,
    this.metaData,
    this.exportOptions,
    this.updatedAt,
    this.size,
  });
}

extension XfileToFile on XFile {
  File toFile() => File(this.path);

  CxFile toCxFileSync([String? name, Map<String, dynamic>? metaData]) {
    String? _name = name ?? fileName(this.path);

    return CxFile(
      internal: this,
      metaData: metaData,
      name: _name,
    );
  }

  Future<CxFile> toCxFile([String? name, Map<String, dynamic>? metaData]) async {
    String? _name = name ?? fileName(this.path);

    return CxFile(
      name: _name,
      internal: this,
      metaData: metaData,
      size: (await this.readAsBytes()).length,
      updatedAt: await this.lastModified(),
    );
  }
}

///Remove the file extension.
///
///`path/to/file.extension` to `file`.
String fileName(String filePath) {
  List<String> _splittedBaseName = path.basename(filePath).split(".");
  return _splittedBaseName.getRange(0, _splittedBaseName.length - 1).join(".");
}
