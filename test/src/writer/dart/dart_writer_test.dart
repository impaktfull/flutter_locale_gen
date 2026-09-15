import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/dart/dart_generator.dart';
import 'package:locale_gen/src/writer/dart/dart_writer.dart';
import 'package:test/test.dart';

import '../../../helpers/test_project.dart';

void main() {
  test('writes the generated Dart file to output_path', () {
    final project = TestProject();
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en', 'nl']
  output_type: dart
  output_path: lib/l10n
''');
    final allTranslations = {
      'en': {'title': 'Title'},
      'nl': {'title': 'Titel'},
    };

    final printed = project.run(() => LocaleGenDartWriter()
        .write(params, allTranslations['en']!, allTranslations));

    expect(
      project.readFile('lib/l10n/localization.dart'),
      LocaleGenDartGenerator().createLocalizationFile(
          params, allTranslations['en']!, allTranslations),
    );
    expect(printed, [
      'localization.dart does not exists',
      'Creating localization.dart ...',
    ]);
  });
}
