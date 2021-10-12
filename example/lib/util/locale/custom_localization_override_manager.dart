import 'package:flutter/material.dart';
import 'package:locale_gen_example/util/locale/localization_override_manager.dart';

class CustomLocalizationOverrideManager extends LocalizationOverrideManager {
  var _translations = <Locale, Map<String, dynamic>>{};

  @override
  Future<void> refreshOverrideLocalizations() async {
    print('FETCHING LATEST TRANSLATIONS');
    await Future<void>.delayed(const Duration(seconds: 5));
    _translations = {
      const Locale('en'): <String, dynamic>{
        'test': 'Testing in english (override)',
      },
      const Locale('nl'): <String, dynamic>{
        'test': 'Testing in Nederlands (override)',
      }
    };
    print('GOT THE LATEST TRANSLATIONS');
  }

  @override
  Future<Map<String, dynamic>> getCachedLocalizations(Locale locale) async {
    return _translations[locale] ?? <String, dynamic>{};
  }
}
