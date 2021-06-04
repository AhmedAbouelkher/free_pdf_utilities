import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:free_pdf_utilities/Modules/Settings/settings_service.dart';

export 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';

export 'package:provider/provider.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettings? _appSettings;

  Future<void> saveSettings(AppSettings settings) {
    var _oldAppSettings = SettingService.read();
    final _newSettings = _oldAppSettings.merge(settings);
    _appSettings = _newSettings;
    notifyListeners();
    return SettingService.save(_newSettings);
  }

  AppSettings appSettings() {
    return _appSettings ?? SettingService.read();
  }

  Future<void> clearAllSettings() async {
    await SettingService.clearAll();
    _appSettings = const AppSettings();
    notifyListeners();
  }

  void updateSettings(AppSettings settings) {
    var _oldAppSettings = SettingService.read();
    final _newSettings = _oldAppSettings.merge(settings);
    _appSettings = _newSettings;
    notifyListeners();
  }

  Future<void> resetExportOptions() {
    final _newSettings = SettingService.read();
    _appSettings = _newSettings;
    notifyListeners();
    return SettingService.save(_newSettings);
  }

  //* Temp Export options

  Future<void> generateTempExportOptions() async {
    if (TempExportOptionsSerivce.isOpen()) {
      await TempExportOptionsSerivce.clear();
    } else {
      await TempExportOptionsSerivce.initBox();
      log("Temp file export opetions box was created");
    }
    print("object");
  }

  Future<void> updateTempExportOptions<T extends ExportOptions>(T options) async {
    return await TempExportOptionsSerivce.save(options);
  }

  T? readTempExportOptions<T extends ExportOptions>() {
    return TempExportOptionsSerivce.read() as T?;
  }

  Future<void> desposeTempExportOptions() async {
    await TempExportOptionsSerivce.deleteFromDisk();
    log("Temp file export opetions box was desposed");
  }
}
