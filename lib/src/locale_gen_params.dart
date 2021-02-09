import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:meta/meta.dart';

final defaultOutputDir = join('lib', 'util', 'locale');
final defaultAssetsDir = join('assets', 'locale');
final defaultLocaleAssetsDir = join('assets', 'locale');

class LocaleGenParams {
  final String programName;
  String outputDir = defaultOutputDir;
  String assetsDir = defaultAssetsDir;
  String localeAssetsDir = defaultLocaleAssetsDir;
  bool nullSafe = false;

  String projectName;
  String defaultLanguage;
  List<String> languages;

  LocaleGenParams(this.programName) {
    final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
    if (!pubspecYaml.existsSync()) {
      throw Exception(
          'This program should be run from the root of a flutter/dart project');
    }

    final pubspecContent = pubspecYaml.readAsStringSync();

    final doc = loadYaml(pubspecContent);
    projectName = doc['name'];

    if (projectName == null || projectName.isEmpty) {
      throw Exception(
          'Could not parse the pubspec.yaml, project name not found');
    }

    final config = doc[programName];
    if (config == null) {
      languages = ['en'];
      defaultLanguage = 'en';
      return;
    }
    configure(config);
  }

  @mustCallSuper
  void configure(YamlMap config) {
    final YamlList yamlList = config['languages'];
    if (yamlList == null || yamlList.isEmpty) {
      throw Exception(
          "At least 1 language should be added to the 'languages' section in the pubspec.yaml\n"
          '$programName\n'
          "  languages: ['en']");
    }

    languages = yamlList.map((item) => item.toString()).toList();
    if (languages == null || languages.isEmpty) {
      throw Exception(
          "At least 1 language should be added to the 'languages' section in the pubspec.yaml\n"
          '$programName\n'
          "  languages: ['en']");
    }

    defaultLanguage = config['default_language'];
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

    outputDir ??= defaultOutputDir;

    assetsDir = config['assets_path'];
    assetsDir ??= defaultAssetsDir;
    if (!assetsDir.endsWith('/')) {
      assetsDir += '/';
    }
    localeAssetsDir = config['locale_assets_path'];
    localeAssetsDir ??= defaultLocaleAssetsDir;
    if (!localeAssetsDir.endsWith('/')) {
      localeAssetsDir += '/';
    }

    nullSafe = config['nullsafety'] == true;
  }
}
