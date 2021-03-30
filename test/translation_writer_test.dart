import 'package:flutter_test/flutter_test.dart';
import 'package:locale_gen/src/translation_writer.dart';

void main() {
  group('buildTranslationFunction', () {
    group('Tests without arguments', () {
      test('Test null translations', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', null);
        expect(sb.toString(), equals('  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
      test('Test empty translations', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', '');
        expect(sb.toString(), equals('  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
      test('Test translations without arguments', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo');
        expect(sb.toString(), equals('  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
    });

    group('Tests with string arguments', () {
      test('Test translations with 1 string argument', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s');
        expect(sb.toString(), equals('  String appTitle(String arg1) => _t(LocalizationKeys.appTitle, args: [arg1]);\n\n'));
      });

      test('Test translations with 2 string arguments', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %2\$s');
        expect(sb.toString(), equals('  String appTitle(String arg1, String arg2) => _t(LocalizationKeys.appTitle, args: [arg1, arg2]);\n\n'));
      });

      test('Test translations with 1 string argument but 2 string replacements', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %1\$s');
        expect(sb.toString(), equals('  String appTitle(String arg1) => _t(LocalizationKeys.appTitle, args: [arg1]);\n\n'));
      });

      test('Test translations with 11 arguments of the same index and same type', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s');
        expect(sb.toString(), equals('  String appTitle(String arg1) => _t(LocalizationKeys.appTitle, args: [arg1]);\n\n'));
      });
    });

    group('Tests with number arguments', () {
      test('Test translations with 1 number argument', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$d');
        expect(sb.toString(), equals('  String appTitle(num arg1) => _t(LocalizationKeys.appTitle, args: [arg1]);\n\n'));
      });

      test('Test translations with 2 number arguments', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$d %2\$d');
        expect(sb.toString(), equals('  String appTitle(num arg1, num arg2) => _t(LocalizationKeys.appTitle, args: [arg1, arg2]);\n\n'));
      });

      test('Test translations with 1 number argument but 2 number replacements', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$d %1\$d');
        expect(sb.toString(), equals('  String appTitle(num arg1) => _t(LocalizationKeys.appTitle, args: [arg1]);\n\n'));
      });

      test('Test translations with 11 arguments of the same index and same type', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d %1\$d');
        expect(sb.toString(), equals('  String appTitle(num arg1) => _t(LocalizationKeys.appTitle, args: [arg1]);\n\n'));
      });
    });

    group('Tests with mixed arguments', () {
      test('Test translations with 1 number argument', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %2\$d');
        expect(sb.toString(), equals('  String appTitle(String arg1, num arg2) => _t(LocalizationKeys.appTitle, args: [arg1, arg2]);\n\n'));
      });

      test('Test translations with 11 arguments of the same index and same type', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %1\$s %2\$d');
        expect(sb.toString(), equals('  String appTitle(String arg1, num arg2) => _t(LocalizationKeys.appTitle, args: [arg1, arg2]);\n\n'));
      });

      test('Test translations with 11 different arguments', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %2\$s %3\$s %4\$s %5\$s %6\$s %7\$s %8\$s %9\$s %10\$s %11\$s');
        expect(
            sb.toString(),
            equals(
                '  String appTitle(String arg1, String arg2, String arg3, String arg4, String arg5, String arg6, String arg7, String arg8, String arg9, String arg10, String arg11) => _t(LocalizationKeys.appTitle, args: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]);\n\n'));
      });
    });

    group('Tests with invalid arguments', () {
      test('Test translations with unsupported type', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$z');
        expect(sb.toString(), equals('  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });

      test('Test translations with 1 number argument', () {
        final sb = StringBuffer();
        TranslationWriter.buildTranslationFunction(sb, 'app_title', 'hallo %1\$s %1\$d');
        expect(sb.toString(), equals('  String get appTitle => _t(LocalizationKeys.appTitle);\n\n'));
      });
    });
  });

  group('buildDocumentation', () {
    group('Tests without languages', () {
      test('Test null translations', () {
        final sb = StringBuffer();
        TranslationWriter.buildDocumentation(sb, 'app_title', {});
        expect(sb.toString(), equals('''  /// Translations:
'''));
      });
      test('Test with translations', () {
        final sb = StringBuffer();
        TranslationWriter.buildDocumentation(sb, 'app_title', {
          'nl': {'app_title': 'Hallo'},
          'en': {'app_title': 'Hello'},
          'fr': {'app_title': 'Bonjour'},
        });
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// nl:  **'Hallo'**
  ///
  /// en:  **'Hello'**
  ///
  /// fr:  **'Bonjour'**
'''));
      });
    });
  });
}
