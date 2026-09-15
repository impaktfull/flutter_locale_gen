import 'package:locale_gen/src/model/locale_gen_type.dart';
import 'package:locale_gen/src/writer/core_writer.dart';
import 'package:locale_gen/src/writer/dart/dart_writer.dart';
import 'package:locale_gen/src/writer/flutter/flutter_writer.dart';
import 'package:test/test.dart';

import '../../helpers/test_project.dart';

void main() {
  group('LocaleGenCoreWriter.fromType', () {
    test('returns the Flutter writer for flutter', () {
      expect(LocaleGenCoreWriter.fromType(LocaleGenOutputType.flutter),
          isA<LocaleGenFlutterWriter>());
    });

    test('returns the Dart writer for dart', () {
      expect(LocaleGenCoreWriter.fromType(LocaleGenOutputType.dart),
          isA<LocaleGenDartWriter>());
    });
  });

  group('LocaleGenCoreWriter.writeFile', () {
    test('creates the file and its directories, and says so', () {
      final project = TestProject();

      final printed = project.run(() => LocaleGenDartWriter()
          .writeFile('lib/util/locale/', 'localization.dart', 'content'));

      expect(project.readFile('lib/util/locale/localization.dart'), 'content');
      expect(printed, [
        'localization.dart does not exists',
        'Creating localization.dart ...',
      ]);
    });

    test('overwrites an existing file without printing', () {
      final project = TestProject()
        ..writeFile('lib/util/locale/localization.dart', 'old');

      final printed = project.run(() => LocaleGenDartWriter()
          .writeFile('lib/util/locale/', 'localization.dart', 'new'));

      expect(project.readFile('lib/util/locale/localization.dart'), 'new');
      expect(printed, isEmpty);
    });
  });
}
