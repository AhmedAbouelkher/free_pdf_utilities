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

  Future<void> resetExportOptions() {
    final _newSettings = SettingService.read();
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

  Future<void> createTempExportOptions(String tempStorageName) async {
    await TempExportOptionsSerivce.initBox(withName: tempStorageName);
    log("New box with created with name: $tempStorageName");
    final _exportOptions = SettingService.read().exportOptions;
    if (_exportOptions != null) await TempExportOptionsSerivce.save(_exportOptions);
  }

  Future<void> updateTempExportOptions(ExportOptions options) async {
    return await TempExportOptionsSerivce.save(options);
  }

  T? readTempExportOptions<T extends ExportOptions>() {
    return TempExportOptionsSerivce.read() as T?;
  }

  Future<void> desposeTempExportOptions() async {
    await TempExportOptionsSerivce.deleteFromDisk();
    log("Box was cleared from memory");
  }
}
