import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/model/plural.dart';
import 'package:locale_gen/src/util/case/case_util.dart';
import 'package:locale_gen/src/util/documentation/documentation_util.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';
import 'package:locale_gen/src/util/parser/translation_style_detector.dart';
import 'package:locale_gen/src/util/validation/cross_locale_validator.dart';
import 'package:locale_gen/src/util/format/message_format_util.dart';
import 'package:locale_gen/src/writer/core_generator.dart';

class LocaleGenDartGenerator extends LocaleGenCoreGenerator {
  String createLocalizationFile(
      LocaleGenParams params,
      Map<String, dynamic> defaultTranslations,
      Map<String, Map<String, dynamic>> allTranslations) {
    final hasPlurals = defaultTranslations.values
        .any((dynamic element) => element is Map<String, dynamic>);
    if (hasPlurals) {
      throw Exception('Plurals are not supported for `dart` writer');
    }

    final hasMessageFormat = defaultTranslations.values.whereType<String>().any(
        (v) =>
            TranslationStyleDetector.detect(v) ==
            TranslationStyle.messageFormat);

    final hasDuration = defaultTranslations.values.whereType<String>().any((v) {
      if (TranslationStyleDetector.detect(v) !=
          TranslationStyle.messageFormat) {
        return false;
      }
      try {
        final ast = MessageFormatParser.parse(v);
        return messageFormatAstContainsDuration(ast);
      } on MessageFormatParseException {
        return false;
      }
    });

    if (hasMessageFormat) {
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
        final warnings = CrossLocaleValidator.validateKey(
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

    final sb = StringBuffer();
    [
      if (hasMessageFormat) ...["import 'package:intl/intl.dart';"],
      if (hasMessageFormat) ...["import 'package:intl/message_format.dart';"],
      "import 'package:sprintf/sprintf.dart';",
    ]
      ..sort((i1, i2) => i1.compareTo(i2))
      ..forEach(sb.writeln);
    sb
      ..writeln()
      ..writeln(
          '//============================================================//')
      ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
      ..writeln(
          '//============================================================//')
      ..writeln()
      ..writeln('class LocalizedValue {');
    for (final locale in params.languages) {
      final variableName = locale.replaceAll('-', '');
      sb.writeln('  final String $variableName;');
    }
    sb
      ..writeln()
      ..writeln('  LocalizedValue({');
    for (final locale in params.languages) {
      final variableName = locale.replaceAll('-', '');
      sb.writeln('    required this.$variableName,');
    }
    sb
      ..writeln('  });')
      ..writeln('}')
      ..writeln()
      ..writeln('class Localization {')
      ..writeln('  static Localization? _instance;')
      ..writeln()
      ..writeln(
          '  static Localization get instance => _instance ??= Localization._();')
      ..writeln()
      ..writeln('  Localization._();')
      ..writeln()
      ..writeln('  String _t(String value, {List<dynamic>? args}) {')
      ..writeln('    try {')
      ..writeln('      if (args == null || args.isEmpty) return value;')
      ..writeln('      return sprintf(value, args);')
      ..writeln('    } catch (e) {')
      ..writeln("      return '⚠\$value⚠';")
      ..writeln('    }')
      ..writeln('  }')
      ..writeln();
    if (hasMessageFormat) {
      sb
        ..writeln(
            '  String _mf(String template, {required Map<String, Object> args, required String locale}) {')
        ..writeln('    try {')
        ..writeln('      final stripped = _stripFormatSpecs(template);')
        ..writeln(
            '      return MessageFormat(stripped, locale: locale).format(args);')
        ..writeln('    } catch (e) {')
        ..writeln("      return '⚠\$template⚠';")
        ..writeln('    }')
        ..writeln('  }')
        ..writeln()
        ..writeln('  String _stripFormatSpecs(String value) {')
        ..writeln(
            "    final regex = RegExp(r'\\{(\\w+)\\s*,\\s*(number|date|time|duration)(\\s*,[^{}]*)?\\}');")
        ..writeln(
            "    return value.replaceAllMapped(regex, (m) => '{\${m.group(1)}}');")
        ..writeln('  }')
        ..writeln();
    }
    if (hasDuration) {
      sb
        ..write(messageFormatDurationHelperTemplate)
        ..writeln();
    }
    defaultTranslations.forEach((key, dynamic value) {
      DocumentationUtil.buildDocumentation(
          sb, key, allTranslations, params.docLanguages);
      buildTranslationFunction(sb, params, key, value, allTranslations);
    });
    sb.writeln('}');
    return sb.toString();
  }

  @override
  void buildDefaultFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final camelCaseKey = CaseUtil.getCamelcase(key);
    sb.writeln('  LocalizedValue get $camelCaseKey => LocalizedValue(');
    for (final locale in params.languages) {
      final localeTranslations = allTranslations[locale];
      if (localeTranslations == null) {
        throw Exception(
            'Locale $locale not found in allTranslations for key $key');
      }
      final value = localeTranslations[key];
      if (value == null) {
        throw Exception(
            'Key $key not found in locale $locale for allTranslations');
      }
      final variableName = locale.replaceAll('-', '');
      final escapedValue = value
          .toString()
          .replaceAll(r'\', r'\\')
          .replaceAll('\n', r'\n')
          .replaceAll('\r', r'\r')
          .replaceAll('"', r'\"')
          .replaceAll('\$', r'\$');
      sb.writeln('    $variableName: _t("$escapedValue"),');
    }
    sb
      ..writeln('  );')
      ..writeln();
  }

  @override
  void buildParameterizedFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Map<int, String> indexToReplacement,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final camelCaseKey = CaseUtil.getCamelcase(key);
    sb.write('  LocalizedValue $camelCaseKey(');
    var iterationIndex = 0;
    indexToReplacement.forEach((index, match) {
      final argument = getArgument(key, match, index);
      sb.write(argument);
      if (iterationIndex++ != indexToReplacement.length - 1) {
        sb.write(', ');
      }
    });
    sb.writeln(') => LocalizedValue(');
    for (final locale in params.languages) {
      final localeTranslations = allTranslations[locale];
      if (localeTranslations == null) {
        throw Exception(
            'Locale $locale not found in allTranslations for key $key');
      }
      final value = localeTranslations[key];
      if (value == null) {
        throw Exception(
            'Key $key not found in locale $locale for allTranslations');
      }
      final variableName = locale.replaceAll('-', '');
      final escapedValue = _getEscapedValue(value);
      sb.write('    $variableName: _t("$escapedValue", args: <dynamic> [');
      iterationIndex = 0;
      indexToReplacement.forEach((index, match) {
        if (iterationIndex++ != 0) {
          sb.write(', ');
        }
        sb.write('arg$index');
      });
      sb.writeln(']),');
    }
    sb
      ..writeln('  );')
      ..writeln();
  }

  String _getEscapedValue(value) => value
      .toString()
      .replaceAll(r'\', r'\\')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('"', r'\"')
      .replaceAll('\$', r'\$');

  @override
  void buildDefaultPluralFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Plural plural,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    throw ArgumentError('Plurals are not supported for `dart` writer');
  }

  @override
  void buildParameterizedPluralFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    Plural plural,
    Map<int, String> arguments,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    throw ArgumentError('Plurals are not supported for `dart` writer');
  }

