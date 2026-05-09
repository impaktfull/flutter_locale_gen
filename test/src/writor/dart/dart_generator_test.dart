import 'dart:async';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/dart/dart_generator.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleGenDartGenerator MessageFormat support', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
''');
    final generator = LocaleGenDartGenerator();

    String generate(Map<String, Map<String, dynamic>> all) {
      return generator.createLocalizationFile(params, all['en']!, all);
    }

    test('emits _mf and message_format import when MessageFormat keys exist', () {
      final out = generate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {name}!'},
      });
      expect(out, contains("import 'package:intl/intl.dart';"));
      expect(out, contains("import 'package:intl/message_format.dart';"));
      expect(out, contains('String _mf('));
      expect(out, contains('LocalizedValue greeting({required String name})'));
    });

    test('does not emit Flutter imports', () {
      final out = generate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {name}!'},
      });
      expect(out, isNot(contains('package:flutter/widgets.dart')));
      expect(out, isNot(contains('package:flutter/services.dart')));
    });

    test('emits a _mf call per language inside LocalizedValue', () {
      final out = generate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {name}!'},
      });
      expect(out, contains("en: _mf(\"Hi, {name}!\", args: {'name': name}, locale: 'en')"));
      expect(out, contains("nl: _mf(\"Hallo, {name}!\", args: {'name': name}, locale: 'nl')"));
    });

    test('plural generates a num count param returning LocalizedValue', () {
      final out = generate({
        'en': {'cart_count': '{count, plural, one {# item} other {# items}}'},
        'nl': {'cart_count': '{count, plural, one {# stuk} other {# stuks}}'},
      });
      expect(out, contains('LocalizedValue cartCount({required num count})'));
      expect(out, contains("args: {'count': count}"));
    });

    test('camelCases uppercase names but preserves original key in args map', () {
      final out = generate({
        'en': {'confirm_terms': 'See {SC} please'},
        'nl': {'confirm_terms': 'Zie {SC} aub'},
      });
      expect(out, contains('LocalizedValue confirmTerms({required String sc})'));
      expect(out, contains("'SC': sc"));
    });

    test('emits _formatDuration helper when duration is used', () {
      final out = generate({
        'en': {'race': '{d, duration}'},
        'nl': {'race': '{d, duration}'},
      });
      expect(out, contains('String _formatDuration(Duration d, String? style)'));
      expect(out, contains('LocalizedValue race({required Duration d})'));
      expect(out, contains('_formatDuration(d, null)'));
    });

    test('date short uses DateFormat.yMd with the locale baked in', () {
      final out = generate({
        'en': {'placedAt': 'Placed {placedAt, date, short}'},
        'nl': {'placedAt': 'Geplaatst {placedAt, date, short}'},
      });
      expect(out, contains('LocalizedValue placedAt({required DateTime placedAt})'));
      expect(out, contains("DateFormat.yMd('en').format(placedAt)"));
      expect(out, contains("DateFormat.yMd('nl').format(placedAt)"));
    });

    test('cross-locale validator warns through Dart writer too', () {
      final buf = StringBuffer();
      runZoned(
        () => generator.createLocalizationFile(params, {
          'greeting': 'Hi, {name}!',
        }, {
          'en': {'greeting': 'Hi, {name}!'},
          'nl': {'greeting': 'Hallo, {naam}!'},
        }),
        zoneSpecification: ZoneSpecification(
          print: (_, __, ___, line) => buf.writeln(line),
        ),
      );
      expect(buf.toString(), contains('greeting'));
      expect(buf.toString(), contains('"nl"'));
    });
  });
}
