import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class Localization {
  Map<dynamic, dynamic> _localisedValues;

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization);

  static Future<Localization> load(Locale locale) async {
    final localizations = Localization();
    print('Switching to ${locale.languageCode}');
    final jsonContent = await rootBundle.loadString('assets/locale/${locale.languageCode}.json');
    final Map<String, dynamic> values = json.decode(jsonContent);
    localizations._localisedValues = values;
    return localizations;
  }

  String _t(String key, {List<dynamic> args}) {
    try {
      String value = _localisedValues[key];
      if (value == null) return '⚠$key⚠';
      if (args == null || args.isEmpty) return value;
      args.asMap().forEach((index, arg) => value = _replaceWith(value, arg, index + 1));
      return value;
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

  String get appTitle => _t('app_title');

  String get test => _t('test');

  String testArg1(String arg1) => _t('test_arg1', args: [arg1]);

  String testArg2(num arg1) => _t('test_arg2', args: [arg1]);

  String testArg3(String arg1, num arg2) => _t('test_arg3', args: [arg1, arg2]);
}
