import 'package:locale_gen/locale_gen.dart';
import 'package:test/test.dart';

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
        try {
          final result = LocaleGenParams.fromYamlString('locale_gen',
                  'name: test\n\nlocale_gen:\n  languages: [\'en\',\'fr\']\n  output_path: \'util/mylocale\'')
              .outputDir;
          expect('This should not succeed', result);
        } catch (e) {
          print(e);
        }
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
            []);
      });
    });
  });
}
