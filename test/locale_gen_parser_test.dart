import 'package:locale_gen/src/locale_gen_parser.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleGen parseSupportedLocale', () {
    test('parses nl locale', () {
      final result = LocaleGenParser.parseSupportedLocale('nl');
      expect(result,
          "    Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null),");
    });
    test('parses zh-Hans-CN locale', () {
      final result = LocaleGenParser.parseSupportedLocale('zh-Hans-CN');
      expect(result,
          "    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),");
    });
    test('parses fi-FI locale', () {
      final result = LocaleGenParser.parseSupportedLocale('fi-FI');
      expect(result,
          "    Locale.fromSubtags(languageCode: 'fi', scriptCode: null, countryCode: 'FI'),");
    });
  });
}
