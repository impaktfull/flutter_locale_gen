import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/writer/core_writer.dart';
import 'package:path/path.dart';

class LocaleGenWriter {
  // Public API: keeps the class uninstantiable without changing its modifiers.
  const LocaleGenWriter._(); // coverage:ignore-line

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
    final writer = LocaleGenCoreWriter.fromType(params.outputType);
    writer.write(
      params,
      defaultTranslations,
      allTranslations,
    );
    print('Done!!!');
  }

  static Map<String, dynamic> getTranslations(
      LocaleGenParams params, String language) {
    // `normalize`, because `localeAssetsDir` always uses `/`: without it the
    // path in the error below mixes `\` and `/` on Windows.
    final translationFile = File(normalize(join(
        Directory.current.path, params.localeAssetsDir, '$language.json')));
    if (!translationFile.existsSync()) {
      throw Exception('${translationFile.path} does not exists');
    }

    final jsonString = translationFile.readAsStringSync();
    return jsonDecode(jsonString) as Map<String, dynamic>; // ignore: avoid_as
  }
}
