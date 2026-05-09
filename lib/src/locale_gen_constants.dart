class LocaleGenConstants {
  const LocaleGenConstants._();

  static final positionalFormatRegex = RegExp(r'\%(\d*)\$[\\.]?[\d+]*([sdf])');
  static final normalFormatRegex = RegExp(r'\%[\\.]?[\d+]*([sdf])');
  static const regexIndexGroupIndex = 1;
  static const regexTypeGroupIndex = 2;
  static const normalRegexTypeGroupIndex = 1;

  /// Matches an unescaped `{` that begins an ICU placeholder, OR an ICU escape
  /// sequence (`'{'`, `'}'`, `''`). Used to detect whether a translation is
  /// MessageFormat-aware vs sprintf-only.
  static final messageFormatMarkerRegex =
      RegExp(r"(\{[A-Za-z_])|('\{')|('\}')|('')");
}
