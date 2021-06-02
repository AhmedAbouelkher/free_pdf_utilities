import 'package:free_pdf_utilities/Modules/Common/Utils/Models/assets_controller.dart';
import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:hive/hive.dart';

class SettingService {
  SettingService._();

  static const String hiveBoxID = "SettingService";

  static Box<AppSettings>? box;

  static Future<void> init() async {
    box = await Hive.openBox<AppSettings>(SettingService.hiveBoxID);
  }

  static Future<void> save(AppSettings settings) async {
    return box?.put(SettingService.hiveBoxID, settings);
  }

  static AppSettings read() {
    final settings = box?.get(SettingService.hiveBoxID);
    return settings ?? const AppSettings();
  }

  static Future<AppSettings> reset() async {
    var appSettings = AppSettings();
    await box?.put(SettingService.hiveBoxID, appSettings);
    return appSettings;
  }

  static Future<void> clearAll() async {
    await box!.clear();
  }
}

class TempExportOptionsSerivce {
  TempExportOptionsSerivce._();

  static Box<ExportOptions>? _exportBox;
  static late String _boxName;
  static Future<void> initBox({required String withName}) async {
    if (_exportBox != null) return;
    _boxName = withName;
    _exportBox = await Hive.openBox(withName);
  }

  static Future<void> save(ExportOptions options) async {
    return _exportBox?.put(_boxName, options);
  }

  static ExportOptions? read() {
    final exportOptions = _exportBox?.get(_boxName);
    return exportOptions;
  }

  static Future<void> clear() async {
    await _exportBox?.clear();
  }

  static Future<void> deleteFromDisk() async {
    await _exportBox?.deleteFromDisk();
  }
}
