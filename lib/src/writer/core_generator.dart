import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/extensions/null_extensions.dart';
import 'package:locale_gen/src/locale_gen_constants.dart';
import 'package:locale_gen/src/model/plural.dart';
import 'package:meta/meta.dart';

abstract class LocaleGenCoreGenerator {
  void buildTranslationFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    dynamic value,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    if (value == null || (value is String && value.isEmpty)) {
      buildDefaultFunction(sb, params, key, allTranslations);
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
          buildDefaultPluralFunction(sb, params, key, plural, allTranslations);
        } else {
          buildDefaultFunction(sb, params, key, allTranslations);
        }
      } else {
        if (plural != null) {
          buildParameterizedPluralFunction(
              sb, params, key, plural, arguments, allTranslations);
        } else {
          buildParameterizedFunction(
              sb, params, key, arguments, allTranslations);
        }
      }
    } on Exception catch (e) {
      print(e);
      buildDefaultFunction(sb, params, key, allTranslations);
    }
  }

  @protected
  void buildDefaultFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Map<String, Map<String, dynamic>> allTranslations,
  );

  @protected
  void buildDefaultPluralFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Plural plural,
    Map<String, Map<String, dynamic>> allTranslations,
  );

  @protected
  void buildParameterizedPluralFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Plural plural,
    Map<int, String> arguments,
    Map<String, Map<String, dynamic>> allTranslations,
  );

  @protected
  void buildParameterizedFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Map<int, String> arguments,
    Map<String, Map<String, dynamic>> allTranslations,
  );

  Map<int, String> _extractParameters(
      {required String key, required String value}) {
    final allPositionalMatched =
        LocaleGenConstants.positionalFormatRegex.allMatches(value);
    final allNormalMatched =
        LocaleGenConstants.normalFormatRegex.allMatches(value);
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

  Map<int, String> _extractPositionalParameters(
      String key, Iterable<RegExpMatch> matches) {
    // Validate
    final validMatcher = <RegExpMatch>[];
    for (final match in matches) {
      final sameTypeMatch = validMatcher.where((validMatch) =>
          validMatch.group(LocaleGenConstants.regexIndexGroupIndex) ==
          match.group(LocaleGenConstants.regexIndexGroupIndex));
      if (sameTypeMatch.isNotEmpty &&
          sameTypeMatch.first.group(LocaleGenConstants.regexTypeGroupIndex) !=
              match.group(LocaleGenConstants.regexTypeGroupIndex)) {
        throw Exception(
            '$key contains a value with more than 1 argument with the same index but different type');
      }
      if (validMatcher
          .where((validMatch) => validMatch.group(0) == match.group(0))
          .isEmpty) {
        validMatcher.add(match);
      }
    }
    final entries = validMatcher
        .map((match) => MapEntry(
            int.parse(match.group(LocaleGenConstants.regexIndexGroupIndex)!),
            match.group(LocaleGenConstants.regexTypeGroupIndex)!))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(entries);
  }

  Map<int, String> _extractNonPositionalParameters(
      Iterable<RegExpMatch> matches) {
    var index = 1;
    final entries = matches.map((match) => MapEntry(
        index++, match.group(LocaleGenConstants.normalRegexTypeGroupIndex)!));
    return Map.fromEntries(entries);
  }

  @protected
  String getArgument(String key, String type, int index) {
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
}
