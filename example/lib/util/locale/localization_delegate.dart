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
  bool isInTest;

  LocalizationDelegate({this.newLocale, this.isInTest = false}) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
    isInTest ??= false;
  }

  @override
  bool isSupported(Locale locale) =>
      supportedLanguages.contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    activeLocale = newLocale ?? locale;
    return Localization.load(activeLocale, isInTest: isInTest);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
