import 'package:locale_gen/src/locale_gen_constants.dart';
import 'package:test/test.dart';

void main() {
  group('positionalFormatRegex', () {
    test('captures the index and the type', () {
      final match =
          LocaleGenConstants.positionalFormatRegex.firstMatch(r'Paid %2$.02f')!;
      expect(match.group(LocaleGenConstants.regexIndexGroupIndex), '2');
      expect(match.group(LocaleGenConstants.regexTypeGroupIndex), 'f');
    });

    test('only matches s, d and f', () {
      expect(
          LocaleGenConstants.positionalFormatRegex.hasMatch(r'%1$x'), isFalse);
    });
  });

  group('normalFormatRegex', () {
    test('captures the type', () {
      final matches = LocaleGenConstants.normalFormatRegex
          .allMatches('%s paid %.2f for %d')
          .map((m) => m.group(LocaleGenConstants.normalRegexTypeGroupIndex));
      expect(matches, ['s', 'f', 'd']);
    });
  });

  group('messageFormatMarkerRegex', () {
    for (final marker in ['{name}', "'{'", "'}'", "It''s"]) {
      test('matches $marker', () {
        expect(LocaleGenConstants.messageFormatMarkerRegex.hasMatch(marker),
            isTrue);
      });
    }

    for (final text in ['Step {1}', "It's", 'Plain text']) {
      test('does not match $text', () {
        expect(LocaleGenConstants.messageFormatMarkerRegex.hasMatch(text),
            isFalse);
      });
    }
  });
}
