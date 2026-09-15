import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleRepository {
  static const storeLocale = 'locale';
  static LocaleRepository? _instance;

  LocaleRepository._();

  factory LocaleRepository() => _instance ??= LocaleRepository._();

  Future<void> setCustomLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      LocaleGenLogger.log('Reset custom locale. Use system language');
      await prefs.remove(storeLocale);
      return;
    }
    await prefs.setString(storeLocale, locale.languageCode);
  }

  //can be null
  Future<Locale?> getCustomLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(storeLocale);
    if (localeCode == null || localeCode.isEmpty) return null;
    return Locale(localeCode);
  }
}
