import 'package:test/test.dart';

import '../../bin/locale_gen.dart' as locale_gen;
import '../helpers/test_project.dart';

void main() {
  test('generates the code for the project in the current directory', () async {
    final project = TestProject()
      ..writeFile('pubspec.yaml', '''
name: my_app
locale_gen:
  languages: ['en']
''')
      ..writeFile('assets/locale/en.json', '{"title": "Title"}');

    final printed = await project.runAsync(() => locale_gen.main([]));

    expect(printed.first, 'Default language: en');
    expect(printed.last, 'Done!!!');
    expect(
      project.readFile('lib/util/locale/localization.dart'),
      contains('String get title => _t(LocalizationKeys.title);'),
    );
  });

  test('fails outside the root of a project', () async {
    final project = TestProject();

    await expectLater(
      project.runAsync(() => locale_gen.main([])),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message',
          contains('should be run from the root of a flutter/dart project'))),
    );
  });
}
