import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locale_gen_example/util/locale/localization.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static LocaleFilter? localeFilter;
  static const defaultLocale = Locale('en');
  static const _supportedLanguages = [
    'en',
    'nl',
    'zh',
    'fi',
  ];

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    Locale.fromSubtags(languageCode: 'fi', scriptCode: null, countryCode: 'FI'),
  ];

  static List<String> get supportedLanguages {
    if (localeFilter == null) return _supportedLanguages;
    return _supportedLanguages
        .where((element) => localeFilter?.call(element) ?? true)
        .toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales
        .where((element) => localeFilter?.call(element.languageCode) ?? true)
        .toList();
  }

  Locale? newLocale;
  Locale? activeLocale;
  final bool useCaching;
  bool showLocalizationKeys;

  LocalizationDelegate(
      {this.newLocale,
      this.showLocalizationKeys = false,
      this.useCaching = !kDebugMode}) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) =>
      supportedLanguages.contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(newActiveLocale,
        showLocalizationKeys: showLocalizationKeys, useCaching: useCaching);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
