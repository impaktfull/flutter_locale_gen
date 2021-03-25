import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization_keys.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class Localization {
  Map<String, dynamic> _localisedValues = Map();

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
      args.asMap().forEach(
          (index, arg) => newValue = _replaceWith(newValue, arg, index + 1));
      return newValue;
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String _replaceWith(String value, arg, argIndex) {
    if (arg == null) return value;
    if (arg is String) {
      return value.replaceAll('%$argIndex\$s', arg);
    } else if (arg is num) {
      return value.replaceAll('%$argIndex\$d', '$arg');
    }
    return value;
  }

  String get test => _t(LocalizationKeys.test);

  String testArg1(String arg1) => _t(LocalizationKeys.testArg1, args: [arg1]);

  String testArg2(num arg1) => _t(LocalizationKeys.testArg2, args: [arg1]);

  String testArg3(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg3, args: [arg1, arg2]);

  String testArg4(String arg1, num arg2) =>
      _t(LocalizationKeys.testArg4, args: [arg1, arg2]);

  String getTranslation(String key, {List<dynamic>? args}) =>
      _t(key, args: args ?? []);
}
