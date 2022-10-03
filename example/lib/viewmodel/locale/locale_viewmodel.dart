import 'package:flutter/material.dart';
import 'package:locale_gen_example/repository/locale_repository.dart';
import 'package:locale_gen_example/util/locale/custom_localization_overrides.dart';
import 'package:locale_gen_example/util/locale/localization.dart';

class LocaleViewModel with ChangeNotifier {
  final LocaleRepository _localeRepository;
  var customLocalizationOverrides = CustomLocalizationOverrideManager();
  static final Localization _localizationInstance = Localization();

  static Localization get localizationInstance => _localizationInstance;

  LocaleViewModel(this._localeRepository);

  void init() {
    initLocale();
    refreshOverrideLocalizations();
  }

  Future<void> initLocale() async {
    final locale = await _localeRepository.getCustomLocale();
    await _localizationInstance.load(
      locale: locale,
      localizationOverrides: customLocalizationOverrides,
    );
    notifyListeners();
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

  Future<void> onSwitchToZHHansCN() async {
    await _onUpdateLocaleClicked(const Locale('zh', 'Hans-CN'));
  }

  Future<void> onSwitchToFiFi() async {
    await _onUpdateLocaleClicked(const Locale('fi', 'FI'));
  }

  Future<void> onSwitchToSystemLanguage() async {
    await _onUpdateLocaleClicked(null);
  }

  Future<void> showTranslationKeys() async {
    final locale = await _localeRepository.getCustomLocale();

    await _localizationInstance.load(
      locale: locale,
      localizationOverrides: customLocalizationOverrides,
      showLocalizationKeys: true,
    );
    notifyListeners();
  }

  Future<void> _onUpdateLocaleClicked(Locale? locale) async {
    await _localeRepository.setCustomLocale(locale);
    await _localizationInstance.load(
      locale: locale,
      localizationOverrides: customLocalizationOverrides,
    );
    notifyListeners();
  }
}
