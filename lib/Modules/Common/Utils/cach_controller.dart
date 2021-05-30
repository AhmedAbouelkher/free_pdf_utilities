import 'package:free_pdf_utilities/Modules/Common/Utils/shared_prefs_utils.dart';
import 'package:free_pdf_utilities/Modules/PDFServices/Providers/pdf_assets_controller.dart';

@deprecated
class CachController {
  CachController._();

  static CachController _instance = CachController._();

  static CachController get instance => _instance;

  String? lastPickedLocation({Object? key}) {
    final String _key = key == null ? kLastPickedLocationKey : key.toString();
    return _getLocationPath(_key);
  }

  String? lastSavedLocation({Object? key}) {
    final String _key = key == null ? kLastSavedLocationKey : key.toString();
    return _getLocationPath(_key);
  }

  void setLastSaveLocation({required String path, Object? key}) {
    final String _key = key == null ? kLastSavedLocationKey : key.toString();
    _setLoactionPath(_key, path);
  }

  void setLastPickedLocation({required String path, Object? key}) {
    final String _key = key == null ? kLastPickedLocationKey : key.toString();
    _setLoactionPath(_key, path);
  }

  String? _getLocationPath(Object? key) {
    final PreferenceUtils? _prefs = PreferenceUtils.instance;
    if (_prefs == null || key == null) return null;
    final _saveLocation = _prefs.getValueWithKey<String>(key.toString());
    return _saveLocation;
  }

  void _setLoactionPath(Object? key, String path) async {
    final PreferenceUtils? _prefs = PreferenceUtils.instance;
    if (_prefs == null || key == null) return null;
    _prefs.saveValueWithKey<String>(key.toString(), path);
  }
}
