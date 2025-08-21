import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/core_writer.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';

class LocaleGenFlutterWriter extends LocaleGenCoreWriter {
  @override
  void write(
    LocaleGenParams params,
    Map<String, dynamic> defaultTranslations,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final generator = LocaleGenFlutterGenerator();
    _createLocalizationKeysFile(
        generator, params, defaultTranslations, allTranslations);
    _createLocalizationFile(
        generator, params, defaultTranslations, allTranslations);
    _createLocalizationDelegateFile(generator, params);
    _createLocalizationOverrides(generator, params);
  }

  void _createLocalizationKeysFile(
    LocaleGenFlutterGenerator generator,
    LocaleGenParams params,
    Map<String, dynamic> defaultTranslations,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final content = generator.createLocalizationKeysFile(
        params, defaultTranslations, allTranslations);
    writeFile(params.outputDir, 'localization_keys.dart', content);
  }

  void _createLocalizationFile(
    LocaleGenFlutterGenerator generator,
    LocaleGenParams params,
    Map<String, dynamic> defaultTranslations,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final content = generator.createLocalizationFile(
        params, defaultTranslations, allTranslations);
    writeFile(params.outputDir, 'localization.dart', content);
  }

  void _createLocalizationDelegateFile(
      LocaleGenFlutterGenerator generator, LocaleGenParams params) {
    final content = generator.createLocalizationDelegateFile(params);
    writeFile(params.outputDir, 'localization_delegate.dart', content);
  }

  void _createLocalizationOverrides(
    LocaleGenFlutterGenerator generator,
    LocaleGenParams params,
  ) {
    final content = generator.createLocalizationOverrides(params);
    writeFile(params.outputDir, 'localization_overrides.dart', content);
  }
}
