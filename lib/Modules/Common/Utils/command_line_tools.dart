import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/PNG_TO_PDF/pdf_assets_controller.dart';

import 'package:http/http.dart' as http;
import 'exception.dart';

Directory kWorkingDirectory = Directory.current;

const String kCompressionPythoneScriptName = "pdf_compressor.py";

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
  ///Checks if `Python` SDK is installed on the current system
  static Future<bool> isPythonAvailable() async {
    try {
      await Process.run('python', ['--version'], workingDirectory: kWorkingDirectory.path);
      return true;
    } catch (e) {
      print('isPythonAvailable() error $e');
      return false;
    }
  }

  //TODO: [Crash!] when calling `isGhostScriptAvailable` from DMG release crashes.

  ///Checks if `GhostScript` is installed on the current system.
  static Future<bool> isGhostScriptAvailable() async {
    try {
      final _r = await Process.start('gs', ['--version'], workingDirectory: kWorkingDirectory.path);
      print(await _r.exitCode);
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

  ///Get the current path of the `Python` compression script from local device.
  ///
  ///if not found the app attempts to download it from the internet.
  ///
  ///See also:
  /// - `isPythonAvailable()`
  /// - `isGhostScriptAvailable()`
  static Future<String> getPythonScriptPath() async {
    bool _doExist = await ScriptsController.isScriptExist(kCompressionPythoneScriptName);
    if (_doExist) return (await ScriptsController.getScriptDirectory(kCompressionPythoneScriptName)).path;
    final _downloadedScriptFile = await ScriptsController.downloadFile(Scripts.pythonCompression);
    return _downloadedScriptFile.path;
  }

  ///Compress PDF files using python script.
  ///params:
  ///- `file` is a `CxFile`.
  ///- `level`:
  ///   - 0: default
  ///   - 1: prepress
  ///   - 2: printer
  ///   - 3: ebook
  ///   - 4: screen
  static Future<CxFile> compress(CxFile file, {int level = 2, String? generatedName}) async {
    if (!Platform.isMacOS) throw NotSupportedPlatform();
    if (!(await isGhostScriptAvailable())) throw GhostScriptNotInstalled();
    if (!(await isPythonAvailable())) throw PythonNotInstalled();

    final Shell _shell = Shell(workingDirectory: dirname(file.path));

    final _tempStorage = await tempPDFGeneratingDirectory();
    final _fileName = fileName(file.path);
    final _generatedName = join(_tempStorage.path, '.gen_trash_$_fileName');

    //? Check for the Python script
    final _scriptPath = await getPythonScriptPath();
    try {
      await _shell.run('''python "$_scriptPath" -c $level -o "$_generatedName.pdf" "$_fileName.pdf"''');
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
  static Future<void> clearTempCache() async {
    final _tempStorage = await tempPDFGeneratingDirectory();
    await _tempStorage.delete(recursive: true);
  }
}

///Helps with dealing with downloading an location `Python` and other scripts.
class ScriptsController {
  ///Get the app scripts directory.
  static Future<Directory> scriptsDirectory() async {
    final _appDirectory = await appDocumentsDirectory();
    final _scriptsDir = Directory(join(_appDirectory.path, ".scripts/"));
    return _scriptsDir.create(recursive: true);
  }

  ///Download the file from the given `uri` and saves it to the given path.
  ///
  ///Params:
  /// - `path`: File path at which the downloaded file will be saved to.
  /// -  `filename` saved file name.
  ///
  /// Exceptions:
  /// - `FileSystemException` due to invalid `path`.
  /// - `ErrorDownloadingFile` due to `uri` or network error.
  static Future<File> downloadFile(
    Uri uri, {
    String? filename,
    String? path,
  }) async {
    ///Get file name from uri
    String _fileName(Uri uri) {
      return uri.pathSegments.last;
    }

    ///Save the `bytes` to the `path`.
    Future<File> _saveTo(String path, List<int> bytes) async {
      final File fileToSave = File(path);
      await fileToSave.writeAsBytes(bytes);
      await fileToSave.create();
      return fileToSave;
    }

    final _response = await http.get(uri);
    if (_response.statusCode != 200) throw ErrorDownloadingFile(response: _response);

    final _scriptsDir = await scriptsDirectory();

    final _pathToSaveTo = path ?? _scriptsDir.path;

    return _saveTo(join(_pathToSaveTo, filename ?? _fileName(uri)), _response.bodyBytes);
  }

  ///Checks of the script file with `name` has been downloaded or not.
  ///
  ///See also:
  ///- `downloadFile()`
  ///- `scriptsDirectory()`
  ///- `getScriptDirectory()`
  static Future<bool> isScriptExist(String name) async {
    final _scriptsDir = await scriptsDirectory();
    var _path = join(_scriptsDir.path, name);
    return File(_path).exists();
  }

  ///Retuns the script directory with `name`.
  ///
  ///if not found throw `ScriptNotFound` exception.
  ///
  ///see also:
  ///- `isScriptExist()`
  static Future<Directory> getScriptDirectory(String name) async {
    final _scriptsDir = await scriptsDirectory();
    var _path = join(_scriptsDir.path, name);

    if (!(await File(_path).exists())) throw ScriptNotFound(name: name, path: _path);
    return Directory(_path);
  }
}
