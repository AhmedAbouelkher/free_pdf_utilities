import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

export 'package:process_run/shell.dart';

class NotSupportedPlatform implements Exception {
  final String message;
  final String? suggestion;
  NotSupportedPlatform({
    this.message = '''Sorry, $kAppName doesn't support the current running platform to perform this feature. '''
        ''' Please, if have any suggestion, open an issue on Github $kAppRepo.''',
    this.suggestion,
  });
}

class UnknownPythonCompressionException implements Exception {
  final ShellException? error;
  const UnknownPythonCompressionException([this.error]);
}

class UnknownDartCompressionException implements Exception {
  final Object? error;
  const UnknownDartCompressionException([this.error]);
}

class ErrorDownloadingFile implements Exception {
  final http.Response response;
  ErrorDownloadingFile({
    required this.response,
  });

  @override
  String toString() => 'ErrorDownloadingFile(response: ${response.body}})';
}

class ScriptNotFound implements Exception {
  final String name;
  final String path;
  ScriptNotFound({
    required this.name,
    required this.path,
  });

  @override
  String toString() => 'ScriptNotFound(name: $name, path: $path)';
}

class InvalidFile implements Exception {}

class PDFRasterNotSupported implements Exception {}

class PythonNotInstalled implements Exception {}

class GhostScriptNotInstalled implements Exception {}

class UserCancelled implements Exception {}
