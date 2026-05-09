import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';
import 'package:locale_gen/src/util/parser/translation_style_detector.dart';

class CrossLocaleValidator {
  const CrossLocaleValidator._();

  /// Runs cross-locale validation across all MessageFormat keys in
  /// [defaultTranslations] and prints each warning via `print`.
  static void validateAndPrint({
    required LocaleGenParams params,
    required Map<String, dynamic> defaultTranslations,
    required Map<String, Map<String, dynamic>> allTranslations,
  }) {
    defaultTranslations.forEach((key, dynamic value) {
      if (value is! String) return;
      if (TranslationStyleDetector.detect(value) !=
          TranslationStyle.messageFormat) {
        return;
      }
      final others = <String, String>{};
      for (final entry in allTranslations.entries) {
        if (entry.key == params.defaultLanguage) continue;
        final v = entry.value[key];
        if (v is String) others[entry.key] = v;
      }
      final warnings = validateKey(
        key: key,
        defaultLanguage: params.defaultLanguage,
        defaultValue: value,
        otherLocales: others,
      );
      for (final w in warnings) {
        print(w);
      }
    });
  }

  static List<String> validateKey({
    required String key,
    required String defaultLanguage,
    required String defaultValue,
    required Map<String, String> otherLocales,
  }) {
    final warnings = <String>[];
    final MessageFormatAst defaultAst;
    try {
      defaultAst = MessageFormatParser.parse(defaultValue);
    } on MessageFormatParseException {
      // The default itself is malformed — handled elsewhere with its own warning.
      return warnings;
    }
    final defaultNodes = _collectNamedNodes(defaultAst);

    for (final entry in otherLocales.entries) {
      final locale = entry.key;
      final value = entry.value;
      MessageFormatAst ast;
      try {
        ast = MessageFormatParser.parse(value);
      } on MessageFormatParseException catch (e) {
        warnings.add(
            '[locale_gen] Warning: key "$key" — locale "$locale" failed to parse as MessageFormat: ${e.message}.');
        continue;
      }
      final localeNodes = _collectNamedNodes(ast);

      final missing =
          defaultNodes.keys.toSet().difference(localeNodes.keys.toSet());
      final extra =
          localeNodes.keys.toSet().difference(defaultNodes.keys.toSet());
      if (missing.isNotEmpty || extra.isNotEmpty) {
        final defaultNames = defaultNodes.keys.toList()..sort();
        final localeNames = localeNodes.keys.toList()..sort();
        warnings.add(
            '[locale_gen] Warning: key "$key" — locale "$locale" uses params $localeNames; '
            'default language "$defaultLanguage" uses $defaultNames. '
            'The translated string must use the same placeholder names as the default language.');
        continue;
      }

      for (final name in defaultNodes.keys) {
        final defaultKind = _kindOf(defaultNodes[name]!);
        final localeKind = _kindOf(localeNodes[name]!);
        if (defaultKind != localeKind) {
          warnings.add(
              '[locale_gen] Warning: key "$key" — locale "$locale" uses $localeKind for "$name"; '
              'default language "$defaultLanguage" uses $defaultKind. '
              'The ICU type must match across locales.');
        }
      }
    }

    return warnings;
  }

  static Map<String, MessageFormatNode> _collectNamedNodes(
      MessageFormatAst ast) {
    final result = <String, MessageFormatNode>{};
    void visit(MessageFormatNode node) {
      switch (node) {
        case LiteralNode():
          break;
        case PlaceholderNode(:final name):
          result[name] ??= node;
        case PluralNode(:final name, :final branches):
          result[name] ??= node;
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case SelectOrdinalNode(:final name, :final branches):
          result[name] ??= node;
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case SelectNode(:final name, :final branches):
          result[name] ??= node;
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case NumberNode(:final name):
          result[name] ??= node;
        case DateNode(:final name):
          result[name] ??= node;
        case TimeNode(:final name):
          result[name] ??= node;
        case DurationNode(:final name):
          result[name] ??= node;
      }
    }

    for (final n in ast.roots) {
      visit(n);
    }
    return result;
  }

  static String _kindOf(MessageFormatNode node) {
    return switch (node) {
      LiteralNode() => 'literal',
      PlaceholderNode() => 'placeholder',
      PluralNode() => 'plural',
      SelectOrdinalNode() => 'selectordinal',
      SelectNode() => 'select',
      NumberNode() => 'number',
      DateNode() => 'date',
      TimeNode() => 'time',
      DurationNode() => 'duration',
    };
  }
}
