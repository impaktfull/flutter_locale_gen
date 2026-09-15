import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';
import 'package:locale_gen/src/writer/flutter/flutter_writer.dart';
import 'package:test/test.dart';

import '../../../helpers/test_project.dart';

void main() {
  test('writes the four generated Flutter files to output_path', () {
    final project = TestProject();
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en', 'nl']
  output_path: lib/l10n
''');
    final allTranslations = {
      'en': {'greeting': 'Hi, {name}!'},
      'nl': {'greeting': 'Hallo, {name}!'},
    };
    final defaultTranslations = allTranslations['en']!;
    final generator = LocaleGenFlutterGenerator();

    final printed = project.run(() => LocaleGenFlutterWriter()
        .write(params, defaultTranslations, allTranslations));

    expect(
      project.readFile('lib/l10n/localization_keys.dart'),
      generator.createLocalizationKeysFile(
          params, defaultTranslations, allTranslations),
    );
    expect(
      project.readFile('lib/l10n/localization.dart'),
      generator.createLocalizationFile(
          params, defaultTranslations, allTranslations),
    );
    expect(
      project.readFile('lib/l10n/localization_delegate.dart'),
      generator.createLocalizationDelegateFile(params),
    );
    expect(
      project.readFile('lib/l10n/localization_overrides.dart'),
      generator.createLocalizationOverrides(params),
    );
    expect(printed, [
      'localization_keys.dart does not exists',
      'Creating localization_keys.dart ...',
      'localization.dart does not exists',
      'Creating localization.dart ...',
      'localization_delegate.dart does not exists',
      'Creating localization_delegate.dart ...',
      'localization_overrides.dart does not exists',
      'Creating localization_overrides.dart ...',
    ]);
  });
}
