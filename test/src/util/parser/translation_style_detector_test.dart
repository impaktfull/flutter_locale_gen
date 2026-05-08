import 'package:locale_gen/src/util/parser/translation_style_detector.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationStyleDetector', () {
    test('plain text → none', () {
      expect(TranslationStyleDetector.detect('hello world'),
          TranslationStyle.none);
    });

    test('contains sprintf %s → sprintf', () {
      expect(TranslationStyleDetector.detect('Hello %s'),
          TranslationStyle.sprintf);
    });

    test('contains sprintf %1\$d → sprintf', () {
      expect(TranslationStyleDetector.detect('Got %1\$d'),
          TranslationStyle.sprintf);
    });

    test('contains ICU placeholder → messageFormat', () {
      expect(TranslationStyleDetector.detect('Hi, {name}!'),
          TranslationStyle.messageFormat);
    });

    test('contains both ICU and sprintf → both', () {
      expect(TranslationStyleDetector.detect('Hello {name}, %s'),
          TranslationStyle.both);
    });

    test('escaped opening brace alone is still messageFormat detection',
        () {
      // '{' is an ICU escape — treat as messageFormat-aware string.
      expect(TranslationStyleDetector.detect("price '{'5}"),
          TranslationStyle.messageFormat);
    });
  });
}
