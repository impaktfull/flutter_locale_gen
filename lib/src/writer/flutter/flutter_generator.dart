import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/model/plural.dart';
import 'package:locale_gen/src/util/case/case_util.dart';
import 'package:locale_gen/src/extensions/list_extensions.dart';
import 'package:locale_gen/src/util/documentation/documentation_util.dart';
import 'package:locale_gen/src/util/parser/locale_gen_parser.dart';
import 'package:locale_gen/src/writer/core_generator.dart';

class LocaleGenFlutterGenerator extends LocaleGenCoreGenerator {
  String createLocalizationKeysFile(
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
    for (final key in defaultTranslations.keys) {
      DocumentationUtil.buildDocumentation(
          sb, key, allTranslations, params.docLanguages);
      final correctKey = CaseUtil.getCamelcase(key);
      sb
        ..writeln('  static const $correctKey = \'$key\';')
        ..writeln();
    }
    sb.writeln('}');
    return sb.toString();
  }

  String createLocalizationFile(
      LocaleGenParams params,
      Map<String, dynamic> defaultTranslations,
      Map<String, Map<String, dynamic>> allTranslations) {
    final hasPlurals = defaultTranslations.values
        .any((dynamic element) => element is Map<String, dynamic>);
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
      ..writeln(
          '  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;')
      ..writeln()
      ..writeln('  /// The locale is used to get the correct json locale.')
      ..writeln(
          '  /// It can later be used to check what the locale is that was used to load this Localization instance.')
      ..writeln('  final Locale? locale;')
      ..writeln()
      ..writeln('  Localization({required this.locale});')
      ..writeln()
      ..writeln('  static Future<Localization> load({')
      ..writeln('    required Locale locale, ')
      ..writeln('    LocalizationOverrides? localizationOverrides,')
      ..writeln('    bool showLocalizationKeys = false,')
      ..writeln('    bool useCaching = true,')
      ..writeln('    AssetBundle? bundle,')
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
          "    final jsonContent = await (bundle ?? rootBundle).loadString('${params.assetsDir}\${locale.toLanguageTag()}.json', cache: useCaching);")
      ..writeln(
          '    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;')
      ..writeln('    return localizations;')
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
    defaultTranslations.forEach((key, dynamic value) {
      DocumentationUtil.buildDocumentation(
          sb, key, allTranslations, params.docLanguages);
      buildTranslationFunction(sb, params, key, value, allTranslations);
    });
    sb
      ..writeln(
          '  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);')
      ..writeln()
      ..writeln('}');
    return sb.toString();
  }

  String createLocalizationDelegateFile(LocaleGenParams params) {
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
    params.languages.moveToFirstIndex(params.defaultLanguage).forEach(
        (language) =>
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
          '    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();')
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
          '  bool isSupported(Locale locale) => supportedLanguages.contains(locale.toLanguageTag());')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Future<Localization> load(Locale locale) async {')
      ..writeln('    final newActiveLocale = newLocale ?? locale;')
      ..writeln('    activeLocale = newActiveLocale;')
      ..writeln('    return Localization.load(')
      ..writeln('      locale: newActiveLocale,')
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

  String createLocalizationOverrides(LocaleGenParams params) {
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

  @override
  void buildDefaultPluralFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Plural plural,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final camelKey = CaseUtil.getCamelcase(key);
    sb
      ..writeln(
          '  String $camelKey(num count) => _plural(LocalizationKeys.$camelKey, count: count);')
      ..writeln();
  }

  @override
  void buildParameterizedPluralFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Plural plural,
    Map<int, String> indexToReplacement,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    try {
      final camelKey = CaseUtil.getCamelcase(key);
      final tmpSb = StringBuffer('  String $camelKey(num count, ');

      var iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        final argument = getArgument(key, match, index);
        tmpSb.write(argument);
        if (iterationIndex++ != indexToReplacement.length - 1) {
          tmpSb.write(', ');
        }
      });
      tmpSb.write(
          ') => _plural(LocalizationKeys.$camelKey, count: count, args: <dynamic>[');
      iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        if (iterationIndex++ != 0) {
          tmpSb.write(', ');
        }
        tmpSb.write('arg$index');
      });
      tmpSb
        ..writeln(']);')
        ..writeln();
      sb.write(tmpSb.toString());
    } on Exception catch (e) {
      print(e);
      buildDefaultFunction(sb, params, key, allTranslations);
    }
  }

  @override
  void buildParameterizedFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Map<int, String> indexToReplacement,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    try {
      final camelKey = CaseUtil.getCamelcase(key);
      final tmpSb = StringBuffer('  String $camelKey(');

      var iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        final argument = getArgument(key, match, index);
        tmpSb.write(argument);
        if (iterationIndex++ != indexToReplacement.length - 1) {
          tmpSb.write(', ');
        }
      });
      tmpSb.write(') => _t(LocalizationKeys.$camelKey, args: <dynamic>[');
      iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        if (iterationIndex++ != 0) {
          tmpSb.write(', ');
        }
        tmpSb.write('arg$index');
      });
      tmpSb
        ..writeln(']);')
        ..writeln();
      sb.write(tmpSb.toString());
    } on Exception catch (e) {
      print(e);
      buildDefaultFunction(sb, params, key, allTranslations);
    }
  }

  @override
  void buildDefaultFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final camelCaseKey = CaseUtil.getCamelcase(key);
    sb
      ..writeln(
          '  String get $camelCaseKey => _t(LocalizationKeys.$camelCaseKey);')
      ..writeln();
  }
}
