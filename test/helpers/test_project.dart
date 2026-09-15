import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:test/test.dart';

/// A throwaway project directory for tests that read or write files.
///
/// Code passed to [run] sees this project as `Directory.current` through
/// [IOOverrides], so tests running in parallel never share a working
/// directory. The directory is deleted when the test ends.
class TestProject {
  final Directory directory;

  TestProject._(this.directory);

  factory TestProject() {
    final project =
        TestProject._(Directory.systemTemp.createTempSync('locale_gen_test_'));
    addTearDown(() => project.directory.deleteSync(recursive: true));
    return project;
  }

  String get path => directory.path;

  void writeFile(String relativePath, String content) {
    File(join(path, relativePath))
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }

  String readFile(String relativePath) =>
      File(join(path, relativePath)).readAsStringSync();

  bool fileExists(String relativePath) =>
      File(join(path, relativePath)).existsSync();

  /// Runs [body] with this project as the current directory and returns every
  /// line it printed.
  List<String> run(void Function() body) {
    final printed = <String>[];
    IOOverrides.runZoned(
      () => runZoned(
        body,
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      ),
      getCurrentDirectory: () => directory,
    );
    return printed;
  }

  /// [run] for asynchronous code, such as a `bin/` entry point.
  Future<List<String>> runAsync(Future<void> Function() body) async {
    final printed = <String>[];
    await IOOverrides.runZoned(
      () => runZoned(
        body,
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      ),
      getCurrentDirectory: () => directory,
    );
    return printed;
  }
}
