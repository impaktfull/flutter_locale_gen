import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/core_writer.dart';
import 'package:locale_gen/src/writer/dart/dart_generator.dart';

class LocaleGenDartWriter extends LocaleGenCoreWriter {
  @override
  void write(
    LocaleGenParams params,
    Map<String, dynamic> defaultTranslations,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final generator = LocaleGenDartGenerator();
    _createLocalizationFile(
      generator,
      params,
      defaultTranslations,
      allTranslations,
    );
  }

  void _createLocalizationFile(
    LocaleGenDartGenerator generator,
    LocaleGenParams params,
    Map<String, dynamic> defaultTranslations,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final content = generator.createLocalizationFile(
      params,
      defaultTranslations,
      allTranslations,
    );
    writeFile(params.outputDir, 'localization.dart', content);
  }
}
