import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/util/case/case_util.dart';

class LocaleGenFormatter {
  const LocaleGenFormatter._();

  static void format(LocaleGenParams params) {
    final files = params.languages
        .map((language) => File('${params.assetsDir}$language.json'));
    const jsonEncoder = JsonEncoder.withIndent('  ');
    for (final file in files) {
      print('Formatting ${file.path}');
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final newJson = {};
      final sortedKeys = json.keys.toList()..sort();
      for (final key in sortedKeys) {
        final value = json[key];
        newJson[CaseUtil.getSnakeCase(key)] = value;
      }

      final data = jsonEncoder.convert(newJson);
      file.writeAsStringSync(data);
    }
    print('Formatting done!');
  }
}
