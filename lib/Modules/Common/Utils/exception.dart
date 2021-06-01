import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

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
