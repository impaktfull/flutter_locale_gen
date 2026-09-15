// Runs every test with coverage and fails unless:
//
// - every Dart file in lib/src/ and bin/ has a test file mirroring its path
//   (lib/src/a/b.dart -> test/src/a/b_test.dart, bin/c.dart -> test/bin/c_test.dart),
// - every line in lib/ is covered.
//
// Usage, from the repository root:
//   dart run tool/coverage.dart
//
// A line that can never run (for example a private constructor that only
// exists to block instantiation) can be excluded with `// coverage:ignore-line`.
// Use it sparingly and say why next to it.
import 'dart:io';

import 'package:path/path.dart';

Future<void> main() async {
  final missingTests = _sourcesWithoutTests();
  if (missingTests.isNotEmpty) {
    stderr.writeln('These source files have no test file:');
    for (final entry in missingTests.entries) {
      stderr.writeln('  ${entry.key} -> create ${entry.value}');
    }
    exitCode = 1;
    return;
  }

  final tests = await Process.start(
    Platform.resolvedExecutable,
    ['run', 'coverage:test_with_coverage'],
    mode: ProcessStartMode.inheritStdio,
  );
  if (await tests.exitCode != 0) {
    exitCode = 1;
    return;
  }

  final hits = _readLcov(File(join('coverage', 'lcov.info')));
  var total = 0;
  final uncovered = <String>[];
  for (final file in _dartFiles('lib')) {
    final lines = hits[file];
    if (lines == null) {
      if (_hasCode(file)) uncovered.add('$file: never loaded by a test');
      continue;
    }
    total += lines.length;
    final source = File(file).readAsLinesSync();
    for (final entry in lines.entries.where((e) => e.value == 0)) {
      uncovered.add('$file:${entry.key}: ${source[entry.key - 1].trim()}');
    }
  }

  if (uncovered.isNotEmpty) {
    stderr.writeln('\nNot covered by any test:');
    for (final line in uncovered) {
      stderr.writeln('  $line');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('\n100% line coverage: all $total lines in lib/ are covered.');
}

/// Source files without their mirrored test file, mapped to that test file.
Map<String, String> _sourcesWithoutTests() {
  final expected = <String, String>{
    join('lib', 'locale_gen.dart'): join('test', 'locale_gen_test.dart'),
    for (final file in _dartFiles(join('lib', 'src')))
      file: join('test', 'src',
          '${withoutExtension(relative(file, from: join('lib', 'src')))}_test.dart'),
    for (final file in _dartFiles('bin'))
      file: join('test', 'bin',
          '${withoutExtension(relative(file, from: 'bin'))}_test.dart'),
  };
  return {
    for (final entry in expected.entries)
      if (!File(entry.value).existsSync()) entry.key: entry.value,
  };
}

List<String> _dartFiles(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .map((file) => normalize(file.path))
    .where((path) => path.endsWith('.dart'))
    .toList()
  ..sort();

/// Line hits per file, keyed by the file's path relative to the repository.
Map<String, Map<int, int>> _readLcov(File lcov) {
  final hits = <String, Map<int, int>>{};
  Map<int, int>? current;
  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final path = line.substring(3);
      current = hits[normalize(isAbsolute(path) ? relative(path) : path)] = {};
    } else if (line.startsWith('DA:')) {
      final [lineNumber, count, ...] = line.substring(3).split(',');
      current![int.parse(lineNumber)] = int.parse(count);
    }
  }
  return hits;
}

/// False for files with only directives and comments, such as lib/locale_gen.dart.
bool _hasCode(String file) => File(file).readAsLinesSync().any((line) {
      final trimmed = line.trim();
      return trimmed.isNotEmpty &&
          !trimmed.startsWith('//') &&
          !trimmed.startsWith('export ') &&
          !trimmed.startsWith('import ') &&
          !trimmed.startsWith('library');
    });
