import 'dart:async';
import 'dart:io';
import 'package:locale_gen/locale_gen.dart';
import 'package:path/path.dart';

Future<void> main(List<String> args) async {
  final localeGenWriter = LocaleGenWriter(programName: 'locale_gen');

  final defaultTranslationFile = File(join(Directory.current.path, localeGenWriter.assetsDir, '${localeGenWriter.defaultLanguage}.json'));
  if (!defaultTranslationFile.existsSync()) {
    throw Exception('${defaultTranslationFile.path} does not exists');
  }
  localeGenWriter.write(defaultTranslationFile);
}
