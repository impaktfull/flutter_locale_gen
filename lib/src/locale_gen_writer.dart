import 'dart:convert';
import 'dart:io';

import 'package:intl/locale.dart';
import 'package:locale_gen/src/case_util.dart';
import 'package:path/path.dart';

import 'locale_gen_params.dart';
import 'translation_writer.dart';

class LocaleGenWriter {
  const LocaleGenWriter._();

  static void write(LocaleGenParams params) {
    print('Default language: ${params.defaultLanguage}');
    print('Supported languages: ${params.languages}');

    final allTranslations = <String, Map<String, dynamic>>{};
    Map<String, dynamic>? defaultTranslations;
    for (var i = 0; i < params.languages.length; ++i) {
      final language = params.languages[i];
      final translations = getTranslations(params, language);
      if (language == params.defaultLanguage) {
        defaultTranslations = translations;
      }
      allTranslations[language] = translations;
    }
    if (defaultTranslations == null) {
      throw Exception(
          '${params.defaultLanguage} could not be used because it is not configured correctly');
    }
    _createLocalizationKeysFile(params, defaultTranslations, allTranslations);
    _createLocalizationFile(params, defaultTranslations, allTranslations);
    _createLocalizationDelegateFile(params);
    print('Done!!!');
  }

  static Map<String, dynamic> getTranslations(
      LocaleGenParams params, String language) {
    final translationFile = File(
        join(Directory.current.path, params.localeAssetsDir, '$language.json'));
    if (!translationFile.existsSync()) {
      throw Exception('${translationFile.path} does not exists');
    }

    final jsonString = translationFile.readAsStringSync();
    return jsonDecode(jsonString) as Map<String, dynamic>; // ignore: avoid_as
  }

