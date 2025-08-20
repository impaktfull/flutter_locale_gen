import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/model/plural.dart';
import 'package:locale_gen/src/util/case/case_util.dart';
import 'package:locale_gen/src/util/documentation/documentation_util.dart';
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
    final sb = StringBuffer();
    [
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
          '  Localization get instance => _instance ??= Localization._();')
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
          .replaceAll('\n', r'\n')
          .replaceAll('\r', r'\r')
          .replaceAll('"', r'\"')
          .replaceAll('\$', r'\$');
      sb.writeln('    $variableName: _t(r"$escapedValue"),');
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
      sb.write('    $variableName: _t(r"$escapedValue", args: <dynamic> [');
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
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('"', r'\"')
      .replaceAll('\$', r'\$')
      .replaceAll('\$', r"\$");

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
}
