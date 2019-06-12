import 'package:yaml/yaml.dart';

class Params {
  static const localeGenYaml = 'locale_gen';

  String projectName;
  String defaultLanguage;
  List<String> languages;

  Params(pubspecContent) {
    final doc = loadYaml(pubspecContent);
    projectName = doc['name'];

    if (projectName == null || projectName.isEmpty) {
      throw Exception('Could not parse the pubspec.yaml, project name not found');
    }

    final config = doc[localeGenYaml];
    if (config == null) {
      languages = ['en'];
      defaultLanguage = 'en';
      return;
    }

    final YamlList yamlList = config['languages'];
    if (yamlList == null || yamlList.isEmpty) {
      throw Exception("At least 1 language should be added to the 'languages' section in the pubspec.yaml\n"
          '$localeGenYaml\n'
          "  languages: ['en']");
    }

    languages = yamlList.map((item) => item.toString()).toList();
    if (languages == null || languages.isEmpty) {
      throw Exception("At least 1 language should be added to the 'languages' section in the pubspec.yaml\n"
          '$localeGenYaml\n'
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
  }
}
