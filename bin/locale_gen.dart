import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import 'src/params.dart';
import 'src/translation_file_writer.dart';

final outputDir = join('lib', 'util', 'locale');
final assetsDir = join('assets', 'locale');

Params params;

Future<void> main(List<String> args) async {
  final pubspecYaml = File(join(Directory.current.path, 'pubspec.yaml'));
  if (!pubspecYaml.existsSync())
    throw Exception(
        'This program should be run from the root of a flutter/dart project');

  await parsePubspec(pubspecYaml);

  final defaultLocaleJson = File(join(
      Directory.current.path, assetsDir, '${params.defaultLanguage}.json'));
  if (!defaultLocaleJson.existsSync()) {
    throw Exception('${defaultLocaleJson.path} does not exists');
  }

  createLocalizationFile(defaultLocaleJson);
  createLocalizationDelegateFile();
  print('Done!!!');
}

Future<void> parsePubspec(File pubspecYaml) async {
  final pubspecContent = pubspecYaml.readAsStringSync();
  params = Params(pubspecContent);
  print('Default language: ${params.defaultLanguage}');
  print('Supported languages: ${params.languages}');
}

void createLocalizationFile(File defaultLocaleJson) {
  print('Creating localization.dart ...');
  final sb = StringBuffer()
    ..writeln("import 'dart:convert';")
    ..writeln()
    ..writeln("import 'package:flutter/services.dart';")
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln(
        '//============================================================//')
    ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
    ..writeln(
        '//============================================================//')
    ..writeln('class Localization {')
    ..writeln('  Map<dynamic, dynamic> _localisedValues;')
    ..writeln()
    ..writeln(
        '  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization);')
    ..writeln('  ')
    ..writeln('  static Future<Localization> load(Locale locale) async {')
    ..writeln('    final localizations = Localization();')
    ..writeln("    print('Switching to \${locale.languageCode}');")
    ..writeln(
        "    final jsonContent = await rootBundle.loadString('assets/locale/\${locale.languageCode}.json');")
    ..writeln(
        '    final Map<String, dynamic> values = json.decode(jsonContent);')
    ..writeln('    localizations._localisedValues = values;')
    ..writeln('    return localizations;')
    ..writeln('  }')
    ..writeln()
    ..writeln('  String _t(String key, {List<dynamic> args}) {')
    ..writeln('    try {')
    ..writeln('      String value = _localisedValues[key];')
    ..writeln("      if (value == null) return '⚠\$key⚠';")
    ..writeln('      if (args == null || args.isEmpty) return value;')
    ..writeln(
        '      args.asMap().forEach((index, arg) => value = _replaceWith(value, arg, index + 1));')
    ..writeln('      return value;')
    ..writeln('    } catch (e) {')
    ..writeln("      return '⚠\$key⚠';")
    ..writeln('    }')
    ..writeln('  }')
    ..writeln()
    ..writeln('  String _replaceWith(String value, arg, argIndex) {')
    ..writeln('    if (arg == null) return value;')
    ..writeln('    if (arg is String) {')
    ..writeln("      return value.replaceAll('%\$argIndex\\\$s', arg);")
    ..writeln('    } else if (arg is num) {')
    ..writeln("      return value.replaceAll('%\$argIndex\\\$d', '\$arg');")
    ..writeln('    }')
    ..writeln('    return value;')
    ..writeln('  }')
    ..writeln();
  final content = defaultLocaleJson.readAsStringSync();
  final translations = json.decode(content);
  translations.forEach(
      (key, value) => FileWriter.buildTranslationFunction(sb, key, value));
  sb.writeln('}');

  // Write to file
  final localizationFile =
      File(join(Directory.current.path, outputDir, 'localization.dart'));
  if (!localizationFile.existsSync()) {
    print('localization.dart does not exists');
    print('Creating localization.dart ...');
    localizationFile.createSync(recursive: true);
  }
  localizationFile.writeAsStringSync(sb.toString());
}

void createLocalizationDelegateFile() {
  print('Creating localization_delegate.dart ...');

  final sb = StringBuffer()
    ..writeln("import 'dart:async';")
    ..writeln()
    ..writeln(
        "import 'package:${params.projectName}/util/locale/localization.dart';")
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln(
        '//============================================================//')
    ..writeln('//THIS FILE IS AUTO GENERATED. DO NOT EDIT//')
    ..writeln(
        '//============================================================//')
    ..writeln(
        'class LocalizationDelegate extends LocalizationsDelegate<Localization> {')
    ..writeln(
        "  static const defaultLocale = Locale('${params.defaultLanguage}');")
    ..writeln('  static const supportedLanguages = [');
  params.languages.forEach((language) => sb.writeln("    '$language',"));
  sb
    ..writeln('  ];')
    ..writeln()
    ..writeln('  static const supportedLocales = [');
  params.languages
      .forEach((language) => sb.writeln("    Locale('$language'),"));
  sb
    ..writeln('  ];')
    ..writeln()
    ..writeln('  Locale newLocale;')
    ..writeln('  Locale activeLocale;')
    ..writeln()
    ..writeln('  LocalizationDelegate({this.newLocale}) {')
    ..writeln('    if (newLocale != null) {')
    ..writeln('      activeLocale = newLocale;')
    ..writeln('    }')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
        '  bool isSupported(Locale locale) => supportedLanguages.contains(locale.languageCode);')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  Future<Localization> load(Locale locale) async {')
    ..writeln('    activeLocale = newLocale ?? locale;')
    ..writeln('    return Localization.load(activeLocale);')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln(
        '  bool shouldReload(LocalizationsDelegate<Localization> old) => true;')
    ..writeln()
    ..writeln('}');

  // Write to file
  final localizationDelegateFile = File(
      join(Directory.current.path, outputDir, 'localization_delegate.dart'));
  if (!localizationDelegateFile.existsSync()) {
    print('localization_delegate.dart does not exists');
    print('Creating localization_delegate.dart ...');
    localizationDelegateFile.createSync(recursive: true);
  }
  localizationDelegateFile.writeAsStringSync(sb.toString());
}
