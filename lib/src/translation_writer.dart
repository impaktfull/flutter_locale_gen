import 'case_util.dart';

class TranslationWriter {
  static final positionalFormatRegex = RegExp(r'\%(\d*)\$([sd])');
  static final normalFormatRegex = RegExp(r'\%([sd])');
  static const REGEX_INDEX_GROUP_INDEX = 1;
  static const REGEX_TYPE_GROUP_INDEX = 2;
  static const NORMAL_REGEX_TYPE_GROUP_INDEX = 1;

  const TranslationWriter._();

  static void buildTranslationFunction(
      StringBuffer sb, String key, String? value) {
    if (value == null || value.isEmpty) {
      _buildDefaultFunction(sb, key);
      return;
    }
    final allPositionalMatched = positionalFormatRegex.allMatches(value);
    final allNormalMatched = normalFormatRegex.allMatches(value);
    if (allPositionalMatched.isEmpty && allNormalMatched.isEmpty) {
      _buildDefaultFunction(sb, key);
      return;
    }
    if (allPositionalMatched.isNotEmpty && allNormalMatched.isNotEmpty) {
      print(Exception(
          'The translation for key "$key" contains both positional and normal format parameters'));
      _buildDefaultFunction(sb, key);
      return;
    }

    try {
      if (allPositionalMatched.isNotEmpty) {
        _buildPositionalParameterized(sb, key, value, allPositionalMatched);
      } else {
        _buildNormalParameterized(sb, key, value, allNormalMatched);
      }
    } on Exception catch (e) {
      print(e);
      _buildDefaultFunction(sb, key);
    }
  }

  static void _buildPositionalParameterized(StringBuffer sb, String key,
      String? value, Iterable<RegExpMatch> matches) {
    // Validate
    final validMatcher = <RegExpMatch>[];
    matches.forEach((match) {
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
    final entries = validMatcher
        .map((match) => MapEntry(
            int.parse(match.group(REGEX_INDEX_GROUP_INDEX)!),
            match.group(REGEX_TYPE_GROUP_INDEX)!))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final indexToReplacement = Map.fromEntries(entries);

    _buildParameterizedFunction(sb, key, value, indexToReplacement, '_t');
  }

  static void _buildNormalParameterized(StringBuffer sb, String key,
      String? value, Iterable<RegExpMatch> matches) {
    var index = 1;
    final entries = matches.map((match) =>
        MapEntry(index++, match.group(NORMAL_REGEX_TYPE_GROUP_INDEX)!));
    final indexToReplacement = Map.fromEntries(entries);

    _buildParameterizedFunction(
        sb, key, value, indexToReplacement, '_nonPositionalT');
  }

  static void _buildParameterizedFunction(StringBuffer sb, String key,
      String? value, Map<int, String> indexToReplacement, String functionName) {
    try {
      final camelKey = CaseUtil.getCamelcase(key);
      final tmpSb = StringBuffer('  String $camelKey(');

      var iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        final argument = _getArgument(key, match, index);
        tmpSb.write(argument);
        if (iterationIndex++ != indexToReplacement.length - 1) {
          tmpSb.write(', ');
        }
      });
      tmpSb.write(
          ') => $functionName(LocalizationKeys.$camelKey, args: <dynamic>[');
      iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        if (iterationIndex++ != 0) {
          tmpSb.write(', ');
        }
        tmpSb.write('arg$index');
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

  static String _getArgument(String key, String type, int index) {
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
    final allMatches = positionalFormatRegex.allMatches(newValue);
    for (final match in allMatches) {
      final index = match.group(REGEX_INDEX_GROUP_INDEX);
      final type = match.group(REGEX_TYPE_GROUP_INDEX);
      if (type == 's') {
        newValue = newValue.replaceAll('%$index\$$type', '[arg$index string]');
      } else if (type == 'd') {
        newValue = newValue.replaceAll('%$index\$$type', '[arg$index number]');
      }
    }
    return newValue;
  }
}
