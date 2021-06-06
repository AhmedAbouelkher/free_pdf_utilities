import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';

import 'exception.dart';

Directory kWorkingDirectory = Directory.current;
Directory _kPythonCompressionScriptDirectory = Directory(join(
  kWorkingDirectory.path,
  'lib/Modules/Common/Utils',
  "Scripts/pdf_compressor.py",
));

//TODO: [Platform Fix] Make available on Linux and Windows
class CommandLineController {
  ///Open document in its default program.
  static Future<void> openDocument(String path, {String? using}) async {
    if (!Platform.isMacOS) throw NotSupportedPlatform();

    final Shell _shell = Shell(workingDirectory: dirname(path));

    String _usingArg = using != null ? '-a $using' : '';

    try {
      await _shell.run("open '${basename(path)}' $_usingArg");
    } catch (e) {
      print(e.toString());
    }
  }
}

class PythonCompressionCLController {
  ///Checks if Python SDK is installed on the current system
  static Future<bool> isPythonAvailable() async {
    final Shell _shell = Shell(workingDirectory: kWorkingDirectory.path);
    try {
      await _shell.runExecutableArguments('python', ['--version']);
      return true;
    } catch (e) {
      print('isPythonAvailable() error $e');
      return false;
    }
  }

  static Future<bool> isGhostScriptAvailable() async {
    final Shell _shell = Shell(workingDirectory: kWorkingDirectory.path);
    try {
      await _shell.runExecutableArguments('gs', ['--version']);
      return true;
    } catch (e) {
      print('isGhostScriptAvailable() error $e');
      return false;
    }
  }

  ///Searches the documents folder associated with the current app for `.generated` folder to save temp files data in it.
  static Future<Directory> tempPDFGeneratingDirectory() async {
    final _tempDocument = await getApplicationDocumentsDirectory();
    final _dir = Directory(join(_tempDocument.path, kAppName, '.generated/pdf'));
    if (await _dir.exists()) return _dir;
    return await _dir.create(recursive: true);
  }

  ///Compress PDF files using python script.
  ///params:
  ///- `file` is a `CxFile`.
  ///- `level`:
  ///   * 0: default
  ///   * 1: prepress
  ///   * 2: printer
  ///   * 3: ebook
  ///   * 4: screen
  static Future<CxFile> compress(CxFile file, {int level = 2, String? generatedName}) async {
    if (!Platform.isMacOS) throw NotSupportedPlatform();
    if (!(await isGhostScriptAvailable())) throw GhostScriptNotInstalled();
    if (!(await isPythonAvailable())) throw PythonNotInstalled();

    final Shell _shell = Shell(workingDirectory: dirname(file.path));

    final _tempStorage = await tempPDFGeneratingDirectory();
    final _fileName = fileName(file.path);
    final _generatedName = join(_tempStorage.path, '.gen_trash_$_fileName');
    try {
      await _shell
          .run("python ${_kPythonCompressionScriptDirectory.path} -c $level -o '$_generatedName.pdf' $_fileName.pdf");
      final XFile _generatedCompressedFile = XFile(
        join(dirname(file.path), '$_generatedName.pdf'),
        name: generatedName,
      );
      return _generatedCompressedFile.toCxFileSync();
    } catch (e) {
      rethrow;
    }
  }

  ///Clears (deletes) all generated cashed PDF files.
  static Future<void> clearTempCashe() async {
    final _tempStorage = await tempPDFGeneratingDirectory();
    await _tempStorage.delete(recursive: true);
  }
}
