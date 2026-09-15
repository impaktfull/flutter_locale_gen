import 'package:locale_gen/locale_gen.dart';
import 'package:test/test.dart';

import '../../../helpers/test_project.dart';

void main() {
  group('LocaleGenFormatter.format', () {
    test('sorts the keys, rewrites them to snake_case and keeps the values',
        () {
      final project = TestProject()
        ..writeFile('assets/locale/en.json',
            '{"welcomeBack": "Welcome back", "app title": "App", "a_key": "A"}')
        ..writeFile('assets/locale/nl.json',
            '{"b": "B", "a": {"one": "1 item", "other": "%d items"}}');
      final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en', 'nl']
''');

      final printed = project.run(() => LocaleGenFormatter.format(params));

      expect(
        project.readFile('assets/locale/en.json'),
        '{\n'
        '  "a_key": "A",\n'
        '  "app_title": "App",\n'
        '  "welcome_back": "Welcome back"\n'
        '}',
      );
      expect(
        project.readFile('assets/locale/nl.json'),
        '{\n'
        '  "a": {\n'
        '    "one": "1 item",\n'
        '    "other": "%d items"\n'
        '  },\n'
        '  "b": "B"\n'
        '}',
      );
      expect(printed, [
        'Formatting assets/locale/en.json',
        'Formatting assets/locale/nl.json',
        'Formatting done!',
      ]);
    });

    test('formats the files on disk in locale_assets_path, not assets_path',
        () {
      // assets_path is where the files are in the app's asset bundle, which
      // can be a different folder than the one the generator reads from.
      final project = TestProject()
        ..writeFile('assets/i18n/en.json', '{"b": "B", "a": "A"}')
        ..writeFile('translations/en.json', '{"b": "B", "a": "A"}');
      final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en']
  assets_path: assets/i18n
  locale_assets_path: translations
''');

      final printed = project.run(() => LocaleGenFormatter.format(params));

      expect(project.readFile('translations/en.json'),
          '{\n  "a": "A",\n  "b": "B"\n}');
      expect(project.readFile('assets/i18n/en.json'), '{"b": "B", "a": "A"}');
      expect(printed, ['Formatting translations/en.json', 'Formatting done!']);
    });
  });
}
