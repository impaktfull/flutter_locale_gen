import 'package:intl/locale.dart';

class LocaleGenParser {
  const LocaleGenParser._();

  static String parseSupportedLocale(String language) {
    try {
      final locale = Locale.tryParse(language);
      final languageCode = locale?.languageCode;
      final scriptCode = locale?.scriptCode;
      final countryCode = locale?.countryCode;
      return "    Locale.fromSubtags(languageCode: ${languageCode != null ? "'$languageCode'" : null}, scriptCode: ${scriptCode != null ? "'$scriptCode'" : null}, countryCode: ${countryCode != null ? "'$countryCode'" : null}),";
    } catch (_) {
      return "    Locale('$language'),";
    }
  }

  static String parseDefaultLanguageLocale(String language) {
    try {
      final locale = Locale.tryParse(language);
      final languageCode = locale?.languageCode;
      final scriptCode = locale?.scriptCode;
      final countryCode = locale?.countryCode;
      return "  static const defaultLocale = Locale.fromSubtags(languageCode: ${languageCode != null ? "'$languageCode'" : null}, scriptCode: ${scriptCode != null ? "'$scriptCode'" : null}, countryCode: ${countryCode != null ? "'$countryCode'" : null});";
    } catch (_) {
      return "  static const defaultLocale = Locale('$language');";
    }
  }
}
