import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleGen SB writer createLocalizationKeysFile', () {
    test('Test createLocalizationKeysFile', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final result = LocaleGenFlutterGenerator()
          .createLocalizationKeysFile(params, <String, dynamic>{}, {});
      expect(result,
          r'''//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class LocalizationKeys {

}
''');
    });

    test('Test createLocalizationKeysFile 1 translation', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
        },
        'nl': {
          'test_translations': 'Dit is een test vertaling',
        },
      };

      final result = LocaleGenFlutterGenerator().createLocalizationKeysFile(
          params, defaultTranslations, allTranslations);
      expect(result,
          r'''//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class LocalizationKeys {

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **'Dit is een test vertaling'**
  static const testTranslations = 'test_translations';

}
''');
    });

    test('Test createLocalizationKeysFile multiple translations', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
          'test_translations2': 'This is a test translation2',
        },
        'nl': {
          'test_translations': 'Dit is een test vertaling',
          'test_translations2': 'Dit is een test vertaling2',
        },
      };
      final result = LocaleGenFlutterGenerator().createLocalizationKeysFile(
          params, defaultTranslations, allTranslations);
      expect(result,
          r'''//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class LocalizationKeys {

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **'Dit is een test vertaling'**
  static const testTranslations = 'test_translations';

}
''');
    });

    test('Test createLocalizationKeysFile multiple translations in all ', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
        'test_translations2': 'This is a test translation2',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
          'test_translations2': 'This is a test translation2',
        },
        'nl': {
          'test_translations': 'Dit is een test vertaling',
          'test_translations2': 'Dit is een test vertaling2',
        },
      };
      final result = LocaleGenFlutterGenerator().createLocalizationKeysFile(
          params, defaultTranslations, allTranslations);
      expect(result,
          r'''//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class LocalizationKeys {

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **'Dit is een test vertaling'**
  static const testTranslations = 'test_translations';

  /// Translations:
  ///
  /// en:  **'This is a test translation2'**
  ///
  /// nl:  **'Dit is een test vertaling2'**
  static const testTranslations2 = 'test_translations2';

}
''');
    });

    test('Test createLocalizationKeysFile missing translations', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
        },
        'nl': {},
      };
      final result = LocaleGenFlutterGenerator().createLocalizationKeysFile(
          params, defaultTranslations, allTranslations);
      expect(result,
          r'''//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
class LocalizationKeys {

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **''**
  static const testTranslations = 'test_translations';

}
''');
    });
  });

  group('LocaleGen SB writer createLocalizationFile', () {
    test('Test createLocalizationFile', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, <String, dynamic>{}, {});
      expect(result, r'''import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });
    test('Test createLocalizationFile other output path', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
  output_path: lib/src/util/locale
''');
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, <String, dynamic>{}, {});
      expect(result, r'''import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/src/util/locale/localization_keys.dart';
import 'package:locale_gen_example/src/util/locale/localization_overrides.dart';
import 'package:sprintf/sprintf.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class Localization {
  LocaleFilter? localeFilter;

  var _localisedValues = <String, dynamic>{};
  var _localisedOverrideValues = <String, dynamic>{};

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });

    test('Test createLocalizationFile 1 translation', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
        },
        'nl': {
          'test_translations': 'Dit is een test vertaling',
        },
      };
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, defaultTranslations, allTranslations);
      expect(result, r'''import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **'Dit is een test vertaling'**
  String get testTranslations => _t(LocalizationKeys.testTranslations);

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });

    test('Test createLocalizationFile multiple translations', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
          'test_translations2': 'This is a test translation2',
        },
        'nl': {
          'test_translations': 'Dit is een test vertaling',
          'test_translations2': 'Dit is een test vertaling2',
        },
      };
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, defaultTranslations, allTranslations);
      expect(result, r'''import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **'Dit is een test vertaling'**
  String get testTranslations => _t(LocalizationKeys.testTranslations);

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });

    test('Test createLocalizationFile multiple translations in all ', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
        'test_translations2': 'This is a test translation2',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
          'test_translations2': 'This is a test translation2',
        },
        'nl': {
          'test_translations': 'Dit is een test vertaling',
          'test_translations2': 'Dit is een test vertaling2',
        },
      };
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, defaultTranslations, allTranslations);
      expect(result, r'''import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **'Dit is een test vertaling'**
  String get testTranslations => _t(LocalizationKeys.testTranslations);

  /// Translations:
  ///
  /// en:  **'This is a test translation2'**
  ///
  /// nl:  **'Dit is een test vertaling2'**
  String get testTranslations2 => _t(LocalizationKeys.testTranslations2);

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });

    test('Test createLocalizationFile missing translations', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, String>{
        'test_translations': 'This is a test translation',
      };
      final allTranslations = <String, Map<String, String>>{
        'en': {
          'test_translations': 'This is a test translation',
        },
        'nl': {},
      };
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, defaultTranslations, allTranslations);
      expect(result, r'''import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  /// Translations:
  ///
  /// en:  **'This is a test translation'**
  ///
  /// nl:  **''**
  String get testTranslations => _t(LocalizationKeys.testTranslations);

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });

    test('Test createLocalizationFile 1 plural', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final defaultTranslations = <String, dynamic>{
        'test_translations': {'other': 'This is a test translation'},
      };
      final allTranslations = <String, Map<String, dynamic>>{
        'en': <String, dynamic>{
          'test_translations': {'other': 'This is a test translation'},
        },
        'nl': <String, dynamic>{
          'test_translations': {'other': 'Dit is een test vertaling'},
        },
      };
      final result = LocaleGenFlutterGenerator()
          .createLocalizationFile(params, defaultTranslations, allTranslations);
      expect(result, r'''import 'dart:convert';

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

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String _plural(String key, {required num count, List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as Map<String, dynamic>?;
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
  /// en:  **'{other: This is a test translation}'**
  ///
  /// nl:  **'{other: Dit is een test vertaling}'**
  String testTranslations(num count) => _plural(LocalizationKeys.testTranslations, count: count);

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
''');
    });
  });
  group('LocaleGen SB writer createLocalizationDelegateFile', () {
    test('Test createLocalizationDelegateFile', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final result =
          LocaleGenFlutterGenerator().createLocalizationDelegateFile(params);
      expect(result, r'''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static LocaleFilter? localeFilter;
  static const defaultLocale = Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
  ];

  static List<String> get supportedLanguages {
    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();
  }

  LocalizationOverrides? localizationOverrides;
  Locale? newLocale;
  Locale? activeLocale;
  final bool useCaching;
  bool showLocalizationKeys;

  LocalizationDelegate({
    this.newLocale,
    this.localizationOverrides,
    this.showLocalizationKeys = false,
    this.useCaching = !kDebugMode,
  }) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.toLanguageTag());

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(
      locale: newActiveLocale,
      localizationOverrides: localizationOverrides,
      showLocalizationKeys: showLocalizationKeys,
      useCaching: useCaching,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
''');
    });
    test('Test createLocalizationDelegateFile with unsorted default language',
        () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['nl','en']
  locale_assets_path: test/assets/locale
''');
      final result =
          LocaleGenFlutterGenerator().createLocalizationDelegateFile(params);
      expect(result, r'''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static LocaleFilter? localeFilter;
  static const defaultLocale = Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
  ];

  static List<String> get supportedLanguages {
    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();
  }

  LocalizationOverrides? localizationOverrides;
  Locale? newLocale;
  Locale? activeLocale;
  final bool useCaching;
  bool showLocalizationKeys;

  LocalizationDelegate({
    this.newLocale,
    this.localizationOverrides,
    this.showLocalizationKeys = false,
    this.useCaching = !kDebugMode,
  }) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.toLanguageTag());

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(
      locale: newActiveLocale,
      localizationOverrides: localizationOverrides,
      showLocalizationKeys: showLocalizationKeys,
      useCaching: useCaching,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
''');
    });
    test(
        'Test createLocalizationDelegateFile with sorted default language but use nl as default',
        () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  default_language: 'nl'
  languages: ['nl','en']
  locale_assets_path: test/assets/locale
''');
      final result =
          LocaleGenFlutterGenerator().createLocalizationDelegateFile(params);
      expect(result, r'''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static LocaleFilter? localeFilter;
  static const defaultLocale = Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
  ];

  static List<String> get supportedLanguages {
    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();
  }

  LocalizationOverrides? localizationOverrides;
  Locale? newLocale;
  Locale? activeLocale;
  final bool useCaching;
  bool showLocalizationKeys;

  LocalizationDelegate({
    this.newLocale,
    this.localizationOverrides,
    this.showLocalizationKeys = false,
    this.useCaching = !kDebugMode,
  }) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.toLanguageTag());

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(
      locale: newActiveLocale,
      localizationOverrides: localizationOverrides,
      showLocalizationKeys: showLocalizationKeys,
      useCaching: useCaching,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
''');
    });
    test(
        'Test createLocalizationDelegateFile with unsorted default language but use nl as default',
        () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  default_language: 'nl'
  languages: ['en', 'nl']
  locale_assets_path: test/assets/locale
''');
      final result =
          LocaleGenFlutterGenerator().createLocalizationDelegateFile(params);
      expect(result, r'''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static LocaleFilter? localeFilter;
  static const defaultLocale = Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
  ];

  static List<String> get supportedLanguages {
    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();
  }

  LocalizationOverrides? localizationOverrides;
  Locale? newLocale;
  Locale? activeLocale;
  final bool useCaching;
  bool showLocalizationKeys;

  LocalizationDelegate({
    this.newLocale,
    this.localizationOverrides,
    this.showLocalizationKeys = false,
    this.useCaching = !kDebugMode,
  }) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.toLanguageTag());

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(
      locale: newActiveLocale,
      localizationOverrides: localizationOverrides,
      showLocalizationKeys: showLocalizationKeys,
      useCaching: useCaching,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
''');
    });
    test('Test createLocalizationDelegateFile with other output path', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
  output_path: lib/src/util/locale
''');
      final result =
          LocaleGenFlutterGenerator().createLocalizationDelegateFile(params);
      expect(result, r'''import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:locale_gen_example/src/util/locale/localization.dart';
import 'package:locale_gen_example/src/util/locale/localization_overrides.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  static LocaleFilter? localeFilter;
  static const defaultLocale = Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null);

  static const _supportedLocales = [
    Locale.fromSubtags(languageCode: 'en', scriptCode: null, countryCode: null),
    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),
  ];

  static List<String> get supportedLanguages {
    final supportedLanguageTags = _supportedLocales.map((e) => e.toLanguageTag()).toList(growable: false);
    if (localeFilter == null) return supportedLanguageTags;
    return supportedLanguageTags.where((element) => localeFilter?.call(element) ?? true).toList();
  }

  static List<Locale> get supportedLocales {
    if (localeFilter == null) return _supportedLocales;
    return _supportedLocales.where((element) => localeFilter?.call(element.toLanguageTag()) ?? true).toList();
  }

  LocalizationOverrides? localizationOverrides;
  Locale? newLocale;
  Locale? activeLocale;
  final bool useCaching;
  bool showLocalizationKeys;

  LocalizationDelegate({
    this.newLocale,
    this.localizationOverrides,
    this.showLocalizationKeys = false,
    this.useCaching = !kDebugMode,
  }) {
    if (newLocale != null) {
      activeLocale = newLocale;
    }
  }

  @override
  bool isSupported(Locale locale) => supportedLanguages.contains(locale.toLanguageTag());

  @override
  Future<Localization> load(Locale locale) async {
    final newActiveLocale = newLocale ?? locale;
    activeLocale = newActiveLocale;
    return Localization.load(
      locale: newActiveLocale,
      localizationOverrides: localizationOverrides,
      showLocalizationKeys: showLocalizationKeys,
      useCaching: useCaching,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => true;
}
''');
    });
  });
  group('LocaleGen SB writer createLocalizationOverrides', () {
    test('Test createLocalizationKeysFile', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final result =
          LocaleGenFlutterGenerator().createLocalizationOverrides(params);
      expect(result, r'''import 'package:flutter/widgets.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//
abstract class LocalizationOverrides {
  Future<void> refreshOverrideLocalizations();

  Future<Map<String, dynamic>> getOverriddenLocalizations(Locale locale);
}
''');
    });
  });
}
