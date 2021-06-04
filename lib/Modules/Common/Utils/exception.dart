import 'package:process_run/shell.dart';

import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

export 'package:process_run/shell.dart';

class NotSupportedPlatform implements Exception {
  final String? message;
  final String? suggestion;
  NotSupportedPlatform({
    this.message = '''Sorry, $kAppName doesn't supporte the current runing platform to perform this feature. '''
        ''' Please, if have any suggestion, open an issue on Github $kAppRepo.''',
    this.suggestion,
  });

  @override
  String toString() => 'NotSupportedPlatform(message: $message, suggestion: $suggestion)';
}

class InvalidFile implements Exception {}

class PDFRasterNotSupport implements Exception {}

class PythonNotInstalled implements Exception {}

class UnkownPythonCompressionException implements Exception {
  final ShellException? error;
  const UnkownPythonCompressionException([this.error]);

  @override
  String toString() => 'UnkownPythonCompressionException(error: $error)';
}

class UnkownDartCompressionException implements Exception {
  final Object? error;
  const UnkownDartCompressionException([this.error]);

  @override
  String toString() => 'UnkownDartCompressionException(error: $error)';
}
