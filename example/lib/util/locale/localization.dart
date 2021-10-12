import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization_keys.dart';
import 'package:locale_gen_example/util/locale/localization_override_manager.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class Localization {
  var _localisedValues = <String, dynamic>{};
  var _localisedOverrideValues = <String, dynamic>{};

  static Localization of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale locale;

  Localization({required this.locale});

  static Future<Localization> load(
    Locale locale, {
    LocalizationOverrideManager? localizationOverrideManager,
    bool showLocalizationKeys = false,
    bool useCaching = true,
  }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrideManager != null) {
      final overrideLocalizations =
          await localizationOverrideManager.getCachedLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await rootBundle.loadString(
        'assets/locale/${locale.languageCode}.json',
        cache: useCaching);
    localizations._localisedValues =
        json.decode(jsonContent) as Map<String, dynamic>; // ignore: avoid_as
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = _localisedValues[key] as String?;
      final overrideValue = _localisedOverrideValues[key] as String?;
      if (value == null && overrideValue == null) return '$key';
      if (args == null || args.isEmpty) {
        return overrideValue ?? value!;
      }
      if (overrideValue != null) {
        return _mapArgs(overrideValue, args: args);
      }
      return _mapArgs(value!, args: args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String _mapArgs(String value, {required List<dynamic> args}) {
    var newValue = value;
    // ignore: avoid_annotating_with_dynamic
    args.asMap().forEach(
        (index, dynamic arg) => newValue = _replaceWith(value, arg, index + 1));
    return newValue;
  }

  String _replaceWith(String value, Object? arg, int argIndex) {
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
  String get test => _t(LocalizationKeys.test);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$s'**
  ///
  /// nl:  **'Test argument %1$s'**
  ///
  /// zh-Hans-CN: **'频的 %1$s'**
  ///
  /// fi-FI: **'Lisää napauttamalla %1$s'**
  String testArg1(String arg1) =>
      _t(LocalizationKeys.testArg1, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$d'**
  ///
  /// nl:  **'Test argument %1$d'**
  ///
  /// zh-Hans-CN: **'频的 %1$d'**
  ///
  /// fi-FI: **'Lisää napauttamalla %1$d'**
  String testArg2(num arg1) =>
      _t(LocalizationKeys.testArg2, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$s %2$d'**
  ///
  /// nl:  **'Test argument %1$s %2$d'**
  ///
  /// zh-Hans-CN: **'频的 %1$s %2$d'**
  ///
  /// fi-FI: **'Lisää napauttamalla %1$s %2$d'**
  String testArg3(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg3, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$s %2$d %1$s'**
  ///
  /// nl:  **'Test argument %1$s %2$d %1$s'**
  ///
  /// zh-Hans-CN: **'频的 %1$s %2$d %1$s'**
  ///
  /// fi-FI: **'Lisää napauttamalla %1$s %2$d %1$s'**
  String testArg4(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg4, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing\nargument\n\n%1$s %2$d %1$s'**
  ///
  /// nl:  **'Test\nargument\n\n%1$s %2$d %1$s'**
  ///
  /// zh-Hans-CN: **'频\n的\n\n%1$s %2$d %1$s'**
  ///
  /// fi-FI: **'Lisää\nLisää napauttamalla\n\n%1$s %2$d %1$s'**
  String testNewLine(String arg1, num arg2) =>
      _t(LocalizationKeys.testNewLine, args: <dynamic>[arg1, arg2]);

  String getTranslation(String key, {List<dynamic>? args}) =>
      _t(key, args: args ?? <dynamic>[]);
}
