import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/locale_gen_sb_writer.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

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
    _createLocalizationOverrides(params);
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
    final content = LocaleGenSbWriter.createLocalizationKeysFile(
        params, defaultTranslations, allTranslations);
    writeFile(params.outputDir, 'localization_keys.dart', content);
  }

  static void _createLocalizationFile(
      LocaleGenParams params,
      Map<String, dynamic> defaultTranslations,
      Map<String, Map<String, dynamic>> allTranslations) {
    final content = LocaleGenSbWriter.createLocalizationFile(
        params, defaultTranslations, allTranslations);
    writeFile(params.outputDir, 'localization.dart', content);
  }

  static void _createLocalizationOverrides(LocaleGenParams params) {
    final content = LocaleGenSbWriter.createLocalizationOverrides(params);
    writeFile(params.outputDir, 'localization_overrides.dart', content);
  }

  @visibleForTesting
  static void writeFile(String outputDir, String fileName, String content) {
    final file = File(join(Directory.current.path, outputDir, fileName));
    if (!file.existsSync()) {
      print('$fileName does not exists');
      print('Creating $fileName ...');
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(content);
  }
}
