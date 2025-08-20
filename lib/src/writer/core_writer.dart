import 'dart:io';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/model/locale_gen_type.dart';
import 'package:locale_gen/src/writer/dart/dart_writer.dart';
import 'package:locale_gen/src/writer/flutter/flutter_writer.dart';
import 'package:path/path.dart';

abstract class LocaleGenCoreWriter {
  void write(
    LocaleGenParams params,
    Map<String, dynamic> defaultTranslations,
    Map<String, Map<String, dynamic>> allTranslations,
  );

  void writeFile(String outputDir, String fileName, String content) {
    final file = File(join(Directory.current.path, outputDir, fileName));
    if (!file.existsSync()) {
      print('$fileName does not exists');
      print('Creating $fileName ...');
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(content);
  }

  static LocaleGenCoreWriter fromType(LocaleGenOutputType type) {
    switch (type) {
      case LocaleGenOutputType.flutter:
        return LocaleGenFlutterWriter();
      case LocaleGenOutputType.dart:
        return LocaleGenDartWriter();
    }
  }
}
