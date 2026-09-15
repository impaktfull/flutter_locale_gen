import 'dart:convert';

import 'package:locale_gen/locale_gen.dart';
import 'package:test/test.dart';

import 'helpers/golden.dart';
import 'helpers/test_project.dart';

/// Snapshots of the complete generated code for a fixture that uses every
/// translation format. Any change to the generated code shows up here first,
/// as a reviewable difference with the files in `test/goldens`.
void main() {
  const languages = ['en', 'nl'];

  /// Generates [outputType] code for the fixture and returns every generated
  /// file by name.
  Map<String, String> generate(
    String outputType, {
    Set<String> skipKeys = const {},
  }) {
    final project = TestProject();
    for (final language in languages) {
      final translations = goldenFixture(language)
        ..removeWhere((key, value) => skipKeys.contains(key));
      project.writeFile(
          'assets/locale/$language.json', jsonEncode(translations));
    }
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: golden_app
locale_gen:
  languages: ['en', 'nl']
  output_type: $outputType
''');
    project.run(() => LocaleGenWriter.write(params));
    return {
      for (final file in project.directory
          .listSync(recursive: true)
          .where((entity) => entity.path.endsWith('.dart')))
        file.uri.pathSegments.last:
            project.readFile('lib/util/locale/${file.uri.pathSegments.last}'),
    };
  }

  test('flutter output', () {
    final files = generate('flutter');
    expect(
        files.keys,
        unorderedEquals([
          'localization.dart',
          'localization_keys.dart',
          'localization_delegate.dart',
          'localization_overrides.dart',
        ]));
    // `.golden`, not `.dart`: the analyzer and `dart format` must leave the
    // snapshots of raw generated output alone.
    files.forEach(
        (name, content) => expectGolden(content, 'flutter/$name.golden'));
  });

  test('dart output', () {
    // The Dart writer does not support JSON-object plurals.
    final files = generate('dart', skipKeys: {'hours'});
    expect(files.keys, ['localization.dart']);
    expectGolden(files['localization.dart']!, 'dart/localization.dart.golden');
  });
}
