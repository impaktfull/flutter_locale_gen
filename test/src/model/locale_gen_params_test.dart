import 'package:locale_gen/locale_gen.dart';
import 'package:test/test.dart';

import '../../helpers/test_project.dart';

void main() {
  group('Parse parameters', () {
    group('Test invalid spec', () {
      test('Test invalid project name', () {
        expect(() => LocaleGenParams.fromYamlString('locale_gen', 'abc: 123'),
            throwsException);
      });
      test('Test missing languages', () {
        expect(
            () => LocaleGenParams.fromYamlString(
                'locale_gen', 'name: test\n\nlocale_gen:\n  abc: 123'),
            throwsException);
      });
      test('Test empty languages', () {
        expect(
            () => LocaleGenParams.fromYamlString(
                'locale_gen', 'name: test\n\nlocale_gen:\n  languages: []'),
            throwsException);
      });
      test('Test default language not found', () {
        expect(
            () => LocaleGenParams.fromYamlString('locale_gen',
                'name: test\n\nlocale_gen:\n  languages: [\'de\']\n  default_language: \'fr\''),
            throwsException);
      });
      test('Test doc language not found', () {
        expect(
            () => LocaleGenParams.fromYamlString('locale_gen',
                'name: test\n\nlocale_gen:\n  languages: [\'de\']\n  doc_languages: [\'fr\']'),
            throwsException);
      });
    });

    group('Test valid spec', () {
      test('Test project name', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen', 'name: test')
                .projectName,
            'test');
      });
      test('Test languages', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']')
                .languages,
            ['en', 'fr']);
      });
      test('Test default language en', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']')
                .defaultLanguage,
            'en');
      });
      test('Test default language set', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  default_language: \'fr\'')
                .defaultLanguage,
            'fr');
      });
      test('Test default asset path', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  default_language: \'fr\'')
                .assetsDir,
            'assets/locale/');
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  default_language: \'fr\'')
                .localeAssetsDir,
            'assets/locale/');
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  default_language: \'fr\'')
                .outputDir,
            'lib/util/locale/');
      });
      test('Test set asset path', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  assets_path: \'assets/mylocale\'')
                .assetsDir,
            'assets/mylocale/');
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  locale_assets_path: \'assets/mylocale\'')
                .localeAssetsDir,
            'assets/mylocale/');
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  output_path: \'lib/util/mylocale\'')
                .outputDir,
            'lib/util/mylocale/');
      });
      test('Test set asset path error handling', () {
        expect(
            () => LocaleGenParams.fromYamlString('locale_gen',
                'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  output_path: \'util/mylocale\''),
            throwsArgumentError);
      });
      test('Test paths with backslashes use forward slashes', () {
        const yaml = r'''
name: test
locale_gen:
  languages: ['en']
  output_path: 'lib\util\mylocale'
  assets_path: 'assets\mylocale\'
  locale_assets_path: 'assets\mylocale'
''';
        final params = LocaleGenParams.fromYamlString('locale_gen', yaml);
        expect(params.outputDir, 'lib/util/mylocale/');
        expect(params.assetsDir, 'assets/mylocale/');
        expect(params.localeAssetsDir, 'assets/mylocale/');
      });
      test('Test default doc languages', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']')
                .docLanguages,
            ['en', 'fr']);
      });
      test('Test set doc languages', () {
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  doc_languages: [\'en\']')
                .docLanguages,
            ['en']);
        expect(
            LocaleGenParams.fromYamlString('locale_gen',
                    'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  doc_languages: []')
                .docLanguages,
            <String>[]);
      });
    });
  });

  group('LocaleGenParams messageFormatStrict', () {
    test('defaults to false when not set', () {
      const yaml = '''
name: example
locale_gen:
  languages: ['en']
''';
      final params = LocaleGenParams.fromYamlString('locale_gen', yaml);
      expect(params.messageFormatStrict, isFalse);
    });

    test('reads true when set in pubspec', () {
      const yaml = '''
name: example
locale_gen:
  languages: ['en']
  message_format_strict: true
''';
      final params = LocaleGenParams.fromYamlString('locale_gen', yaml);
      expect(params.messageFormatStrict, isTrue);
    });
  });

  group('LocaleGenParams(programName)', () {
    test('reads the pubspec.yaml in the current directory', () {
      final project = TestProject()..writeFile('pubspec.yaml', '''
name: my_app
locale_gen:
  languages: ['nl', 'fr']
''');

      late LocaleGenParams params;
      project.run(() => params = LocaleGenParams('locale_gen'));

      expect(params.projectName, 'my_app');
      expect(params.languages, ['nl', 'fr']);
      expect(params.defaultLanguage, 'nl',
          reason: 'without en, the first language is the default');
    });

    test('fails without a pubspec.yaml in the current directory', () {
      final project = TestProject();

      expect(
        () => project.run(() => LocaleGenParams('locale_gen')),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: This program should be run from the root of a flutter/dart project',
        )),
      );
    });

    test('uses English and the defaults without a locale_gen section', () {
      final params = LocaleGenParams.fromYamlString('locale_gen', 'name: app');

      expect(params.languages, ['en']);
      expect(params.defaultLanguage, 'en');
      expect(params.docLanguages, ['en']);
      expect(params.outputType.name, 'flutter');
      expect(params.outputDir, 'lib/util/locale/');
      expect(params.messageFormatStrict, isFalse);
    });
  });
}
