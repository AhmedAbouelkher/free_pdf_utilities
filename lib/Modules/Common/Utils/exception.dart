import 'package:process_run/shell.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

export 'package:process_run/shell.dart';

class NotSupportedPlatform implements Exception {
  final String message;
  final String? suggestion;
  NotSupportedPlatform({
    this.message = '''Sorry, $kAppName doesn't supporte the current runing platform to perform this feature. '''
        ''' Please, if have any suggestion, open an issue on Github $kAppRepo.''',
    this.suggestion,
  });
}

class UnkownPythonCompressionException implements Exception {
  final ShellException? error;
  const UnkownPythonCompressionException([this.error]);
}

class UnkownDartCompressionException implements Exception {
  final Object? error;
  const UnkownDartCompressionException([this.error]);
}

class InvalidFile implements Exception {}

class PDFRasterNotSupported implements Exception {}

class PythonNotInstalled implements Exception {}

class GhostScriptNotInstalled implements Exception {}

class UserCancelled implements Exception {}
