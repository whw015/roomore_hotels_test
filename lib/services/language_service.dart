import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageService {
  static const _localeKey = 'app_locale'; // 'ar' أو 'en'

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  static Future<Locale?> readSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }
}
