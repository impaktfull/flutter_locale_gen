import 'package:locale_gen/src/case_util.dart';
import 'package:locale_gen/src/extensions/list_extensions.dart';
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
    final hasPlurals = defaultTranslations.values
        .any((element) => element is Map<String, dynamic>);
    final importPath = params.outputDir.replaceFirst('lib/', '');
    final sb = StringBuffer()
      ..writeln("import 'dart:convert';")
      ..writeln();
    [
      if (hasPlurals) ...["import 'package:intl/intl.dart';"],
      "import 'package:sprintf/sprintf.dart';",
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
      ..writeln()
      ..writeln('typedef LocaleFilter = bool Function(String languageCode);')
      ..writeln()
      ..writeln('class Localization {')
      ..writeln('  LocaleFilter? localeFilter;')
      ..writeln()
      ..writeln('  var _localisedValues = <String, dynamic>{};')
      ..writeln('  var _localisedOverrideValues = <String, dynamic>{};')
      ..writeln()
      ..writeln('  /// The locale is used to get the correct json locale.')
      ..writeln(
          '  /// It can later be used to check what the locale is that was used to load this Localization instance.')
      ..writeln('  Locale? locale;')
      ..writeln()
      ..writeln(
          LocaleGenParser.parseDefaultLanguageLocale(params.defaultLanguage))
      ..writeln()
      ..writeln('  static const _supportedLocales = [');
    params.languages.moveToFirstIndex(params.defaultLanguage).forEach(
        (language) =>
            sb.writeln(LocaleGenParser.parseSupportedLocale(language)));
    sb
      ..writeln('  ];')
      ..writeln()
      ..writeln('  List<String> get supportedLanguages {')
      ..writeln(
          '    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);')
      ..writeln('    if (localeFilter == null) return supportedLanguageTags;')
      ..writeln(
          '    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();')
      ..writeln('  }')
      ..writeln()
      ..writeln('  List<Locale> get supportedLocales {')
      ..writeln('    if (localeFilter == null) return _supportedLocales;')
      ..writeln(
          '    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<void> load({')
      ..writeln('    Locale? locale, ')
      ..writeln('    LocalizationOverrides? localizationOverrides,')
      ..writeln('    bool showLocalizationKeys = false,')
      ..writeln('    bool useCaching = true,')
      ..writeln('    AssetBundle? bundle,')
      ..writeln('    }) async {')
      ..writeln('    final currentLocale = locale ?? defaultLocale;')
      ..writeln('    this.locale = currentLocale;')
      ..writeln('    if (showLocalizationKeys) {')
      ..writeln('      _localisedValues.clear();')
      ..writeln('      _localisedOverrideValues.clear();')
      ..writeln('      return;')
      ..writeln('    }')
      ..writeln('    if (localizationOverrides != null) {')
      ..writeln(
          '      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(currentLocale);')
      ..writeln('      _localisedOverrideValues = overrideLocalizations;')
      ..writeln('    }')
      ..writeln(
          "    final jsonContent = await (bundle ?? rootBundle).loadString('${params.assetsDir}\${currentLocale.toLanguageTag()}.json', cache: useCaching);")
      ..writeln(
          '    _localisedValues = json.decode(jsonContent) as Map<String, dynamic>;')
      ..writeln('  }')
      ..writeln()
      ..writeln('  String _t(String key, {List<dynamic>? args}) {')
      ..writeln('    try {')
      ..writeln(
          '      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;')
      ..writeln('      if (value == null) return key;')
      ..writeln('      if (args == null || args.isEmpty) return value;')
      ..writeln('      return sprintf(value, args);')
      ..writeln('    } catch (e) {')
      ..writeln("      return '⚠\$key⚠';")
      ..writeln('    }')
      ..writeln('  }')
      ..writeln();
    if (hasPlurals) {
      sb
        ..writeln(
            '  String _plural(String key, {required num count, List<dynamic>? args}) {')
        ..writeln('    try {')
        ..writeln(
            '      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as Map<String, dynamic>?;')
        ..writeln('      if (value == null) return key;')
        ..writeln('      ')
        ..writeln('      final pluralValue = Intl.plural(')
        ..writeln('        count,')
        ..writeln('        zero: value[\'zero\'] as String?,')
        ..writeln('        one: value[\'one\'] as String?,')
        ..writeln('        two: value[\'two\'] as String?,')
        ..writeln('        few: value[\'few\'] as String?,')
        ..writeln('        many: value[\'many\'] as String?,')
        ..writeln('        other: value[\'other\'] as String,')
        ..writeln('      );')
        ..writeln('      if (args == null || args.isEmpty) return pluralValue;')
        ..writeln('      return sprintf(pluralValue, args);')
        ..writeln('    } catch (e) {')
        ..writeln("      return '⚠\$key⚠';")
        ..writeln('    }')
        ..writeln('  }')
        ..writeln();
    }
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
