import 'package:test/test.dart';

import '../../bin/format.dart' as format;
import '../helpers/test_project.dart';

void main() {
  test('formats the translation files of the project in the current directory',
      () {
    final project = TestProject()
      ..writeFile('pubspec.yaml', '''
name: my_app
locale_gen:
  languages: ['en']
''')
      ..writeFile('assets/locale/en.json', '{"b": "B", "a": "A"}');

    final printed = project.run(format.main);

    expect(project.readFile('assets/locale/en.json'),
        '{\n  "a": "A",\n  "b": "B"\n}');
    expect(printed, ['Formatting assets/locale/en.json', 'Formatting done!']);
  });
}
