import 'package:locale_gen/src/util/parser/locale_gen_parser.dart';
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
    test('parses non existing locale', () {
      final result = LocaleGenParser.parseSupportedLocale(
          ' flijasdf saodfip3e 45768sdfafasof helloworldhi');
      expect(result,
          "    Locale(' flijasdf saodfip3e 45768sdfafasof helloworldhi'),");
    });
  });
  group('LocaleGen parseDefaultLanguageLocale', () {
    test('parses nl locale', () {
      final result = LocaleGenParser.parseDefaultLanguageLocale('nl');
      expect(result,
          "  static const defaultLocale = Locale.fromSubtags(languageCode: 'nl', scriptCode: null, countryCode: null);");
    });
    test('parses zh-Hans-CN locale', () {
      final result = LocaleGenParser.parseDefaultLanguageLocale('zh-Hans-CN');
      expect(result,
          "  static const defaultLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN');");
    });
    test('parses fi-FI locale', () {
      final result = LocaleGenParser.parseDefaultLanguageLocale('fi-FI');
      expect(result,
          "  static const defaultLocale = Locale.fromSubtags(languageCode: 'fi', scriptCode: null, countryCode: 'FI');");
    });
    test('parses non existing locale', () {
      final result = LocaleGenParser.parseDefaultLanguageLocale(
          ' flijasdf saodfip3e 45768sdfafasof helloworldhi');
      expect(result,
          "  static const defaultLocale = Locale(' flijasdf saodfip3e 45768sdfafasof helloworldhi');");
    });
  });
}
