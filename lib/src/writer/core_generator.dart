import 'package:locale_gen/locale_gen.dart';
import 'package:locale_gen/src/extensions/null_extensions.dart';
import 'package:locale_gen/src/locale_gen_constants.dart';
import 'package:locale_gen/src/model/plural.dart';
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';
import 'package:locale_gen/src/util/parser/message_format_param_extractor.dart';
import 'package:locale_gen/src/util/parser/translation_style_detector.dart';
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
      // JSON-object plural — unchanged path.
      if (value is Map<String, dynamic>) {
        if (value['other'] == null) {
          throw Exception('Other is required for plurals. Key: $key');
        }
        final plural = Plural.fromJson(value);
        final arguments = <int, String>{};
        plural.zero?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.one?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.two?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.few?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.many?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        arguments.addAll(_extractParameters(key: key, value: plural.other));
        if (arguments.isEmpty) {
          buildDefaultPluralFunction(sb, params, key, plural, allTranslations);
        } else {
          buildParameterizedPluralFunction(
              sb, params, key, plural, arguments, allTranslations);
        }
        return;
      }

      // String value — choose between sprintf and MessageFormat per detection.
      value as String;
      final style = TranslationStyleDetector.detect(value);

      if (style == TranslationStyle.both) {
        print(
            '[locale_gen] Warning: key "$key" contains both sprintf and MessageFormat markers; falling back to default getter.');
        buildDefaultFunction(sb, params, key, allTranslations);
        return;
      }

      if (params.messageFormatStrict && style == TranslationStyle.sprintf) {
        print(
            '[locale_gen] Warning: key "$key" uses sprintf markers but messageFormatStrict is enabled; falling back to default getter.');
        buildDefaultFunction(sb, params, key, allTranslations);
        return;
      }

      if (style == TranslationStyle.messageFormat) {
        try {
          final ast = MessageFormatParser.parse(value);
          final mfParams = MessageFormatParamExtractor.extract(ast);
          buildMessageFormatFunction(
              sb, params, key, ast, mfParams, allTranslations);
        } on MessageFormatParseException catch (e) {
          print('[locale_gen] Warning: key "$key" failed to parse as '
              'MessageFormat: ${e.message}. Falling back to default getter.');
          buildDefaultFunction(sb, params, key, allTranslations);
        } on MessageFormatParamConflictException catch (e) {
          print('[locale_gen] Warning: key "$key" — ${e.message}. Falling back to default getter.');
          buildDefaultFunction(sb, params, key, allTranslations);
        }
        return;
      }

      // Sprintf path — unchanged.
      final arguments = _extractParameters(key: key, value: value);
      if (arguments.isEmpty) {
        buildDefaultFunction(sb, params, key, allTranslations);
      } else {
        buildParameterizedFunction(
            sb, params, key, arguments, allTranslations);
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

  @protected
  void buildMessageFormatFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    MessageFormatAst ast,
    Map<String, MessageFormatParam> mfParams,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    // Default: subclasses without MessageFormat support fall back.
    buildDefaultFunction(sb, params, key, allTranslations);
  }

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
