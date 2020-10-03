import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/src/case_util.dart';
import 'package:path/path.dart';

import 'locale_gen_params.dart';
import 'translation_writer.dart';

class LocaleGenWriter {
  const LocaleGenWriter._();

  static void write(LocaleGenParams params) {
    final defaultTranslationFile = File(join(Directory.current.path,
        params.assetsDir, '${params.defaultLanguage}.json'));
    if (!defaultTranslationFile.existsSync()) {
      throw Exception('${defaultTranslationFile.path} does not exists');
    }

    print('Default language: ${params.defaultLanguage}');
    print('Supported languages: ${params.languages}');

    final jsonString = defaultTranslationFile.readAsStringSync();
    final translations =
        jsonDecode(jsonString) as Map<String, dynamic>; // ignore: avoid_as
    _createLocalizationKeysFile(params, translations);
    _createLocalizationFile(params, translations);
    _createLocalizationDelegateFile(params);
    print('Done!!!');
  }

  static void _createLocalizationKeysFile(
      LocaleGenParams params, Map<String, dynamic> translations) {
    final sb = StringBuffer()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln('class LocalizationKeys {')
      ..writeln();
    translations.forEach((key, value) {
      final correctKey = CaseUtil.getCamelcase(key);
      sb..writeln('  static const $correctKey = \'$key\';')..writeln();
    });
    sb.writeln('}');

    // Write to file
    final localizationKeysFile = File(join(
        Directory.current.path, params.outputDir, 'localization_keys.dart'));
    if (!localizationKeysFile.existsSync()) {
      print('localization_keys.dart does not exists');
      print('Creating localization_keys.dart ...');
      localizationKeysFile.createSync(recursive: true);
    }
    localizationKeysFile.writeAsStringSync(sb.toString());
  }

  static void _createLocalizationFile(
      LocaleGenParams params, Map<String, dynamic> translations) {
    final sb = StringBuffer()
      ..writeln("import 'dart:convert';")
      ..writeln()
      ..writeln("import 'package:flutter/services.dart';")
      ..writeln("import 'package:flutter/widgets.dart';")
      ..writeln(
          "import 'package:${params.projectName}/util/locale/localization_keys.dart';")
      ..writeln()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln('class Localization {')
      ..writeln('  Map<String, dynamic> _localisedValues = Map();')
      ..writeln()
      ..writeln(
          '  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization);')
      ..writeln()
      ..writeln(
          '  static Future<Localization> load(Locale locale, {bool showLocalizationKeys = false}) async {')
      ..writeln('    final localizations = Localization();')
      ..writeln('    if (showLocalizationKeys) {')
      ..writeln('      return localizations;')
      ..writeln('    }')
      ..writeln(
          "    final jsonContent = await rootBundle.loadString('${params.assetsDir}\${locale.languageCode}.json');")
      ..writeln('    // ignore: avoid_as')
      ..writeln(
          '    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;')
      ..writeln('    return localizations;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  String _t(String key, {List<dynamic> args}) {')
      ..writeln('    try {')
      ..writeln('      // ignore: avoid_as')
      ..writeln('      var value = _localisedValues[key] as String;')
      ..writeln("      if (value == null) return '\$key';")
      ..writeln('      if (args == null || args.isEmpty) return value;')
      ..writeln(
          '      args.asMap().forEach((index, arg) => value = _replaceWith(value, arg, index + 1));')
      ..writeln('      return value;')
      ..writeln('    } catch (e) {')
      ..writeln("      return '⚠\$key⚠';")
      ..writeln('    }')
      ..writeln('  }')
      ..writeln()
      ..writeln('  String _replaceWith(String value, arg, argIndex) {')
      ..writeln('    if (arg == null) return value;')
      ..writeln('    if (arg is String) {')
      ..writeln("      return value.replaceAll('%\$argIndex\\\$s', arg);")
      ..writeln('    } else if (arg is num) {')
      ..writeln("      return value.replaceAll('%\$argIndex\\\$d', '\$arg');")
      ..writeln('    }')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln();
    translations.forEach((key, value) =>
        TranslationWriter.buildTranslationFunction(sb, key, value));
    sb
      ..writeln(
          '  String getTranslation(String key, {List<dynamic> args}) => _t(key, args: args ?? List());')
      ..writeln()
      ..writeln('}');

    // Write to file
    final localizationFile = File(
        join(Directory.current.path, params.outputDir, 'localization.dart'));
    if (!localizationFile.existsSync()) {
      print('localization.dart does not exists');
      print('Creating localization.dart ...');
      localizationFile.createSync(recursive: true);
    }
    localizationFile.writeAsStringSync(sb.toString());
  }

  static void _createLocalizationDelegateFile(LocaleGenParams params) {
    final sb = StringBuffer()
      ..writeln("import 'dart:async';")
      ..writeln()
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln(
          "import 'package:${params.projectName}/util/locale/localization.dart';")
      ..writeln()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln(
          'class LocalizationDelegate extends LocalizationsDelegate<Localization> {')
      ..writeln(
          "  static const defaultLocale = Locale('${params.defaultLanguage}');")
      ..writeln('  static const supportedLanguages = [');
    params.languages.forEach((language) => sb.writeln("    '$language',"));
    sb
      ..writeln('  ];')
      ..writeln()
      ..writeln('  static const supportedLocales = [');
    params.languages
        .forEach((language) => sb.writeln("    Locale('$language'),"));
    sb
      ..writeln('  ];')
      ..writeln()
      ..writeln('  Locale newLocale;')
      ..writeln('  Locale activeLocale;')
      ..writeln('  bool showLocalizationKeys;')
      ..writeln()
      ..writeln(
          '  LocalizationDelegate({this.newLocale, this.showLocalizationKeys = false}) {')
      ..writeln('    if (newLocale != null) {')
      ..writeln('      activeLocale = newLocale;')
      ..writeln('    }')
      ..writeln('    showLocalizationKeys ??= false;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
          '  bool isSupported(Locale locale) => supportedLanguages.contains(locale.languageCode);')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Future<Localization> load(Locale locale) async {')
      ..writeln('    activeLocale = newLocale ?? locale;')
      ..writeln(
          '    return Localization.load(activeLocale, showLocalizationKeys: showLocalizationKeys);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
          '  bool shouldReload(LocalizationsDelegate<Localization> old) => true;')
      ..writeln()
      ..writeln('}');

    // Write to file
    final localizationDelegateFile = File(join(Directory.current.path,
        params.outputDir, 'localization_delegate.dart'));
    if (!localizationDelegateFile.existsSync()) {
      print('localization_delegate.dart does not exists');
      print('Creating localization_delegate.dart ...');
      localizationDelegateFile.createSync(recursive: true);
    }
    localizationDelegateFile.writeAsStringSync(sb.toString());
  }
}
