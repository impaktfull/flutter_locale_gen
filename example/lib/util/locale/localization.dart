import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:locale_gen_example/util/locale/localization_keys.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';
import 'package:sprintf/sprintf.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class Localization {
  LocaleFilter? localeFilter;

  var _localisedValues = <String, dynamic>{};
  var _localisedOverrideValues = <String, dynamic>{};

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  Locale? locale;

  static const defaultLocale = Locale.fromSubtags(
      languageCode: 'en', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    Locale.fromSubtags(languageCode: 'fi', scriptCode: null, countryCode: 'FI'),
  ];

  List<String> get supportedLanguages {
    final supportedLanguageTags =
        _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags
        .where((element) => localeFilter?.call(element) ?? true)
        .toList();
  }

  List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales
        .where((element) => localeFilter?.call(element.toLanguageTag()) ?? true)
        .toList();
  }

  Future<void> load({
    Locale? locale,
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
  }) async {
    final currentLocale = locale ?? defaultLocale;
    this.locale = currentLocale;
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
    final jsonContent = await (bundle ?? rootBundle).loadString(
        'assets/locale/${currentLocale.toLanguageTag()}.json',
        cache: useCaching);
    _localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value =
          (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String _plural(String key, {required num count, List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key])
          as Map<String, dynamic>?;
      if (value == null) return key;

      final pluralValue = Intl.plural(
        count,
        zero: value['zero'] as String?,
        one: value['one'] as String?,
        two: value['two'] as String?,
        few: value['few'] as String?,
        many: value['many'] as String?,
        other: value['other'] as String,
      );
      if (args == null || args.isEmpty) return pluralValue;
      return sprintf(pluralValue, args);
    } catch (e) {
      return '⚠$key⚠';
    }
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
  String get test => _t(LocalizationKeys.test);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string]'**
  String testArg1(String arg1) =>
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
  String testArg2(int arg1) =>
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
  String testArg3(String arg1, int arg2) =>
      _t(LocalizationKeys.testArg3, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] %2$.02f [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string] %2$f [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] %2$f [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] %2$f [arg1 string]'**
  String testArg4(String arg1, double arg2) =>
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
  String testNewLine(String arg1, int arg2) =>
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
  String get testNewLineCarriageReturn =>
      _t(LocalizationKeys.testNewLineCarriageReturn);

  /// Translations:
  ///
  /// en:  **'Testing non positional argument %s and %.02f'**
  ///
  /// nl:  **'Test niet positioneel argument %s en %f'**
  ///
  /// zh-Hans-CN: **'测试非位置参数 %s 和 %f'**
  ///
  /// fi-FI: **'Testataan ei-positiaalista argumenttia %s ja %f'**
  String testNonPositional(String arg1, double arg2) =>
      _t(LocalizationKeys.testNonPositional, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'{one: %d hour, other: %d hours}'**
  ///
  /// nl:  **'{one: %d uur, other: %d uren}'**
  ///
  /// zh-Hans-CN: **'{other: %d 小时}'**
  ///
  /// fi-FI: **'{one: %d tunti, other: %d tuntia}'**
  String testPlural(num count, int arg1) =>
      _plural(LocalizationKeys.testPlural, count: count, args: <dynamic>[arg1]);

  String getTranslation(String key, {List<dynamic>? args}) =>
      _t(key, args: args ?? <dynamic>[]);
}
