class LocaleGenConstants {
  const LocaleGenConstants._();

  static final positionalFormatRegex = RegExp(r'\%(\d*)\$[\\.]?[\d+]*([sdf])');
  static final normalFormatRegex = RegExp(r'\%[\\.]?[\d+]*([sdf])');
  static const regexIndexGroupIndex = 1;
  static const regexTypeGroupIndex = 2;
  static const normalRegexTypeGroupIndex = 1;
}
