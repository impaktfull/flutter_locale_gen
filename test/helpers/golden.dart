import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:test/test.dart';

const goldensDirectory = 'test/goldens';

final _update = Platform.environment['UPDATE_GOLDENS'] == 'true';

/// Compares [actual] with the golden file at [goldenPath], relative to
/// `test/goldens`. With `UPDATE_GOLDENS=true` it writes [actual] instead.
void expectGolden(String actual, String goldenPath) {
  final file = File(join(goldensDirectory, goldenPath));
  final command = 'UPDATE_GOLDENS=true dart test ${_testFile()}';
  if (_update) {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(actual);
    return;
  }
  expect(file.existsSync(), isTrue,
      reason: '$goldenPath does not exist yet. Create it with: $command');
  // Goldens are stored with LF endings, see .gitattributes.
  expect(actual, file.readAsStringSync().replaceAll('\r\n', '\n'),
      reason: '$goldenPath changed. Review the difference and, when the new '
          'output is intended, update the golden with: $command');
}

/// The JSON fixture for [language] in `test/goldens/fixture`.
Map<String, dynamic> goldenFixture(String language) =>
    jsonDecode(File(join(goldensDirectory, 'fixture', '$language.json'))
        .readAsStringSync()) as Map<String, dynamic>;

String _testFile() {
  final frame = StackTrace.current
      .toString()
      .split('\n')
      .firstWhere((line) => line.contains('_test.dart'), orElse: () => '');
  return RegExp(r'(test/[\w/]+_test\.dart)').firstMatch(frame)?[1] ?? '';
}
