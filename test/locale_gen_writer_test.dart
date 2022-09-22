import 'package:locale_gen/locale_gen.dart';
import 'package:test/test.dart';

void main() {
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
      expect(
          error!.contains(
              'locale_gen/test/assets/locale-does-not-exists/en.json does not exists'),
          true);
    });
  });
}
