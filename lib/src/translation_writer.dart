import 'case_util.dart';

class TranslationWriter {
  static final formatRegex = RegExp(r'\%(\d*)\$([a-z])');
  static const REGEX_INDEX_GROUP_INDEX = 1;
  static const REGEX_TYPE_GROUP_INDEX = 2;

  static void buildTranslationFunction(
      StringBuffer sb, String key, String value) {
    if (value == null || value.isEmpty) {
      _buildDefaultFunction(sb, key, value);
      return;
    }
    final allMatched = formatRegex.allMatches(value);
    if (allMatched == null || allMatched.isEmpty) {
      _buildDefaultFunction(sb, key, value);
      return;
    }
    try {
      final camelKey = CaseUtil.getCamelcase(key);
      final tmpSb = StringBuffer('  String $camelKey(');

      final validMatcher = List<RegExpMatch>();
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
      tmpSb.write(') => _t(LocalizationKeys.$camelKey, args: [');
      validMatcher.asMap().forEach((index, match) {
        if (index != 0) {
          tmpSb.write(', ');
        }
        tmpSb.write('arg${match.group(REGEX_INDEX_GROUP_INDEX)}');
      });
      tmpSb..writeln(']);')..writeln();
      sb.write(tmpSb.toString());
    } on Exception catch (e) {
      print(e);
      _buildDefaultFunction(sb, key, value);
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
        'Unsupported argument type for $key. Supported types are -> s,d. Create a github ticket for support -> https://github.com/icapps/flutter-icapps-translations/issues');
  }

  static void _buildDefaultFunction(StringBuffer sb, String key, String value) {
    final camelCaseKey = CaseUtil.getCamelcase(key);
    sb
      ..writeln(
          '  String get $camelCaseKey => _t(LocalizationKeys.$camelCaseKey);')
      ..writeln();
  }
}
