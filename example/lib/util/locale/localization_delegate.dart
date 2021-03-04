import 'dart:async';

import 'package:flutter/material.dart';
import 'package:locale_gen_example/util/locale/localization.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static const defaultLocale = Locale('en');
  static const supportedLanguages = [
    'en',
    'nl',
  ];

  static const supportedLocales = [
    Locale('en'),
    Locale('nl'),
  ];

  Locale? newLocale;
  Locale? activeLocale;
  bool showLocalizationKeys;

  LocalizationDelegate({this.newLocale, this.showLocalizationKeys = false}) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(newActiveLocale, showLocalizationKeys: showLocalizationKeys);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;

}
