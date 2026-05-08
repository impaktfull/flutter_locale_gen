import 'dart:async';

import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  final params = LocaleGenParams.fromYamlString(
    'locale_gen',
    '''name: locale_gen_example
locale_gen:
  languages: ['en','nl']
''',
  );

  group('buildTranslationFunction', () {
    group('Tests without arguments', () {
      test('Test null translations', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator()
            .buildTranslationFunction(sb, params, 'app_title', null, {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
      test('Test empty translations', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator()
            .buildTranslationFunction(sb, params, 'app_title', '', {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
      test('Test translations without arguments', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator()
            .buildTranslationFunction(sb, params, 'app_title', 'hallo', {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
    });

    group('Tests with string arguments', () {
      test('Test translations with 1 string argument', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$s', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1]);\n\n'));
      });

      test('Test translations with 2 string arguments', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$s %2\$s', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, String arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });

      test('Test translations with 1 string argument but 2 string replacements',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$s %1\$s', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1]);\n\n'));
      });

      test(
          'Test translations with 11 arguments of the same index and same type',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb,
            params,
            'app_title',
            'hallo %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s',
            {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1]);\n\n'));
      });

      test('Test translations with 2 string arguments, non-positional', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %s %s', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, String arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });

      test(
          'Test translations with 1 string and 1 integer argument, non-positional',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %s %d', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, int arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });
      test(
          'Test translations with 1 string and 1 complex float argument, non-positional',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %s %.02f', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, double arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });
    });

    group('Tests with number arguments', () {
      test('Test translations with 1 number argument', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$d', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(int arg1) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1]);\n\n'));
      });

      test('Test translations with 2 number arguments', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$d %2\$f', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(int arg1, double arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });

      test('Test translations with 2 number arguments, special float format',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$d %2\$.04f', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(int arg1, double arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });

      test('Test translations with 1 number argument but 2 number replacements',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$d %1\$d', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(int arg1) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1]);\n\n'));
      });

      test(
          'Test translations with 11 arguments of the same index and same type',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb,
            params,
            'app_title',
            'hallo %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d',
            {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(int arg1) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1]);\n\n'));
      });
    });

    group('Tests with mixed arguments', () {
      test('Test translations with 1 number argument', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$s %2\$d', {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, int arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });

      test(
          'Test translations with 11 arguments of the same index and same type',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb,
            params,
            'app_title',
            'hallo %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %2\$d',
            {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, int arg2) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2]);\n\n'));
      });

      test('Test translations with 11 different arguments', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb,
            params,
            'app_title',
            'hallo %1\$s %2\$s %3\$s %4\$s %5\$s %6\$s %7\$s %8\$s %9\$s %10\$s %11\$s',
            {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, String arg2, String arg3, String arg4, String arg5, String arg6, String arg7, String arg8, String arg9, String arg10, String arg11) => _t(LocalizationKeys.appTitle, args: <dynamic>[arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]);\n\n'));
      });
    });

    group('Tests with invalid arguments', () {
      test('Test translations with unsupported type', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$z', {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });

      test('Test translations with different type of arguments for same index',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$s %1\$d', {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });

      test(
          'Test translations with mixed positional and non-positional arguments',
          () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', 'hallo %1\$s %d', {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
    });

    group('Tests with plurals', () {
      test('Test with plural without arguments', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb,
            params,
            'app_title',
            <String, dynamic>{'one': 'hour', 'other': 'hours'},
            {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(num count) => _plural(LocalizationKeys.appTitle, count: count);\n\n'));
      });
      test('Test with plural with arguments', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(
            sb, params, 'app_title', <String, dynamic>{
          'one': '%1\$s hour',
          'other': '%2\$s hours',
          'zero': '',
          'two': '',
          'few': '',
          'many': ''
        }, {});
        expect(
            sb.toString(),
            equals(
                '  String appTitle(num count, String arg1, String arg2) => _plural(LocalizationKeys.appTitle, count: count, args: <dynamic>[arg1, arg2]);\n\n'));
      });
      test('Test with plural without other', () {
        final sb = StringBuffer();
        LocaleGenFlutterGenerator().buildTranslationFunction(sb, params,
            'app_title', <String, dynamic>{'one': '%1\$s hour'}, {});
        expect(
            sb.toString(),
            equals(
                '  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
    });
  });

  group('LocaleGenFlutterGenerator MessageFormat helpers', () {
    final mfParams = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    test('emits _mf and _stripFormatSpecs when MessageFormat keys exist', () {
      final defaults = <String, dynamic>{'greeting': 'Hi, {name}!'};
      final all = <String, Map<String, dynamic>>{
        'en': {'greeting': 'Hi, {name}!'},
      };
      final output = generator.createLocalizationFile(mfParams, defaults, all);
      expect(output, contains("import 'package:intl/message_format.dart';"));
      expect(output, contains('String _mf('));
      expect(output, contains('String _stripFormatSpecs('));
    });

    test('does not emit MessageFormat helpers when no MessageFormat keys exist',
        () {
      final defaults = <String, dynamic>{'plain': 'hello world'};
      final all = <String, Map<String, dynamic>>{
        'en': {'plain': 'hello world'},
      };
      final output = generator.createLocalizationFile(mfParams, defaults, all);
      expect(output, isNot(contains('package:intl/message_format.dart')));
      expect(output, isNot(contains('String _mf(')));
    });
  });

  group('LocaleGenFlutterGenerator buildMessageFormatFunction (free-tier)', () {
    final mfParams = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    String generate(Map<String, dynamic> defaults) {
      return generator.createLocalizationFile(mfParams, defaults, {'en': defaults});
    }

    test('placeholder generates a named-required String param', () {
      final out = generate({'greeting': 'Hi, {name}!'});
      expect(out, contains('String greeting({required String name})'));
      expect(out, contains("LocalizationKeys.greeting"));
      expect(out, contains("'name': name"));
    });

    test('camelCases uppercase names but preserves original key in args map', () {
      final out = generate({'confirm_terms': 'See {SC} please'});
      expect(out, contains('String confirmTerms({required String sc})'));
      expect(out, contains("'SC': sc"));
    });

    test('plural generates a named-required num count param', () {
      final out =
          generate({'cart_count': '{count, plural, one {# item} other {# items}}'});
      expect(out, contains('String cartCount({required num count})'));
      expect(out, contains("'count': count"));
    });

    test('selectordinal generates a named-required num param', () {
      final out = generate({
        'rank': '{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}'
      });
      expect(out, contains('String rank({required num place})'));
    });

    test('select generates a named-required String param', () {
      final out = generate({
        'pronoun': '{gender, select, male {he} female {she} other {they}}'
      });
      expect(out, contains('String pronoun({required String gender})'));
    });

    test('multiple placeholders generate ordered named params', () {
      final out = generate({'mix': 'A {first} and {second}.'});
      expect(out, contains('String mix({required String first, required String second})'));
    });
  });

  group('LocaleGenFlutterGenerator buildMessageFormatFunction (formatters)', () {
    final mfParams = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    String generate(Map<String, dynamic> defaults) {
      return generator.createLocalizationFile(mfParams, defaults, {'en': defaults});
    }

    test('number with no style uses NumberFormat.decimalPattern', () {
      final out = generate({'count': 'Total {n, number}'});
      expect(out, contains('String count({required num n})'));
      expect(out, contains("NumberFormat.decimalPattern(locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()).format(n)"));
    });

    test('number percent uses NumberFormat.percentPattern', () {
      final out = generate({'rate': '{r, number, percent}'});
      expect(out, contains("NumberFormat.percentPattern(locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()).format(r)"));
    });

    test('number currency uses NumberFormat.simpleCurrency', () {
      final out = generate({'price': '{p, number, currency}'});
      expect(out, contains("NumberFormat.simpleCurrency(locale: locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()).format(p)"));
    });

    test('date short uses DateFormat.yMd', () {
      final out = generate({'placedAt': 'Placed {placedAt, date, short}'});
      expect(out, contains('String placedAt({required DateTime placedAt})'));
      expect(out, contains("DateFormat.yMd(locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()).format(placedAt)"));
    });

    test('date custom skeleton passes through to DateFormat', () {
      final out = generate({'when': '{when, date, yMMMd}'});
      expect(out, contains("DateFormat('yMMMd', locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()).format(when)"));
    });

    test('time medium uses DateFormat.jms', () {
      final out = generate({'at': '{at, time, medium}'});
      expect(out, contains("DateFormat.jms(locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()).format(at)"));
    });
  });

  group('LocaleGenFlutterGenerator duration support', () {
    final mfParams = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    test('emits _formatDuration helper when duration is used', () {
      final defaults = <String, dynamic>{'race': '{d, duration}'};
      final out = generator.createLocalizationFile(mfParams, defaults, {'en': defaults});
      expect(out, contains('String _formatDuration(Duration d, String? style)'));
      expect(out, contains('String race({required Duration d})'));
      expect(out, contains('_formatDuration(d, null)'));
    });

    test('does not emit _formatDuration when duration is not used', () {
      final defaults = <String, dynamic>{'plain': 'hello'};
      final out = generator.createLocalizationFile(mfParams, defaults, {'en': defaults});
      expect(out, isNot(contains('_formatDuration')));
    });

    test('custom duration pattern is passed through to _formatDuration', () {
      final defaults = <String, dynamic>{'race': '{d, duration, mm:ss}'};
      final out = generator.createLocalizationFile(mfParams, defaults, {'en': defaults});
      expect(out, contains("_formatDuration(d, 'mm:ss')"));
    });
  });

  group('LocaleGenFlutterGenerator cross-locale validation', () {
    final mfParams = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
''');
    final generator = LocaleGenFlutterGenerator();

    String captureGenerate(Map<String, Map<String, dynamic>> all) {
      final buf = StringBuffer();
      runZoned(
        () => generator.createLocalizationFile(mfParams, all['en']!, all),
        zoneSpecification: ZoneSpecification(
          print: (_, __, ___, line) => buf.writeln(line),
        ),
      );
      return buf.toString();
    }

    test('warns when nl uses a different placeholder name than en', () {
      final printed = captureGenerate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {naam}!'},
      });
      expect(printed, contains('greeting'));
      expect(printed, contains('"nl"'));
    });

    test('does not warn when locales agree', () {
      final printed = captureGenerate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {name}!'},
      });
      expect(printed, isNot(contains('Warning')));
    });
  });
}
