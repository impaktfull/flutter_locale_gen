import 'package:locale_gen/locale_gen.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../helpers/test_project.dart';

void main() {
  group('LocaleGenWriter.write', () {
    LocaleGenParams params(String config) =>
        LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
$config''');

    TestProject projectWithTranslations() => TestProject()
      ..writeFile('assets/locale/en.json', '{"title": "Title"}')
      ..writeFile('assets/locale/nl.json', '{"title": "Titel"}');

    test('generates the Flutter files', () {
      final project = projectWithTranslations();

      final printed = project.run(
          () => LocaleGenWriter.write(params("  languages: ['en', 'nl']\n")));

      expect(printed.take(2),
          ['Default language: en', 'Supported languages: [en, nl]']);
      expect(printed.last, 'Done!!!');
      for (final file in [
        'localization.dart',
        'localization_keys.dart',
        'localization_delegate.dart',
        'localization_overrides.dart',
      ]) {
        expect(project.fileExists('lib/util/locale/$file'), isTrue,
            reason: file);
      }
    });

    test('generates one Dart file with output_type dart', () {
      final project = projectWithTranslations();

      project.run(() => LocaleGenWriter.write(
          params("  languages: ['en', 'nl']\n  output_type: dart\n")));

      expect(
        project.readFile('lib/util/locale/localization.dart'),
        contains('LocalizedValue get title => LocalizedValue('),
      );
      expect(project.fileExists('lib/util/locale/localization_keys.dart'),
          isFalse);
    });

    test('fails when the default language is not one of the languages', () {
      final project = projectWithTranslations();
      final configured = params("  languages: ['en', 'nl']\n")
        ..defaultLanguage = 'fr';

      expect(
        () => project.run(() => LocaleGenWriter.write(configured)),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            'Exception: fr could not be used because it is not configured correctly')),
      );
    });
  });

  group('LocaleGen writer', () {
    test('Test nl translations', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final translations = LocaleGenWriter.getTranslations(params, 'nl');
      expect(translations.length, 9);
      expect(translations.keys.length, 9);
      expect(translations.values.length, 9);
    });
    test('Test en translations', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale
''');
      final translations = LocaleGenWriter.getTranslations(params, 'en');
      expect(translations.length, 8);
      expect(translations.keys.length, 8);
      expect(translations.values.length, 8);
    });
    test('Test en translations with incorrect path', () {
      final params = LocaleGenParams.fromYamlString(
          'locale_gen', '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
  locale_assets_path: test/assets/locale-does-not-exists
''');
      String? error;
      try {
        LocaleGenWriter.getTranslations(params, 'en');
      } catch (e) {
        error = e.toString();
      }
      expect(error, isNotNull);
      // `normalize`, because the path uses the platform separator: `\` on
      // Windows.
      expect(
          error!.contains(
              '${normalize('test/assets/locale-does-not-exists/en.json')} does not exists'),
          true);
    });
  });
}
