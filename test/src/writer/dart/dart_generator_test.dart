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

    test('emits _mf and message_format import when MessageFormat keys exist',
        () {
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
      expect(
          out,
          contains(
              "en: _mf(\"Hi, {name}!\", args: {'name': name}, locale: 'en')"));
      expect(
          out,
          contains(
              "nl: _mf(\"Hallo, {name}!\", args: {'name': name}, locale: 'nl')"));
    });

    test('plural generates a num count param returning LocalizedValue', () {
      final out = generate({
        'en': {'cart_count': '{count, plural, one {# item} other {# items}}'},
        'nl': {'cart_count': '{count, plural, one {# stuk} other {# stuks}}'},
      });
      expect(out, contains('LocalizedValue cartCount({required num count})'));
      expect(out, contains("args: {'count': count}"));
    });

    test('camelCases uppercase names but preserves original key in args map',
        () {
      final out = generate({
        'en': {'confirm_terms': 'See {SC} please'},
        'nl': {'confirm_terms': 'Zie {SC} aub'},
      });
      expect(
          out, contains('LocalizedValue confirmTerms({required String sc})'));
      expect(out, contains("'SC': sc"));
    });

    test('emits _formatDuration helper when duration is used', () {
      final out = generate({
        'en': {'race': '{d, duration}'},
        'nl': {'race': '{d, duration}'},
      });
      expect(
          out, contains('String _formatDuration(Duration d, String? style)'));
      expect(out, contains('LocalizedValue race({required Duration d})'));
      expect(out, contains('_formatDuration(d, null)'));
    });

    test('date short uses DateFormat.yMd with the locale baked in', () {
      final out = generate({
        'en': {'placedAt': 'Placed {placedAt, date, short}'},
        'nl': {'placedAt': 'Geplaatst {placedAt, date, short}'},
      });
      expect(out,
          contains('LocalizedValue placedAt({required DateTime placedAt})'));
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

  group('LocaleGenDartGenerator output', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
  doc_languages: []
''');
    final generator = LocaleGenDartGenerator();

    ({String output, List<String> printed}) generate(
        Map<String, Map<String, dynamic>> all) {
      final printed = <String>[];
      final output = runZoned(
        () => generator.createLocalizationFile(params, all['en']!, all),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      );
      return (output: output, printed: printed);
    }

    Matcher throwsMessage(String message) => throwsA(isA<Exception>()
        .having((e) => e.toString(), 'message', 'Exception: $message'));

    test('a plain value is a getter with every language', () {
      final result = generate({
        'en': {'title': 'Title'},
        'nl': {'title': 'Titel'},
      });
      expect(
        result.output,
        contains('  LocalizedValue get title => LocalizedValue(\n'
            '    en: _t("Title"),\n'
            '    nl: _t("Titel"),\n'
            '  );\n'),
      );
    });

    test('sprintf markers become positional parameters', () {
      final result = generate({
        'en': {'welcome': r'Welcome %1$s, you have %2$d messages'},
        'nl': {'welcome': r'Welkom %1$s, je hebt %2$d berichten'},
      });
      expect(
        result.output,
        contains('  LocalizedValue welcome(String arg1, int arg2) => '
            'LocalizedValue(\n'
            r'    en: _t("Welcome %1\$s, you have %2\$d messages", args: <dynamic> [arg1, arg2]),'
            '\n'
            r'    nl: _t("Welkom %1\$s, je hebt %2\$d berichten", args: <dynamic> [arg1, arg2]),'
            '\n'
            '  );\n'),
      );
    });

    test('escapes values for a Dart string literal', () {
      final result = generate({
        'en': {'note': 'Say "hi" \\ to\nthe\rworld for \$5'},
        'nl': {'note': 'Zeg "hoi"'},
      });
      expect(
        result.output,
        contains(r'    en: _t("Say \"hi\" \\ to\nthe\rworld for \$5"),'),
      );
    });

    test('MessageFormat without parameters is a getter', () {
      final result = generate({
        'en': {'quote': "It''s here"},
        'nl': {'quote': "Het is ''hier''"},
      });
      expect(
        result.output,
        contains('  LocalizedValue get quote => LocalizedValue(\n'
            "    en: _mf(\"It''s here\", args: const {}, locale: 'en'),\n"
            "    nl: _mf(\"Het is ''hier''\", args: const {}, locale: 'nl'),\n"
            '  );\n'),
      );
    });

    test('a value that is not a String in another language falls back whole',
        () {
      final result = generate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {
          'greeting': {'other': 'Hallo'},
        },
      });
      expect(result.printed, [
        'Exception: Key greeting in locale nl is not a String for MessageFormat'
      ]);
      expect(result.output,
          isNot(contains('LocalizedValue greeting({required String name})')));
      expect(
        result.output,
        contains('  LocalizedValue get greeting => LocalizedValue(\n'
            '    en: _t("Hi, {name}!"),\n'
            '    nl: _t("{other: Hallo}"),\n'
            '  );\n'),
      );
    });

    test('fails when a language has no value for a key', () {
      expect(
        () => generate({
          'en': {'title': 'Title'},
          'nl': {},
        }),
        throwsMessage('Key title not found in locale nl for allTranslations'),
      );
    });

    test('fails when a language has no translations at all', () {
      expect(
        () => generate({
          'en': {'title': 'Title'},
        }),
        throwsMessage('Locale nl not found in allTranslations for key title'),
      );
    });

    test('fails for JSON-object plurals', () {
      expect(
        () => generate({
          'en': {
            'hours': {'other': 'hours'},
          },
          'nl': {
            'hours': {'other': 'uren'},
          },
        }),
        throwsMessage('Plurals are not supported for `dart` writer'),
      );
    });

    test('its plural builders throw an ArgumentError', () {
      final all = {'en': <String, dynamic>{}, 'nl': <String, dynamic>{}};
      expect(
        () => generator.buildTranslationFunction(StringBuffer(), params,
            'hours', {'one': 'An hour', 'other': 'Hours'}, all),
        throwsArgumentError,
      );
      expect(
        () => generator.buildTranslationFunction(
            StringBuffer(), params, 'hours', {'other': '%d hours'}, all),
        throwsArgumentError,
      );
    });
  });
}
