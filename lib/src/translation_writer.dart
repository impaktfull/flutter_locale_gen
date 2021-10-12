import 'case_util.dart';

class TranslationWriter {
  static final formatRegex = RegExp(r'\%(\d*)\$([a-z])');
  static const REGEX_INDEX_GROUP_INDEX = 1;
  static const REGEX_TYPE_GROUP_INDEX = 2;

  static void buildTranslationFunction(
      StringBuffer sb, String key, String? value) {
    if (value == null || value.isEmpty) {
      _buildDefaultFunction(sb, key);
      return;
    }
    final allMatched = formatRegex.allMatches(value);
    if (allMatched.isEmpty) {
      _buildDefaultFunction(sb, key);
      return;
    }
    try {
      final camelKey = CaseUtil.getCamelcase(key);
      final tmpSb = StringBuffer('  String $camelKey(');

      final validMatcher = <RegExpMatch>[];
      allMatched.forEach((match) {
        final sameTypeMatch = validMatcher.where((validMatch) =>
            validMatch.group(REGEX_INDEX_GROUP_INDEX) ==
            match.group(REGEX_INDEX_GROUP_INDEX));
        if (sameTypeMatch.isNotEmpty &&
            sameTypeMatch.first.group(REGEX_TYPE_GROUP_INDEX) !=
                match.group(REGEX_TYPE_GROUP_INDEX)) {
          throw Exception(
              '$key contains a value with more than 1 argument with the same index but different type');
        }
        if (validMatcher
            .where((validMatch) => validMatch.group(0) == match.group(0))
            .isEmpty) {
          validMatcher.add(match);
        }
      });

      validMatcher.asMap().forEach((index, match) {
        final argument = _getArgument(key, match);
        tmpSb.write(argument);
        if (index != validMatcher.length - 1) {
          tmpSb.write(', ');
        }
      });
      tmpSb.write(') => _t(LocalizationKeys.$camelKey, args: <dynamic>[');
      validMatcher.asMap().forEach((index, match) {
        if (index != 0) {
          tmpSb.write(', ');
        }
        tmpSb.write('arg${match.group(REGEX_INDEX_GROUP_INDEX)}');
      });
      tmpSb
        ..writeln(']);')
        ..writeln();
      sb.write(tmpSb.toString());
    } on Exception catch (e) {
      print(e);
      _buildDefaultFunction(sb, key);
    }
  }

  static String _getArgument(String key, RegExpMatch match) {
    final index = match.group(REGEX_INDEX_GROUP_INDEX);
    final type = match.group(REGEX_TYPE_GROUP_INDEX);
    if (type == 's') {
      return 'String arg$index';
    } else if (type == 'd') {
      return 'num arg$index';
    }
    throw Exception(
        'Unsupported argument type for $key. Supported types are -> s,d. Create a github ticket for support -> https://github.com/vanlooverenkoen/locale_gen/issues');
  }

  static void _buildDefaultFunction(StringBuffer sb, String key) {
    final camelCaseKey = CaseUtil.getCamelcase(key);
    sb
      ..writeln(
          '  String get $camelCaseKey => _t(LocalizationKeys.$camelCaseKey);')
      ..writeln();
  }

  static void buildDocumentation(
      StringBuffer sb,
      String key,
      Map<String, Map<String, dynamic>> translations,
      List<String> includedLanguages) {
    if (includedLanguages.isEmpty) return;

    sb.writeln('  /// Translations:');
    includedLanguages.forEach((language) {
      final values = translations[language];
      if (values == null) return;
      final languageFormatted = '$language:'.padRight(4, ' ');
      final value = values[key];
      var formattedNewLines =
          value?.toString().replaceAll('\n', '\\n').replaceAll('\r', '\\r');
      formattedNewLines = replaceArgumentDocumentation(formattedNewLines);
      sb
        ..writeln('  ///')
        ..writeln("  /// $languageFormatted **'${formattedNewLines ?? ''}'**");
    });
  }

  static String? replaceArgumentDocumentation(String? value) {
    if (value == null) return null;
    var newValue = value;
    formatRegex.allMatches(newValue).forEach((match) {
      final index = match.group(REGEX_INDEX_GROUP_INDEX);
      final type = match.group(REGEX_TYPE_GROUP_INDEX);
      if (type == 's') {
        newValue = newValue.replaceAll('%$index\$$type', '[arg$index string]');
      } else if (type == 'd') {
        newValue = newValue.replaceAll('%$index\$$type', '[arg$index number]');
      } else {
      }
      throw Exception(
          'Unsupported argument type for $type. Supported types are -> s,d. Create a github ticket for support -> https://github.com/vanlooverenkoen/locale_gen/issues');
    });
    return newValue;
  }
}
