import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

const _marker = 'x-release-please-version';

/// A release PR bumps `pubspec.yaml`, `.release-please-manifest.json` and
/// every line marked `x-release-please-version` in the `extra-files` of
/// `release-please-config.json`. These tests fail when one of them is edited
/// by hand and drifts from the others.
void main() {
  final version = (loadYaml(File('pubspec.yaml').readAsStringSync())
      as YamlMap)['version'] as String;
  final config =
      jsonDecode(File('release-please-config.json').readAsStringSync())
          as Map<String, dynamic>;
  final package =
      (config['packages'] as Map<String, dynamic>)['.'] as Map<String, dynamic>;
  final extraFiles =
      (package['extra-files'] as List<dynamic>).cast<Map<String, dynamic>>();

  test('pubspec.yaml has a plain version release-please can bump', () {
    // release-please keeps anything after the numbers as a build suffix:
    // 13.0.0-alpha.2 would be released as 13.0.0+-alpha.2.
    expect(version, matches(RegExp(r'^\d+\.\d+\.\d+$')));
  });

  test('the manifest holds the version of pubspec.yaml', () {
    final manifest =
        jsonDecode(File('.release-please-manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(manifest['.'], version);
  });

  test('extra-files only update their marked lines', () {
    // A plain path makes release-please also set a top-level `version` in
    // YAML and JSON files; `generic` touches the marked lines only.
    expect(extraFiles.map((file) => file['type']), everyElement('generic'));
  });

  for (final extraFile in extraFiles) {
    final path = extraFile['path'] as String;
    test('$path is on the version of pubspec.yaml', () {
      final marked = File(path)
          .readAsLinesSync()
          .where((line) => line.contains(_marker))
          .toList();
      expect(marked, isNotEmpty, reason: 'no line in $path is marked $_marker');
      for (final line in marked) {
        expect(RegExp(r'\d+\.\d+\.\d+\S*').firstMatch(line)?[0], version,
            reason: line);
      }
    });
  }

  test('every file with a version marker is in extra-files', () {
    final result = Process.runSync('git', [
      'grep',
      '-l',
      _marker,
      '--',
      '.',
      ':!test',
      ':!CONTRIBUTING.md',
    ]);
    expect(
      LineSplitter.split(result.stdout as String).toSet(),
      extraFiles.map((file) => file['path']).toSet(),
    );
  });
}
