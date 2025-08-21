enum LocaleGenOutputType {
  flutter,
  dart;

  static const defaultValue = LocaleGenOutputType.flutter;

  static LocaleGenOutputType fromString(String? type) {
    switch (type) {
      case 'dart':
        return LocaleGenOutputType.dart;
      default:
        return LocaleGenOutputType.flutter;
    }
  }
}
