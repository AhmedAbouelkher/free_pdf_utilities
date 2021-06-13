import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../command_line_tools.dart';

///An interface to use when creating new controller.
abstract class AssetsController {
  Future<String> exportDocument(XFile file) {
    throw UnimplementedError('exportDocument() is not implemented');
  }

  Future<XFile> generateDocument(ExportOptions exportOptions) {
    throw UnimplementedError('generateDocument() is not implemented');
  }

  Future<void> pickFiles() {
    throw UnimplementedError('pickFiles() is not implemented');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() is not implemented');
  }

  ///Open the current file at `filePath`.
  void showInFinder(String filePath, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text("PDF Saved", style: TextStyle(fontSize: 12)),
            SizedBox(width: 5),
            TextButton(
              onPressed: () {
                openDocument(filePath);
              },
              child: Text(
                "Open File",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.cyan,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

///ExportOptions generic class.
abstract class ExportOptions {
  const ExportOptions();
}

///Wraps `XFile` and adds new features to it.
class CxFile {
  ///The parent `XFile`.
  final XFile internal;

  ///Get File name (ex: `image_name`)
  final String? name;

  ///File basename (ex: `image_name.png`)
  final String? baseName;

  ///Get File meta data (if provided)
  final Map<String, dynamic>? metaData;

  ///Get the last-modified time for `internal` file
  ///
  ///Use `toCxFile()` on `XFile` to get the createdAt, otherwise use `await internal.lastModified()`.
  final DateTime? updatedAt;

  ///Get file size.
  ///
  ///Use `toCxFile()` on `XFile` to get the size, otherwise use `(await internal.readAsBytes()).length`.
  final int? size;

  ///Get file path on the current device.
  String get path => internal.path;

  ///Get file size as a human readable string representing the current `internal` file size.
  String? get fileSize => size != null ? filesize(size) : null;

  const CxFile({
    required this.internal,
    this.name,
    this.metaData,
    this.updatedAt,
    this.size,
    this.baseName,
  });
}

extension XfileToFile on XFile {
  ///Convert `XFile` to `io.File`
  File toFile() => File(this.path);

  ///Convert `XFile` to `CxFile`.
  ///
  ///- Only copies `name`
  ///- You can provide `metaData` to `CxFile`
  CxFile toCxFileSync([String? name, Map<String, dynamic>? metaData]) {
    String? _name = name ?? fileName(this.path);

    return CxFile(
      internal: this,
      metaData: metaData,
      name: _name,
      baseName: path.basename(this.path),
    );
  }

  ///Convert `XFile` to `CxFile`.
  ///
  ///- Copies `name`, `readAsBytes` and `lastModified`
  ///- You can provide `metaData` to `CxFile`
  Future<CxFile> toCxFile([String? name, Map<String, dynamic>? metaData]) async {
    String? _name = name ?? fileName(this.path);

    return CxFile(
      name: _name,
      internal: this,
      metaData: metaData,
      size: (await this.readAsBytes()).length,
      updatedAt: await this.lastModified(),
      baseName: path.basename(this.path),
    );
  }

  ///Get the file size in Bytes (8 bit)
  Future<int> sizeInBytes() async {
    return (await readAsBytes()).length;
  }
}

///Remove the file extension.
///
///`path/to/file.extension` to `file`.
String fileName(String filePath) {
  List<String> _splittedBaseName = path.basename(filePath).split(".");
  if (_splittedBaseName.length == 1) return filePath;
  return _splittedBaseName.getRange(0, _splittedBaseName.length - 1).join(".");
}