  static void _createLocalizationKeysFile(
      LocaleGenParams params,
      Map<String, dynamic> defaultTranslations,
      Map<String, Map<String, dynamic>> allTranslations) {
    final sb = StringBuffer()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln('class LocalizationKeys {')
      ..writeln();
    defaultTranslations.forEach((key, value) {
      TranslationWriter.buildDocumentation(
          sb, key, allTranslations, params.docLanguages);
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
      LocaleGenParams params,
      Map<String, dynamic> defaultTranslations,
      Map<String, Map<String, dynamic>> allTranslations) {
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
      ..writeln(
          '  Map<String, dynamic> _localisedValues = <String, dynamic>{};')
      ..writeln()
      ..writeln(
          '  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;')
      ..writeln()
      ..writeln(
          '  static Future<Localization> load(Locale locale, {bool showLocalizationKeys = false, bool useCaching = true}) async {')
      ..writeln('    final localizations = Localization();')
      ..writeln('    if (showLocalizationKeys) {')
      ..writeln('      return localizations;')
      ..writeln('    }')
      ..writeln(
          "    final jsonContent = await rootBundle.loadString('${params.assetsDir}\${locale.languageCode}.json', cache: useCaching);")
      ..writeln(
          '    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>; // ignore: avoid_as')
      ..writeln('    return localizations;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  String _t(String key, {List<dynamic>? args}) {')
      ..writeln('    try {')
      ..writeln(
          '      final value = _localisedValues[key] as String?; // ignore: avoid_as')
      ..writeln("      if (value == null) return '\$key';")
      ..writeln('      if (args == null || args.isEmpty) return value;')
      ..writeln('      var newValue = value;')
      ..writeln('      // ignore: avoid_annotating_with_dynamic')
      ..writeln(
          '      args.asMap().forEach((index, dynamic arg) => newValue = _replaceWith(newValue, arg, index + 1));')
      ..writeln('      return newValue;')
      ..writeln('    } catch (e) {')
      ..writeln("      return '⚠\$key⚠';")
      ..writeln('    }')
      ..writeln('  }')
      ..writeln()
      ..writeln(
          '  String _replaceWith(String value, Object? arg, int argIndex) {')
      ..writeln('    if (arg == null) return value;')
      ..writeln('    if (arg is String) {')
      ..writeln("      return value.replaceAll('%\$argIndex\\\$s', arg);")
      ..writeln('    } else if (arg is num) {')
      ..writeln("      return value.replaceAll('%\$argIndex\\\$d', '\$arg');")
      ..writeln('    }')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln();
    defaultTranslations.forEach((key, value) {
      TranslationWriter.buildDocumentation(
          sb, key, allTranslations, params.docLanguages);
      TranslationWriter.buildTranslationFunction(sb, key, value);
    });
    sb
      ..writeln(
          '  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);')
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
      ..writeln("import 'package:flutter/foundation.dart';")
      ..writeln("import 'package:flutter/material.dart';")
      ..writeln(
          "import 'package:${params.projectName}/util/locale/localization.dart';")
      ..writeln()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln()
      ..writeln('typedef LocaleFilter = bool Function(String languageCode);')
      ..writeln()
      ..writeln(
          'class LocalizationDelegate extends LocalizationsDelegate<Localization> {')
      ..writeln('  static LocaleFilter? localeFilter;')
      ..writeln(
          "  static const defaultLocale = Locale('${params.defaultLanguage}');")
      ..writeln('  static const _supportedLanguages = [');
    params.languages
        .forEach((language) => sb.writeln(_parseSupportedLanguage(language)));
    sb
      ..writeln('  ];')
      ..writeln()
      ..writeln('  static const _supportedLocales = [');
    params.languages
        .forEach((language) => sb.writeln(_parseSupportedLocale(language)));
    sb
      ..writeln('  ];')
      ..writeln()
      ..writeln('  static List<String> get supportedLanguages {')
      ..writeln('    if (localeFilter == null) return _supportedLanguages;')
      ..writeln(
          '    return _supportedLanguages.where((element) => localeFilter?.call(element) ?? true).toList();')
      ..writeln('  }')
      ..writeln()
      ..writeln('  static List<Locale> get supportedLocales {')
      ..writeln('    if (localeFilter == null) return _supportedLocales;')
      ..writeln(
          '    return _supportedLocales.where((element) => localeFilter?.call(element.languageCode) ?? true).toList();')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Locale? newLocale;')
      ..writeln('  Locale? activeLocale;')
      ..writeln('  final bool useCaching;')
      ..writeln('  bool showLocalizationKeys;')
      ..writeln()
      ..writeln(
          '  LocalizationDelegate({this.newLocale, this.showLocalizationKeys = false, this.useCaching = !kDebugMode}) {')
      ..writeln('    if (newLocale != null) {')
      ..writeln('      activeLocale = newLocale;')
      ..writeln('    }')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
          '  bool isSupported(Locale locale) => supportedLanguages.contains(locale.languageCode);')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Future<Localization> load(Locale locale) async {')
      ..writeln('    final newActiveLocale = newLocale ?? locale;')
      ..writeln('    activeLocale = newActiveLocale;')
      ..writeln(
          '    return Localization.load(newActiveLocale, showLocalizationKeys: showLocalizationKeys, useCaching: useCaching);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
          '  bool shouldReload(LocalizationsDelegate<Localization> old) => true;')
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

  static String _parseSupportedLanguage(String language) {
    try {
      final locale = Locale.tryParse(language);
      final languageCode = locale?.languageCode;
      return "    '$languageCode',";
    } catch (_) {
      return "    '$language',";
    }
  }

  static String _parseSupportedLocale(String language) {
    try {
      final locale = Locale.tryParse(language);
      final languageCode = locale?.languageCode;
      final scriptCode = locale?.scriptCode;
      final countryCode = locale?.countryCode;
      return "    Locale.fromSubtags(languageCode: ${languageCode != null ? "'$languageCode'" : null}, scriptCode: ${scriptCode != null ? "'$scriptCode'" : null}, countryCode: ${countryCode != null ? "'$countryCode'" : null}),";
    } catch (_) {
      return "    Locale('$language'),";
    }
  }
}
