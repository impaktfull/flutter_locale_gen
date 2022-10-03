import 'package:locale_gen/src/extensions/null_extension.dart';
import 'package:locale_gen/src/plural.dart';

import 'case_util.dart';

class TranslationWriter {
  static final positionalFormatRegex = RegExp(r'\%(\d*)\$[\\.]?[\d+]*([sdf])');
  static final normalFormatRegex = RegExp(r'\%[\\.]?[\d+]*([sdf])');
  static const REGEX_INDEX_GROUP_INDEX = 1;
  static const REGEX_TYPE_GROUP_INDEX = 2;
  static const NORMAL_REGEX_TYPE_GROUP_INDEX = 1;

  const TranslationWriter._();

  static void buildTranslationFunction(
      StringBuffer sb, String key, dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      _buildDefaultFunction(sb, key);
      return;
    }
    try {
      final Map<int, String> arguments;
      Plural? plural;

      // Plural
      if (value is Map<String, dynamic>) {
        if (value['other'] == null) {
          throw Exception('Other is required for plurals. Key: $key');
        }

        plural = Plural.fromJson(value);
        arguments = {};
        plural.zero?.let((value) =>
            arguments.addAll(_extractParameters(key: key, value: value)));
        plural.one?.let((value) =>
            arguments.addAll(_extractParameters(key: key, value: value)));
        plural.two?.let((value) =>
            arguments.addAll(_extractParameters(key: key, value: value)));
        plural.few?.let((value) =>
            arguments.addAll(_extractParameters(key: key, value: value)));
        plural.many?.let((value) =>
            arguments.addAll(_extractParameters(key: key, value: value)));
        arguments.addAll(_extractParameters(key: key, value: plural.other));
      } else {
        value as String;
        arguments = _extractParameters(key: key, value: value);
      }

      if (arguments.isEmpty) {
        if (plural != null) {
          _buildDefaultPluralFunction(sb, key, plural);
        } else {
          _buildDefaultFunction(sb, key);
        }
      } else {
        if (plural != null) {
          _buildParameterizedPluralFunction(sb, key, plural, arguments);
        } else {
          _buildParameterizedFunction(sb, key, arguments);
        }
      }
    } on Exception catch (e) {
      print(e);
      _buildDefaultFunction(sb, key);
    }
  }

  static Map<int, String> _extractParameters(
      {required String key, required String value}) {
    final allPositionalMatched = positionalFormatRegex.allMatches(value);
    final allNormalMatched = normalFormatRegex.allMatches(value);
    if (allPositionalMatched.isNotEmpty && allNormalMatched.isNotEmpty) {
      throw Exception(
          'The translation for key "$key" contains both positional and normal format parameters');
    }
    if (allPositionalMatched.isNotEmpty) {
      return _extractPositionalParameters(key, allPositionalMatched);
    } else if (allNormalMatched.isNotEmpty) {
      return _extractNonPositionalParameters(allNormalMatched);
    }
    return {};
  }

  static Map<int, String> _extractPositionalParameters(
      String key, Iterable<RegExpMatch> matches) {
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

    return Map.fromEntries(entries);
  }

  static Map<int, String> _extractNonPositionalParameters(
      Iterable<RegExpMatch> matches) {
    var index = 1;
    final entries = matches.map((match) =>
        MapEntry(index++, match.group(NORMAL_REGEX_TYPE_GROUP_INDEX)!));
    return Map.fromEntries(entries);
  }

  static void _buildDefaultPluralFunction(
      StringBuffer sb, String key, Plural plural) {
    final camelKey = CaseUtil.getCamelcase(key);
    sb
      ..writeln(
          '  String $camelKey(num count) => _plural(LocalizationKeys.$camelKey, count: count);')
      ..writeln();
  }

  static void _buildParameterizedPluralFunction(StringBuffer sb, String key,
      Plural plural, Map<int, String> indexToReplacement) {
    try {
      final camelKey = CaseUtil.getCamelcase(key);
      final tmpSb = StringBuffer('  String $camelKey(num count, ');

      var iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        final argument = _getArgument(key, match, index);
        tmpSb.write(argument);
        if (iterationIndex++ != indexToReplacement.length - 1) {
          tmpSb.write(', ');
        }
      });
      tmpSb.write(
          ') => _plural(LocalizationKeys.$camelKey, count: count, args: <dynamic>[');
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

  static void _buildParameterizedFunction(
      StringBuffer sb, String key, Map<int, String> indexToReplacement) {
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
      tmpSb.write(') => _t(LocalizationKeys.$camelKey, args: <dynamic>[');
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
      return 'int arg$index';
    } else if (type == 'f') {
      return 'double arg$index';
    }
    throw Exception(
        'Unsupported argument type for $key. Supported types are -> s,d,f. Create a github ticket for support -> https://github.com/vanlooverenkoen/locale_gen/issues');
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
