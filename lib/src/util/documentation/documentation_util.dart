import 'package:locale_gen/src/locale_gen_constants.dart';

class DocumentationUtil {
  const DocumentationUtil._();

  static void buildDocumentation(
      StringBuffer sb,
      String key,
      Map<String, Map<String, dynamic>> translations,
      List<String> includedLanguages) {
    if (includedLanguages.isEmpty) return;

    sb.writeln('  /// Translations:');
    for (final language in includedLanguages) {
      final values = translations[language];
      if (values == null) continue;
      final languageFormatted = '$language:'.padRight(4, ' ');
      String? value;
      if (values[key] is String?) {
        value = values[key] as String?;
      } else {
        value = values[key].toString();
      }
      var formattedNewLines =
          value?.toString().replaceAll('\n', '\\n').replaceAll('\r', '\\r');
      formattedNewLines = replaceArgumentDocumentation(formattedNewLines);
      sb
        ..writeln('  ///')
        ..writeln("  /// $languageFormatted **'${formattedNewLines ?? ''}'**");
    }
  }

  static String? replaceArgumentDocumentation(String? value) {
    if (value == null) return null;
    var newValue = value;
    final allMatches =
        LocaleGenConstants.positionalFormatRegex.allMatches(newValue);
    for (final match in allMatches) {
      final index = match.group(LocaleGenConstants.regexIndexGroupIndex);
      final type = match.group(LocaleGenConstants.regexTypeGroupIndex);
      if (type == 's') {
        newValue = newValue.replaceAll('%$index\$$type', '[arg$index string]');
      } else if (type == 'd') {
        newValue = newValue.replaceAll('%$index\$$type', '[arg$index number]');
      }
    }
    return newValue;
  }
}
