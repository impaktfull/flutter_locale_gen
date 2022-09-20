import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization_keys.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class Localization {
  static LocaleFilter? localeFilter;

  static var _localisedValues = <String, dynamic>{};
  static var _localisedOverrideValues = <String, dynamic>{};

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  static Locale? locale;

  static const defaultLocale = Locale.fromSubtags(
      languageCode: 'en', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    Locale.fromSubtags(languageCode: 'fi', scriptCode: null, countryCode: 'FI'),
  ];

  static List<String> get supportedLanguages {
    final supportedLanguageTags =
        _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags
        .where((element) => localeFilter?.call(element) ?? true)
        .toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales
        .where((element) => localeFilter?.call(element.toLanguageTag()) ?? true)
        .toList();
  }

  static Future<void> load({
    Locale? locale,
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
  }) async {
    final currentLocale = locale ?? defaultLocale;
    Localization.locale = currentLocale;
    if (showLocalizationKeys) {
      _localisedValues.clear();
      _localisedOverrideValues.clear();
      return;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations =
          await localizationOverrides.getOverriddenLocalizations(currentLocale);
      _localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await rootBundle.loadString(
        'assets/locale/${currentLocale.toLanguageTag()}.json',
        cache: useCaching);
    _localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
  }

  static String _t(String key, {List<dynamic>? args}) {
    try {
      final value =
          (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      var newValue = value;
      // ignore: avoid_annotating_with_dynamic
      args.asMap().forEach((index, dynamic arg) =>
          newValue = _replaceWith(newValue, arg, index + 1));
      return newValue;
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  static String _replaceWith(String value, Object? arg, int argIndex) {
    if (arg == null) return value;
    if (arg is String) {
      return value.replaceAll('%$argIndex\$s', arg);
    } else if (arg is num) {
      return value.replaceAll('%$argIndex\$d', '$arg');
    }
    return value;
  }

  /// Translations:
  ///
  /// en:  **'Testing in English'**
  ///
  /// nl:  **'Test in het Nederlands'**
  ///
  /// zh-Hans-CN: **'视频的灯光脚本'**
  ///
  /// fi-FI: **'Näet lisää napauttamalla kuvakkeita'**
  static String get test => _t(LocalizationKeys.test);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string]'**
  static String testArg1(String arg1) =>
      _t(LocalizationKeys.testArg1, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 number]'**
  ///
  /// nl:  **'Test argument [arg1 number]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 number]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 number]'**
  static String testArg2(num arg1) =>
      _t(LocalizationKeys.testArg2, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] [arg2 number]'**
  ///
  /// nl:  **'Test argument [arg1 string] [arg2 number]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] [arg2 number]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] [arg2 number]'**
  static String testArg3(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg3, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] [arg2 number] [arg1 string]'**
  static String testArg4(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg4, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing\nargument\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// nl:  **'Test\nargument\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频\n的\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// fi-FI: **'Lisää\nLisää napauttamalla\n\n[arg1 string] [arg2 number] [arg1 string]'**
  static String testNewLine(String arg1, num arg2) =>
      _t(LocalizationKeys.testNewLine, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Carriage\r\nReturn'**
  ///
  /// nl:  **'Carriage\r\nReturn'**
  ///
  /// zh-Hans-CN: **'Carriage\r\nReturn'**
  ///
  /// fi-FI: **'Carriage\r\nReturn'**
  static String get testNewLineCarriageReturn =>
      _t(LocalizationKeys.testNewLineCarriageReturn);

  static String getTranslation(String key, {List<dynamic>? args}) =>
      _t(key, args: args ?? <dynamic>[]);
}