  @override
  void buildMessageFormatFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    MessageFormatAst ast,
    Map<String, MessageFormatParam> mfParams,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final camelKey = CaseUtil.getCamelcase(key);
    final paramSignatures = mfParams.values
        .map((p) =>
            'required ${dartTypeForMessageFormatParam(p.dartType)} ${p.dartName}')
        .join(', ');
    if (mfParams.isEmpty) {
      sb.writeln('  LocalizedValue get $camelKey => LocalizedValue(');
    } else {
      sb.writeln(
          '  LocalizedValue $camelKey({$paramSignatures}) => LocalizedValue(');
    }
    for (final locale in params.languages) {
      final variableName = locale.replaceAll('-', '');
      final localeTranslations = allTranslations[locale];
      if (localeTranslations == null) {
        throw Exception(
            'Locale $locale not found in allTranslations for key $key');
      }
      final template = localeTranslations[key];
      if (template is! String) {
        throw Exception(
            'Key $key in locale $locale is not a String for MessageFormat');
      }
      final escapedTemplate = _getEscapedValue(template);
      if (mfParams.isEmpty) {
        sb.writeln(
            '    $variableName: _mf("$escapedTemplate", args: const {}, locale: \'$locale\'),');
      } else {
        final argEntries = mfParams.values
            .map((p) =>
                "'${p.originalName}': ${_argExpressionForLocale(p, locale)}")
            .join(', ');
        sb.writeln(
            '    $variableName: _mf("$escapedTemplate", args: {$argEntries}, locale: \'$locale\'),');
      }
    }
    sb
      ..writeln('  );')
      ..writeln();
  }

  static String _argExpressionForLocale(
      MessageFormatParam p, String localeTag) {
    final tag = "'$localeTag'";
    switch (p.formatter) {
      case MessageFormatFormatter.none:
        return p.dartName;
      case MessageFormatFormatter.numberDecimal:
        return 'NumberFormat.decimalPattern($tag).format(${p.dartName})';
      case MessageFormatFormatter.numberPercent:
        return 'NumberFormat.percentPattern($tag).format(${p.dartName})';
      case MessageFormatFormatter.numberCurrency:
        return 'NumberFormat.simpleCurrency(locale: $tag).format(${p.dartName})';
      case MessageFormatFormatter.numberCustom:
        return "NumberFormat('${escapeForSingleQuotedString(p.formatterStyle ?? '')}', $tag).format(${p.dartName})";
      case MessageFormatFormatter.dateShort:
        return 'DateFormat.yMd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateMedium:
        return 'DateFormat.yMMMd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateLong:
        return 'DateFormat.yMMMMd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateFull:
        return 'DateFormat.yMMMMEEEEd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateCustom:
        return "DateFormat('${escapeForSingleQuotedString(p.formatterStyle ?? '')}', $tag).format(${p.dartName})";
      case MessageFormatFormatter.timeShort:
        return 'DateFormat.jm($tag).format(${p.dartName})';
      case MessageFormatFormatter.timeMedium:
      case MessageFormatFormatter.timeLong:
      case MessageFormatFormatter.timeFull:
        return 'DateFormat.jms($tag).format(${p.dartName})';
      case MessageFormatFormatter.timeCustom:
        return "DateFormat('${escapeForSingleQuotedString(p.formatterStyle ?? '')}', $tag).format(${p.dartName})";
      case MessageFormatFormatter.durationDefault:
      case MessageFormatFormatter.durationMedium:
        return '_formatDuration(${p.dartName}, null)';
      case MessageFormatFormatter.durationShort:
        return "_formatDuration(${p.dartName}, 'short')";
      case MessageFormatFormatter.durationLong:
        return "_formatDuration(${p.dartName}, 'long')";
      case MessageFormatFormatter.durationCustom:
        return "_formatDuration(${p.dartName}, '${escapeForSingleQuotedString(p.formatterStyle ?? '')}')";
    }
  }
}
