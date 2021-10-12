import 'package:flutter/material.dart';
import 'package:locale_gen_example/repository/locale_repository.dart';
import 'package:locale_gen_example/util/locale/custom_localization_overrides.dart';
import 'package:locale_gen_example/util/locale/localization_delegate.dart';

class LocaleViewModel with ChangeNotifier {
  final LocaleRepository _localeRepository;
  var customLocalizationOverrides = CustomLocalizationOverrideManager();
  late var localeDelegate = LocalizationDelegate(
    localizationOverrides: customLocalizationOverrides,
  );

  LocaleViewModel(this._localeRepository);

  void init() {
    initLocale();
    refreshOverrideLocalizations();
  }

  Future<void> initLocale() async {
    final locale = await _localeRepository.getCustomLocale();
    if (locale != null) {
      localeDelegate = LocalizationDelegate(
        newLocale: locale,
        localizationOverrides: customLocalizationOverrides,
      );
      notifyListeners();
    }
  }

  Future<void> refreshOverrideLocalizations() async {
    await customLocalizationOverrides.refreshOverrideLocalizations();
    await initLocale();
  }

  Future<void> onSwitchToDutch() async {
    await _onUpdateLocaleClicked(const Locale('nl'));
  }

  Future<void> onSwitchToEnglish() async {
    await _onUpdateLocaleClicked(const Locale('en'));
  }

  Future<void> onSwitchToSystemLanguage() async {
    await _onUpdateLocaleClicked(null);
  }

  Future<void> _onUpdateLocaleClicked(Locale? locale) async {
    await _localeRepository.setCustomLocale(locale);
    localeDelegate = LocalizationDelegate(
      newLocale: locale,
      localizationOverrides: customLocalizationOverrides,
    );
    notifyListeners();
  }
}
