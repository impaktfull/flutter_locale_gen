enum LocaleGenType {
  flutter,
  dart;

  static const defaultValue = LocaleGenType.flutter;

  static LocaleGenType fromString(String? type) {
    switch (type) {
      case 'dart':
        return LocaleGenType.dart;
      default:
        return LocaleGenType.flutter;
    }
  }
}
