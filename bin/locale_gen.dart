import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'src/locale_gen_writer.dart';

export 'src/locale_gen_writer.dart';

Future<void> main(List<String> args) async {
  final outputDir = join('lib', 'util', 'locale');
  final assetsDir = join('assets', 'locale');

  final localeGenWriter = LocaleGenWriter(
    outputDir: outputDir,
    assetsDir: assetsDir,
    programName: 'locale_gen',
  );

  final defaultLocaleJson = File(join(Directory.current.path, assetsDir, '${localeGenWriter.defaultLanguage}.json'));
  if (!defaultLocaleJson.existsSync()) {
    throw Exception('${defaultLocaleJson.path} does not exists');
  }
  localeGenWriter.write(defaultLocaleJson);
  print('Done!!!');
}
