import 'package:flutter/material.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';
import 'package:locale_gen_example/util/logger/logger.dart';

class CustomLocalizationOverrideManager extends LocalizationOverrides {
  var _translations = <Locale, Map<String, dynamic>>{};

  @override
  Future<void> refreshOverrideLocalizations() async {
    LocaleGenLogger.log('FETCHING LATEST TRANSLATIONS');
    await Future<void>.delayed(const Duration(seconds: 5));
    _translations = {
      const Locale('en'): <String, dynamic>{
        'test': 'Testing in english (override)',
      },
      const Locale('nl'): <String, dynamic>{
        'test': 'Testing in Nederlands (override)',
      },
    };
    LocaleGenLogger.log('GOT THE LATEST TRANSLATIONS');
  }

  @override
  Future<Map<String, dynamic>> getOverriddenLocalizations(Locale locale) async {
    return _translations[locale] ?? <String, dynamic>{};
  }
}
