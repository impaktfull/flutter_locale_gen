import 'package:intl/locale.dart';

class LocaleGenParser {
  const LocaleGenParser._();

  static String parseSupportedLocale(String language) {
    final locale = Locale.tryParse(language);
    if (locale == null) {
      return "    Locale('$language'),";
    }
    final languageCode = locale.languageCode;
    final scriptCode = locale.scriptCode;
    final countryCode = locale.countryCode;
    return "    Locale.fromSubtags(languageCode: '$languageCode', scriptCode: ${scriptCode != null ? "'$scriptCode'" : null}, countryCode: ${countryCode != null ? "'$countryCode'" : null}),";
  }

  static String parseDefaultLanguageLocale(String language) {
    final locale = Locale.tryParse(language);
    if (locale == null) {
      return "  static const defaultLocale = Locale('$language');";
    }
    final languageCode = locale.languageCode;
    final scriptCode = locale.scriptCode;
    final countryCode = locale.countryCode;
    return "  static const defaultLocale = Locale.fromSubtags(languageCode: '$languageCode', scriptCode: ${scriptCode != null ? "'$scriptCode'" : null}, countryCode: ${countryCode != null ? "'$countryCode'" : null});";
  }
}
