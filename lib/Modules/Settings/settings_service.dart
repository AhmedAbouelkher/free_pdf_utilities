import 'package:free_pdf_utilities/Modules/Settings/Models/app_settings.dart';
import 'package:hive/hive.dart';

class SettingService {
  static const String _hiveBoxID = "SettingService";

  static Box<AppSettings>? box;

  static Future<void> init() async {
    box = await Hive.openBox<AppSettings>(SettingService._hiveBoxID);
  }

  static Future<void> save(AppSettings settings) async {
    return box?.put(SettingService._hiveBoxID, settings);
  }

  static AppSettings read() {
    final settings = box?.get(SettingService._hiveBoxID);
    if (settings != null) {
      return settings;
    } else {
      return AppSettings();
    }
  }

  static Future<AppSettings> reset() async {
    var appSettings = AppSettings();
    await box?.put(SettingService._hiveBoxID, appSettings);
    return appSettings;
  }
}
