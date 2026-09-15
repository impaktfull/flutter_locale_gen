import 'package:locale_gen/src/locale_gen_constants.dart';

enum TranslationStyle { none, sprintf, messageFormat, both }

class TranslationStyleDetector {
  const TranslationStyleDetector._();

  static TranslationStyle detect(String value) {
    final hasSprintf =
        LocaleGenConstants.positionalFormatRegex.hasMatch(value) ||
            LocaleGenConstants.normalFormatRegex.hasMatch(value);
    final hasMessageFormat =
        LocaleGenConstants.messageFormatMarkerRegex.hasMatch(value);
    if (hasSprintf && hasMessageFormat) return TranslationStyle.both;
    if (hasSprintf) return TranslationStyle.sprintf;
    if (hasMessageFormat) return TranslationStyle.messageFormat;
    return TranslationStyle.none;
  }
}
