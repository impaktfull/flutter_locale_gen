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
}
