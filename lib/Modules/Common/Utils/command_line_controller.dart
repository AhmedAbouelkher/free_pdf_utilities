import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';

import 'exception.dart';

class CommandLineController {
  //TODO: Make `openDocument()` available on Linux and Windows
  static Future<void> openDocument(String path, {String? using}) async {
    if (!Platform.isMacOS) throw NotSupportedPlatform();

    final Shell _shell = Shell(workingDirectory: dirname(path));

    String _usingArg = using != null ? '-a $using' : '';

    try {
      await _shell.run('''
      open '${basename(path)}' $_usingArg
    ''');
    } catch (e) {
      print(e.toString());
    }
  }
}
