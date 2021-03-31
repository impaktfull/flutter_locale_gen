import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization_keys.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class Localization {
  Map<String, dynamic> _localisedValues = <String, dynamic>{};

  static Localization of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization)!;

  static Future<Localization> load(Locale locale,
      {bool showLocalizationKeys = false}) async {
    final localizations = Localization();
    if (showLocalizationKeys) {
      return localizations;
    }
    final jsonContent = await rootBundle
        .loadString('assets/locale/${locale.languageCode}.json');
    localizations._localisedValues =
        json.decode(jsonContent) as Map<String, dynamic>; // ignore: avoid_as
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = _localisedValues[key] as String?; // ignore: avoid_as
      if (value == null) return '$key';
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
  String get test => _t(LocalizationKeys.test);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$s'**
  ///
  /// nl:  **'Test argument %1$s'**
  String testArg1(String arg1) =>
      _t(LocalizationKeys.testArg1, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$d'**
  ///
  /// nl:  **'Test argument %1$d'**
  String testArg2(num arg1) =>
      _t(LocalizationKeys.testArg2, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$s %2$d'**
  ///
  /// nl:  **'Test argument %1$s %2$d'**
  String testArg3(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg3, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing argument %1$s %2$d %1$s'**
  ///
  /// nl:  **'Test argument %1$s %2$d %1$s'**
  String testArg4(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg4, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing\nargument\n\n%1$s %2$d %1$s'**
  ///
  /// nl:  **'Test\nargument\n\n%1$s %2$d %1$s'**
  String testNewLine(String arg1, num arg2) =>
      _t(LocalizationKeys.testNewLine, args: <dynamic>[arg1, arg2]);

  String getTranslation(String key, {List<dynamic>? args}) =>
      _t(key, args: args ?? <dynamic>[]);
}
