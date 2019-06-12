import 'dart:async';

import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:flutter/material.dart';

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

  Locale newLocale;
  Locale activeLocale;

  LocalizationDelegate({this.newLocale}) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    activeLocale = newLocale ?? locale;
    return Localization.load(activeLocale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;

}
