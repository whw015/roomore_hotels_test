import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesRepository {
  static const _languageCodeKey = 'selected_language_code';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String?> getSelectedLanguageCode() async {
    final prefs = await _prefs;
    return prefs.getString(_languageCodeKey);
  }

  Future<void> saveLanguageCode(String code) async {
    final prefs = await _prefs;
    await prefs.setString(_languageCodeKey, code);
  }

  Future<void> clearForTesting() async {
    final prefs = await _prefs;
    await prefs.remove(_languageCodeKey);
  }
}
