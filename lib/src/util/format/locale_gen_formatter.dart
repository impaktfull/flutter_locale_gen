import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/util/case/case_util.dart';
import 'package:path/path.dart';

class LocaleGenFormatter {
  // Public API: keeps the class uninstantiable without changing its modifiers.
  const LocaleGenFormatter._(); // coverage:ignore-line

  static void format(LocaleGenParams params) {
    const jsonEncoder = JsonEncoder.withIndent('  ');
    for (final language in params.languages) {
      // locale_assets_path, where the files are on disk. assets_path is their
      // location in the app's asset bundle, which can be a different folder.
      final path = '${params.localeAssetsDir}$language.json';
      print('Formatting $path');
      final file = File(join(Directory.current.path, path));
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
