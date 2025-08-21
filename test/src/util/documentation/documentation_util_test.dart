import 'package:locale_gen/src/util/documentation/documentation_util.dart';
import 'package:test/test.dart';

void main() {
  group('buildDocumentation', () {
    group('Tests without languages', () {
      test('Test null translations', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {}, ['en']);
        expect(sb.toString(), equals('''  /// Translations:
'''));
      });
      test('Test without doc languages', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {}, []);
        expect(sb.toString().length, 0);
      });
      test('Test with translations', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {
          'nl': <String, dynamic>{'app_title': 'Hallo'},
          'en': <String, dynamic>{'app_title': 'Hello'},
          'fr': <String, dynamic>{'app_title': 'Bonjour'},
        }, [
          'nl',
          'en',
          'fr'
        ]);
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// nl:  **'Hallo'**
  ///
  /// en:  **'Hello'**
  ///
  /// fr:  **'Bonjour'**
'''));
      });
      test('Test with translations sub-set', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {
          'nl': <String, dynamic>{'app_title': 'Hallo'},
          'en': <String, dynamic>{'app_title': 'Hello'},
          'fr': <String, dynamic>{'app_title': 'Bonjour'},
        }, [
          'en',
          'fr'
        ]);
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// en:  **'Hello'**
  ///
  /// fr:  **'Bonjour'**
'''));
      });
      test('Test with translations sub-set unknown', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {
          'nl': <String, dynamic>{'app_title': 'Hallo'},
          'en': <String, dynamic>{'app_title': 'Hello'},
          'fr': <String, dynamic>{'app_title': 'Bonjour'},
        }, [
          'en',
          'fr',
          'de'
        ]);
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// en:  **'Hello'**
  ///
  /// fr:  **'Bonjour'**
'''));
      });
      test('Test with translations with multi lines with \n', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {
          'nl': <String, dynamic>{'app_title': 'Hallo\nAlles Goed'},
          'en': <String, dynamic>{'app_title': 'Hi There\nEverything alright'},
        }, [
          'nl',
          'en',
        ]);
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// nl:  **'Hallo\\nAlles Goed'**
  ///
  /// en:  **'Hi There\\nEverything alright'**
'''));
      });
      test('Test with translations with double multi lines with \n', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {
          'nl': <String, dynamic>{'app_title': 'Hallo\n\nAlles goed'},
          'en': <String, dynamic>{
            'app_title': 'Hi There\n\nEverything alright'
          },
        }, [
          'nl',
          'en',
        ]);
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// nl:  **'Hallo\\n\\nAlles goed'**
  ///
  /// en:  **'Hi There\\n\\nEverything alright'**
'''));
      });

      test('Test with translations with double multi lines with \r', () {
        final sb = StringBuffer();
        DocumentationUtil.buildDocumentation(sb, 'app_title', {
          'nl': <String, dynamic>{'app_title': 'Hallo\r\rAlles goed'},
          'en': <String, dynamic>{
            'app_title': 'Hi There\r\rEverything alright'
          },
        }, [
          'nl',
          'en',
        ]);
        expect(sb.toString(), equals('''  /// Translations:
  ///
  /// nl:  **'Hallo\\r\\rAlles goed'**
  ///
  /// en:  **'Hi There\\r\\rEverything alright'**
'''));
      });
    });
  });

  group('replaceArgumentDocumentation', () {
    test('Test replaceArgumentDocumentation with empty string', () {
      final result = DocumentationUtil.replaceArgumentDocumentation('');
      expect(result, '');
    });
    test('Test replaceArgumentDocumentation with null', () {
      final result = DocumentationUtil.replaceArgumentDocumentation(null);
      expect(result, null);
    });
    test('Test replaceArgumentDocumentation with null', () {
      final result = DocumentationUtil.replaceArgumentDocumentation(null);
      expect(result, null);
    });
    test('Test replaceArgumentDocumentation with %1\$s', () {
      final result =
          DocumentationUtil.replaceArgumentDocumentation('Simple test %1\$s');
      expect(result, 'Simple test [arg1 string]');
    });
    test('Test replaceArgumentDocumentation with 2 %1\$s', () {
      final result = DocumentationUtil.replaceArgumentDocumentation(
          'Double test: %1\$s %1\$s');
      expect(result, 'Double test: [arg1 string] [arg1 string]');
    });
    test('Test replaceArgumentDocumentation with %1\$d', () {
      final result =
          DocumentationUtil.replaceArgumentDocumentation('Test with %1\$d');
      expect(result, 'Test with [arg1 number]');
    });
    test('Test replaceArgumentDocumentation with 2 %1\$d', () {
      final result = DocumentationUtil.replaceArgumentDocumentation(
          'Another test with %1\$d and %1\$d');
      expect(result, 'Another test with [arg1 number] and [arg1 number]');
    });
    test('Test replaceArgumentDocumentation with %1\$x', () {
      final result = DocumentationUtil.replaceArgumentDocumentation(
          'Another test with %1\$x and %1\$x');
      expect(result, 'Another test with %1\$x and %1\$x');
    });
  });
}
