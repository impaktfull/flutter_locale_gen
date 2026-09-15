import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'helpers/golden.dart';
import 'helpers/test_project.dart';

/// Line coverage cannot see the Dart that locale_gen writes out as strings,
/// such as `_formatDuration`, `_mf` and the sprintf calls. This test generates
/// a real project with the Dart writer, runs it, and snapshots what every
/// translation renders to in every language.
void main() {
  test(
    'generated Dart code renders every translation format',
    () async {
      final project = TestProject()
        ..writeFile('pubspec.yaml', '''
name: runtime_app
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  intl: ^0.20.2
  sprintf: ^7.0.0
dev_dependencies:
  locale_gen:
    path: ${jsonEncode(Directory.current.path)}
locale_gen:
  languages: ['en', 'nl']
  output_type: dart
''')
        ..writeFile('bin/main.dart', _program);
      for (final language in ['en', 'nl']) {
        // The Dart writer does not support JSON-object plurals.
        final translations = goldenFixture(language)..remove('hours');
        project.writeFile(
            'assets/locale/$language.json', jsonEncode(translations));
      }

      await _dart(['pub', 'get'], project.path);
      await _dart(['run', 'locale_gen'], project.path);
      final output = await _dart(['run', 'bin/main.dart'], project.path);

      expectGolden(output, 'dart/runtime_output.txt');
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Future<String> _dart(List<String> arguments, String workingDirectory) async {
  final result = await Process.run(Platform.resolvedExecutable, arguments,
      workingDirectory: workingDirectory, stdoutEncoding: utf8);
  if (result.exitCode != 0) {
    fail('dart ${arguments.join(' ')} failed in $workingDirectory:\n'
        '${result.stdout}\n${result.stderr}');
  }
  return (result.stdout as String).replaceAll('\r\n', '\n');
}

const _program = '''
import 'package:intl/date_symbol_data_local.dart';
import 'package:runtime_app/util/locale/localization.dart';

Future<void> main() async {
  await initializeDateFormatting();
  final l = Localization.instance;
  final values = <String, LocalizedValue>{
    'title': l.title,
    'multiline': l.multiline,
    'welcome_back': l.welcomeBack('Koen', 3),
    'paid': l.paid('Koen', 2.5),
    'greeting': l.greeting(name: 'Koen'),
    'cart_count 0': l.cartCount(count: 0),
    'cart_count 1': l.cartCount(count: 1),
    'cart_count 3': l.cartCount(count: 3),
    'pronoun female': l.pronoun(gender: 'female'),
    'rank 1': l.rank(place: 1),
    'rank 2': l.rank(place: 2),
    'rank 3': l.rank(place: 3),
    'rank 4': l.rank(place: 4),
    'total': l.total(total: 1234.5),
    'share': l.share(share: 0.42),
    'placed_at': l.placedAt(placedAt: DateTime(2026, 9, 15)),
    'meeting_at': l.meetingAt(at: DateTime(2026, 9, 15, 14, 30)),
    'lap_time': l.lapTime(lap: const Duration(minutes: 1, seconds: 42)),
    'quote': l.quote,
  };
  values.forEach((key, value) {
    print('\$key');
    print('  en: \${value.en}');
    print('  nl: \${value.nl}');
  });
}
''';
