import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_service.dart';

export 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';

export 'package:provider/provider.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettings? _appSettings;

  Future<void> saveSettings(AppSettings settings) {
    final _newSettings = SettingService.read().merge(settings);
    _appSettings = _newSettings;
    notifyListeners();
    return SettingService.save(_newSettings);
  }

  Future<void> resetExportOptions() {
    final _newSettings = SettingService.read().copyWith(exportOptions: const PDFExportOptions());
    _appSettings = _newSettings;
    notifyListeners();
    return SettingService.save(_newSettings);
  }

  AppSettings appSettings() {
    return _appSettings ?? SettingService.read();
  }
}
