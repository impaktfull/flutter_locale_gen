import 'package:locale_gen/src/model/locale_gen_type.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleGenOutputType.fromString', () {
    test('reads dart', () {
      expect(LocaleGenOutputType.fromString('dart'), LocaleGenOutputType.dart);
    });

    test('reads flutter', () {
      expect(LocaleGenOutputType.fromString('flutter'),
          LocaleGenOutputType.flutter);
    });

    test('falls back to flutter for a missing or unknown value', () {
      expect(LocaleGenOutputType.fromString(null), LocaleGenOutputType.flutter);
      expect(
          LocaleGenOutputType.fromString('web'), LocaleGenOutputType.flutter);
    });
  });

  test('defaults to flutter', () {
    expect(LocaleGenOutputType.defaultValue, LocaleGenOutputType.flutter);
  });
}
