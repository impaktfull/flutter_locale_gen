import 'dart:io';

import 'package:locale_gen/locale_gen.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'helpers/test_project.dart';

/// Shaped like the `Params` classes of impaktfull_translations and
/// icapps_translations, which extend [LocaleGenParams] with their own options
/// and hand the result to [LocaleGenWriter]. If this stops compiling or
/// working, a change broke those packages.
class _DependentParams extends LocaleGenParams {
  String? apiKey;

  factory _DependentParams(String programName) {
    final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
    return _DependentParams.fromYamlString(
        programName, pubspecYaml.readAsStringSync());
  }

  _DependentParams.fromYamlString(super.programName, super.pubspecContent)
      : super.fromYamlString();

  @override
  void configure(YamlMap config) {
    super.configure(config);
    apiKey = config['api_key'] as String?;
  }
}

void main() {
  test('only the public API files are exported', () {
    const allowedExports = [
      "export 'src/model/locale_gen_params.dart';",
      "export 'src/locale_gen_writer.dart';",
      "export 'src/util/format/locale_gen_formatter.dart';",
    ];
    final exports = File('lib/locale_gen.dart').readAsLinesSync();
    expect(exports, allowedExports);
  });

  group('public API', () {
    test('keeps its signatures', () {
      // Each typed assignment stops compiling when a signature changes.
      const LocaleGenParams Function(String) create = LocaleGenParams.new;
      const LocaleGenParams Function(String, String) fromYamlString =
          LocaleGenParams.fromYamlString;
      const void Function(LocaleGenParams) write = LocaleGenWriter.write;
      const Map<String, dynamic> Function(LocaleGenParams, String)
          getTranslations = LocaleGenWriter.getTranslations;
      const void Function(LocaleGenParams) format = LocaleGenFormatter.format;

      expect(
        [create, fromYamlString, write, getTranslations, format],
        everyElement(isA<Function>()),
      );
    });

    test('keeps its default directories', () {
      expect(defaultOutputDir, 'lib/util/locale');
      expect(defaultAssetsDir, 'assets/locale');
      expect(defaultLocaleAssetsDir, 'assets/locale');
    });

    test('exposes the configuration as mutable fields', () {
      final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en', 'nl']
  default_language: nl
  output_type: dart
  output_path: lib/l10n
  assets_path: assets/i18n
  locale_assets_path: translations
  doc_languages: ['nl']
  message_format_strict: true
''');

      expect(params.programName, 'locale_gen');
      expect(params.projectName, 'my_app');
      expect(params.languages, ['en', 'nl']);
      expect(params.defaultLanguage, 'nl');
      expect(params.outputType.name, 'dart');
      expect(params.outputDir, 'lib/l10n/');
      expect(params.assetsDir, 'assets/i18n/');
      expect(params.localeAssetsDir, 'translations/');
      expect(params.docLanguages, ['nl']);
      expect(params.messageFormatStrict, isTrue);

      params
        ..projectName = 'other_app'
        ..languages = ['en']
        ..defaultLanguage = 'en'
        ..outputType = params.outputType
        ..outputDir = 'lib/other/'
        ..assetsDir = 'assets/other/'
        ..localeAssetsDir = 'other/'
        ..docLanguages = []
        ..messageFormatStrict = false;

      expect(params.projectName, 'other_app');
      expect(params.languages, ['en']);
      expect(params.defaultLanguage, 'en');
      expect(params.outputDir, 'lib/other/');
      expect(params.assetsDir, 'assets/other/');
      expect(params.localeAssetsDir, 'other/');
      expect(params.docLanguages, isEmpty);
      expect(params.messageFormatStrict, isFalse);
    });

    test('a subclass reads its own section and generates with LocaleGenWriter',
        () {
      final project = TestProject()
        ..writeFile('pubspec.yaml', '''
name: my_app
my_translations:
  languages: ['en']
  api_key: secret
''')
        ..writeFile('assets/locale/en.json', '{"greeting": "Hi, {name}!"}');

      late _DependentParams params;
      final printed = project.run(() {
        params = _DependentParams('my_translations');
        LocaleGenWriter.write(params);
      });

      expect(params.programName, 'my_translations');
      expect(params.apiKey, 'secret');
      expect(printed.first, 'Default language: en');
      expect(printed.last, 'Done!!!');
      expect(
        project.readFile('lib/util/locale/localization.dart'),
        contains('String greeting({required String name})'),
      );
    });
  });
}
