import 'dart:io';

import 'package:test/test.dart';

void main() {
  final allowedExports = [
    'src/model/locale_gen_params.dart',
    'src/locale_gen_writer.dart',
    'src/util/format/locale_gen_formatter.dart',
  ];
  test('Check if only allowed files are exported', () {
    final file = File('lib/locale_gen.dart');
    expect(file.existsSync(), true);
    final content = file.readAsLinesSync();
    final fullAllowedExports = allowedExports.map((e) => 'export \'$e\';').toList();
    var amountOfExports = 0;
    for (final line in content) {
      expect(line.contains('package:locale_gen/'), false, reason: '$line should not contain package:locale_gen/');
      expect(fullAllowedExports.contains(line), true, reason: '$line is not allowed');
      amountOfExports++;
    }
    expect(amountOfExports, allowedExports.length, reason: 'Amount of exports should be ${allowedExports.length}');
  });
}
