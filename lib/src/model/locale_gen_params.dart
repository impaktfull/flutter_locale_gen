import 'dart:io';

import 'package:locale_gen/src/model/locale_gen_type.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

final defaultOutputDir = join('lib', 'util', 'locale');
final defaultAssetsDir = join('assets', 'locale');
final defaultLocaleAssetsDir = join('assets', 'locale');

class LocaleGenParams {
  final String programName;
  String outputDir = '$defaultOutputDir/';
  String assetsDir = '$defaultAssetsDir/';
  String localeAssetsDir = '$defaultLocaleAssetsDir/';

  late String projectName;
  late String defaultLanguage;
  late List<String> languages;
  late List<String> docLanguages;
  late LocaleGenType type;

  factory LocaleGenParams(String programName) {
    final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
    if (!pubspecYaml.existsSync()) {
      throw Exception(
          'This program should be run from the root of a flutter/dart project');
    }

    final pubspecContent = pubspecYaml.readAsStringSync();
    return LocaleGenParams.fromYamlString(programName, pubspecContent);
  }

  LocaleGenParams.fromYamlString(this.programName, String pubspecContent) {
    final doc = loadYaml(pubspecContent) as YamlMap;
    final projectName = doc['name'] as String?;

    if (projectName == null || projectName.isEmpty) {
      throw Exception(
          'Could not parse the pubspec.yaml, project name not found');
    }

    this.projectName = projectName;
    final config = doc[programName] as YamlMap?;
    if (config == null) {
      languages = ['en'];
      defaultLanguage = 'en';
      docLanguages = languages;
      type = LocaleGenType.defaultValue;
      return;
    }
    configure(config);
  }

  @mustCallSuper
  void configure(YamlMap config) {
    final YamlList? yamlList = config['languages'] as YamlList?;
    if (yamlList == null || yamlList.isEmpty) {
      throw Exception(
          "At least 1 language should be added to the 'languages' section in the pubspec.yaml\n"
          '$programName\n'
          "  languages: ['en']");
    }

    final languages =
        yamlList.map((dynamic item) => item.toString()).toList(growable: false);

    final YamlList? docLanguageList = config['doc_languages'] as YamlList?;
    List<String>? docLanguages;
    if (docLanguageList != null) {
      docLanguages =
          docLanguageList.map((dynamic item) => item.toString()).toList();
    }

    var defaultLanguage = config['default_language'] as String?;
    if (defaultLanguage == null) {
      if (languages.contains('en')) {
        defaultLanguage = 'en';
      } else {
        defaultLanguage = languages[0];
      }
    }

    if (!languages.contains(defaultLanguage)) {
      throw Exception('default language is not included in the languages list');
    }

    var outputDir = config['output_path'] as String?;
    outputDir ??= defaultOutputDir;
    if (!outputDir.endsWith('/')) {
      outputDir += '/';
    }
    if (!outputDir.startsWith('lib/')) {
      throw ArgumentError('output_path should always start with lib');
    }

    var assetsDir = config['assets_path'] as String?;
    assetsDir ??= defaultAssetsDir;
    if (!assetsDir.endsWith('/')) {
      assetsDir += '/';
    }

    var localeAssetsDir = config['locale_assets_path'] as String?;
    localeAssetsDir ??= defaultLocaleAssetsDir;
    if (!localeAssetsDir.endsWith('/')) {
      localeAssetsDir += '/';
    }

    final type = config['type'] as String?;

    this.localeAssetsDir = localeAssetsDir;
    this.outputDir = outputDir;
    this.assetsDir = assetsDir;
    this.languages = languages;
    this.defaultLanguage = defaultLanguage;
    this.docLanguages = docLanguages ?? languages;
    this.type = LocaleGenType.fromString(type);

    final different =
        this.docLanguages.where((language) => !languages.contains(language));
    if (different.isNotEmpty) {
      throw Exception(
          '$different is defined in doc_languages but they are not found in the supported languages');
    }
  }
}
