import 'package:locale_gen/src/case_util.dart';
import 'package:locale_gen/src/locale_gen_parser.dart';

import 'locale_gen_params.dart';
import 'translation_writer.dart';

class LocaleGenSbWriter {
  const LocaleGenSbWriter._();

  static String createLocalizationKeysFile(
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
      sb
        ..writeln('  static const $correctKey = \'$key\';')
        ..writeln();
    });
    sb.writeln('}');
    return sb.toString();
  }

  static String createLocalizationFile(
      LocaleGenParams params,
      Map<String, dynamic> defaultTranslations,
      Map<String, Map<String, dynamic>> allTranslations) {
    final importPath = params.outputDir.replaceFirst('lib/', '');
    final sb = StringBuffer()
      ..writeln("import 'dart:convert';")
      ..writeln();
    [
      "import 'package:flutter/services.dart';",
      "import 'package:flutter/widgets.dart';",
      "import 'package:${params.projectName}/${importPath}localization_keys.dart';",
      "import 'package:${params.projectName}/${importPath}localization_overrides.dart';",
    ]
      ..sort((i1, i2) => i1.compareTo(i2))
      ..forEach(sb.writeln);
    sb
      ..writeln()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln('class Localization {')
      ..writeln('  var _localisedValues = <String, dynamic>{};')
      ..writeln('  var _localisedOverrideValues = <String, dynamic>{};')
      ..writeln()
      ..writeln(
          '  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;')
      ..writeln()
      ..writeln('  /// The locale is used to get the correct json locale.')
      ..writeln(
          '  /// It can later be used to check what the locale is that was used to load this Localization instance.')
      ..writeln('  final Locale locale;')
      ..writeln()
      ..writeln('  Localization({required this.locale});')
      ..writeln()
      ..writeln('  static Future<Localization> load(Locale locale, {')
      ..writeln('    LocalizationOverrides? localizationOverrides,')
      ..writeln('    bool showLocalizationKeys = false,')
      ..writeln('    bool useCaching = true,')
      ..writeln('    }) async {')
      ..writeln('    final localizations = Localization(locale: locale);')
      ..writeln('    if (showLocalizationKeys) {')
      ..writeln('      return localizations;')
      ..writeln('    }')
      ..writeln('    if (localizationOverrides != null) {')
      ..writeln(
          '      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);')
      ..writeln(
          '      localizations._localisedOverrideValues = overrideLocalizations;')
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
          '      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;')
      ..writeln('      if (value == null) return key;')
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
    return sb.toString();
  }

  static String createLocalizationDelegateFile(LocaleGenParams params) {
    final importPath = params.outputDir.replaceFirst('lib/', '');
    final sb = StringBuffer()
      ..writeln("import 'dart:async';")
      ..writeln();
    [
      "import 'package:flutter/foundation.dart';",
      "import 'package:flutter/widgets.dart';",
      "import 'package:${params.projectName}/${importPath}localization.dart';",
      "import 'package:${params.projectName}/${importPath}localization_overrides.dart';",
    ]
      ..sort((i1, i2) => i1.compareTo(i2))
      ..forEach(sb.writeln);
    sb
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
          LocaleGenParser.parseDefaultLanguageLocale(params.defaultLanguage))
      ..writeln()
      ..writeln('  static const _supportedLocales = [');
    params.languages.forEach((language) =>
        sb.writeln(LocaleGenParser.parseSupportedLocale(language)));
    sb
      ..writeln('  ];')
      ..writeln()
      ..writeln('  static List<String> get supportedLanguages {')
      ..writeln(
          '    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);')
      ..writeln('    if (localeFilter == null) return supportedLanguageTags;')
      ..writeln(
          '    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();')
      ..writeln('  }')
      ..writeln()
      ..writeln('  static List<Locale> get supportedLocales {')
      ..writeln('    if (localeFilter == null) return _supportedLocales;')
      ..writeln(
          '    return _supportedLocales.where((element) => localeFilter?.call(element.languageCode) ?? true).toList();')
      ..writeln('  }')
      ..writeln()
      ..writeln('  LocalizationOverrides? localizationOverrides;')
      ..writeln('  Locale? newLocale;')
      ..writeln('  Locale? activeLocale;')
      ..writeln('  final bool useCaching;')
      ..writeln('  bool showLocalizationKeys;')
      ..writeln()
      ..writeln('  LocalizationDelegate({')
      ..writeln('    this.newLocale,')
      ..writeln('    this.localizationOverrides,')
      ..writeln('    this.showLocalizationKeys = false,')
      ..writeln('    this.useCaching = !kDebugMode,')
      ..writeln('  }) {')
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
      ..writeln('    return Localization.load(')
      ..writeln('      newActiveLocale,')
      ..writeln('      localizationOverrides: localizationOverrides,')
      ..writeln('      showLocalizationKeys: showLocalizationKeys,')
      ..writeln('      useCaching: useCaching,')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln(
          '  bool shouldReload(LocalizationsDelegate<Localization> old) => true;')
      ..writeln('}');
    return sb.toString();
  }

  static String createLocalizationOverrides(LocaleGenParams params) {
    final sb = StringBuffer()
      ..writeln("import 'package:flutter/widgets.dart';")
      ..writeln()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln('abstract class LocalizationOverrides {')
      ..writeln('  Future<void> refreshOverrideLocalizations();')
      ..writeln()
      ..writeln(
          '  Future<Map<String, dynamic>> getOverriddenLocalizations(Locale locale);')
      ..writeln('}');
    return sb.toString();
  }
}
