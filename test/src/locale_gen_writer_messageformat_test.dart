import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  test('end-to-end Flutter generation for MessageFormat fixtures', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
''');

    final en = json.decode(
            File('test/assets/locale/messageformat/en.json').readAsStringSync())
        as Map<String, dynamic>;
    final nl = json.decode(
            File('test/assets/locale/messageformat/nl.json').readAsStringSync())
        as Map<String, dynamic>;

    final generator = LocaleGenFlutterGenerator();
    final out =
        generator.createLocalizationFile(params, en, {'en': en, 'nl': nl});

    expect(out, contains('String greeting({required String name})'));
    expect(out, contains('String cartCount({required num count})'));
    expect(
        out,
        contains(
            'String orderPlaced({required DateTime placedAt, required num total})'));
    expect(out, contains('String race({required Duration d})'));
    expect(out, contains('String pronoun({required String gender})'));

    expect(out, contains('String _mf('));
    expect(out, contains('String _stripFormatSpecs('));
    expect(out, contains('String _formatDuration('));
    expect(out, contains("import 'package:intl/message_format.dart';"));
  });
}
