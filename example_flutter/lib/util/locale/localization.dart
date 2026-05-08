import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_format.dart';
import 'package:locale_gen_example/util/locale/localization_keys.dart';
import 'package:locale_gen_example/util/locale/localization_overrides.dart';
import 'package:sprintf/sprintf.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

typedef LocaleFilter = bool Function(String languageCode);

class Localization {
  LocaleFilter? localeFilter;

  var _localisedValues = <String, dynamic>{};
  var _localisedOverrideValues = <String, dynamic>{};

  static Localization of(BuildContext context) => Localizations.of<Localization>(context, Localization)!;

  /// The locale is used to get the correct json locale.
  /// It can later be used to check what the locale is that was used to load this Localization instance.
  final Locale? locale;

  Localization({required this.locale});

  static Future<Localization> load({
    required Locale locale, 
    LocalizationOverrides? localizationOverrides,
    bool showLocalizationKeys = false,
    bool useCaching = true,
    AssetBundle? bundle,
    }) async {
    final localizations = Localization(locale: locale);
    if (showLocalizationKeys) {
      return localizations;
    }
    if (localizationOverrides != null) {
      final overrideLocalizations = await localizationOverrides.getOverriddenLocalizations(locale);
      localizations._localisedOverrideValues = overrideLocalizations;
    }
    final jsonContent = await (bundle ?? rootBundle).loadString('assets/locale/${locale.toLanguageTag()}.json', cache: useCaching);
    localizations._localisedValues = json.decode(jsonContent) as Map<String, dynamic>;
    return localizations;
  }

  String _t(String key, {List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String _mf(String key, {required Map<String, Object> args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
      if (value == null) return key;
      final stripped = _stripFormatSpecs(value);
      return MessageFormat(stripped, locale: locale?.toLanguageTag() ?? 'en').format(args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  String _stripFormatSpecs(String value) {
    final regex = RegExp(r'\{(\w+)\s*,\s*(number|date|time|duration)(\s*,[^{}]*)?\}');
    return value.replaceAllMapped(regex, (m) => '{${m.group(1)}}');
  }

  String _formatDuration(Duration d, String? style) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    String pad(int n) => n.toString().padLeft(2, '0');
    if (style == null || style == 'medium') {
      return '${pad(h)}:${pad(m)}:${pad(s)}';
    }
    if (style == 'short') {
      return '${pad(d.inMinutes)}:${pad(s)}';
    }
    if (style == 'long') {
      final parts = <String>[];
      if (h > 0) parts.add('${h}h');
      if (m > 0) parts.add('${m}m');
      if (s > 0 || parts.isEmpty) parts.add('${s}s');
      return parts.join(' ');
    }
    final buf = StringBuffer();
    var i = 0;
    while (i < style.length) {
      final c = style[i];
      if (c == "'" && i + 1 < style.length) {
        final end = style.indexOf("'", i + 1);
        if (end == -1) {
          buf.write(style.substring(i + 1));
          break;
        }
        buf.write(style.substring(i + 1, end));
        i = end + 1;
        continue;
      }
      if (c == 'H') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 'H') {
          n++;
        }
        buf.write(h.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      if (c == 'm') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 'm') {
          n++;
        }
        buf.write(m.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      if (c == 's') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 's') {
          n++;
        }
        buf.write(s.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      buf.write(c);
      i++;
    }
    return buf.toString();
  }

  String _plural(String key, {required num count, List<dynamic>? args}) {
    try {
      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as Map<String, dynamic>?;
      if (value == null) return key;
      
      final pluralValue = Intl.plural(
        count,
        zero: value['zero'] as String?,
        one: value['one'] as String?,
        two: value['two'] as String?,
        few: value['few'] as String?,
        many: value['many'] as String?,
        other: value['other'] as String,
      );
      if (args == null || args.isEmpty) return pluralValue;
      return sprintf(pluralValue, args);
    } catch (e) {
      return '⚠$key⚠';
    }
  }

  /// Translations:
  ///
  /// en:  **'Testing in English'**
  ///
  /// nl:  **'Test in het Nederlands'**
  ///
  /// zh-Hans-CN: **'视频的灯光脚本'**
  ///
  /// fi-FI: **'Näet lisää napauttamalla kuvakkeita'**
  String get test => _t(LocalizationKeys.test);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string]'**
  String testArg1(String arg1) => _t(LocalizationKeys.testArg1, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 number]'**
  ///
  /// nl:  **'Test argument [arg1 number]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 number]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 number]'**
  String testArg2(int arg1) => _t(LocalizationKeys.testArg2, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] [arg2 number]'**
  ///
  /// nl:  **'Test argument [arg1 string] [arg2 number]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] [arg2 number]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] [arg2 number]'**
  String testArg3(String arg1, int arg2) => _t(LocalizationKeys.testArg3, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] %2$.02f [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string] %2$f [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] %2$f [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] %2$f [arg1 string]'**
  String testArg4(String arg1, double arg2) => _t(LocalizationKeys.testArg4, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Testing\nargument\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// nl:  **'Test\nargument\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频\n的\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// fi-FI: **'Lisää\nLisää napauttamalla\n\n[arg1 string] [arg2 number] [arg1 string]'**
  String testNewLine(String arg1, int arg2) => _t(LocalizationKeys.testNewLine, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'Carriage\r\nReturn'**
  ///
  /// nl:  **'Carriage\r\nReturn'**
  ///
  /// zh-Hans-CN: **'Carriage\r\nReturn'**
  ///
  /// fi-FI: **'Carriage\r\nReturn'**
  String get testNewLineCarriageReturn => _t(LocalizationKeys.testNewLineCarriageReturn);

  /// Translations:
  ///
  /// en:  **'Testing non positional argument %s and %.02f'**
  ///
  /// nl:  **'Test niet positioneel argument %s en %f'**
  ///
  /// zh-Hans-CN: **'测试非位置参数 %s 和 %f'**
  ///
  /// fi-FI: **'Testataan ei-positiaalista argumenttia %s ja %f'**
  String testNonPositional(String arg1, double arg2) => _t(LocalizationKeys.testNonPositional, args: <dynamic>[arg1, arg2]);

  /// Translations:
  ///
  /// en:  **'{one: %d hour, other: %d hours}'**
  ///
  /// nl:  **'{one: %d uur, other: %d uren}'**
  ///
  /// zh-Hans-CN: **'{other: %d 小时}'**
  ///
  /// fi-FI: **'{one: %d tunti, other: %d tuntia}'**
  String testPlural(num count, int arg1) => _plural(LocalizationKeys.testPlural, count: count, args: <dynamic>[arg1]);

  /// Translations:
  ///
  /// en:  **'Hi, {name}!'**
  ///
  /// nl:  **'Hallo, {name}!'**
  ///
  /// zh-Hans-CN: **'你好, {name}!'**
  ///
  /// fi-FI: **'Hei, {name}!'**
  String mfGreeting({required String name}) => _mf(LocalizationKeys.mfGreeting, args: {'name': name});

  /// Translations:
  ///
  /// en:  **'{count, plural, one {# item} other {# items}}'**
  ///
  /// nl:  **'{count, plural, one {# stuk} other {# stuks}}'**
  ///
  /// zh-Hans-CN: **'{count, plural, other {# 件}}'**
  ///
  /// fi-FI: **'{count, plural, one {# tuote} other {# tuotetta}}'**
  String mfCartCount({required num count}) => _mf(LocalizationKeys.mfCartCount, args: {'count': count});

  /// Translations:
  ///
  /// en:  **'{gender, select, male {he} female {she} other {they}}'**
  ///
  /// nl:  **'{gender, select, male {hij} female {zij} other {zij}}'**
  ///
  /// zh-Hans-CN: **'{gender, select, male {他} female {她} other {他们}}'**
  ///
  /// fi-FI: **'{gender, select, male {hän} female {hän} other {he}}'**
  String mfPronoun({required String gender}) => _mf(LocalizationKeys.mfPronoun, args: {'gender': gender});

  /// Translations:
  ///
  /// en:  **'{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}'**
  ///
  /// nl:  **'{place, selectordinal, other {#e}}'**
  ///
  /// zh-Hans-CN: **'{place, selectordinal, other {第#}}'**
  ///
  /// fi-FI: **'{place, selectordinal, other {#.}}'**
  String mfRank({required num place}) => _mf(LocalizationKeys.mfRank, args: {'place': place});

  /// Translations:
  ///
  /// en:  **'Total: {total, number, currency}'**
  ///
  /// nl:  **'Totaal: {total, number, currency}'**
  ///
  /// zh-Hans-CN: **'合计: {total, number, currency}'**
  ///
  /// fi-FI: **'Yhteensä: {total, number, currency}'**
  String mfTotal({required num total}) => _mf(LocalizationKeys.mfTotal, args: {'total': NumberFormat.simpleCurrency(locale: locale?.toLanguageTag() ?? 'en').format(total)});

  /// Translations:
  ///
  /// en:  **'Placed on {placedAt, date, short}'**
  ///
  /// nl:  **'Geplaatst op {placedAt, date, short}'**
  ///
  /// zh-Hans-CN: **'下单于 {placedAt, date, short}'**
  ///
  /// fi-FI: **'Tehty {placedAt, date, short}'**
  String mfPlacedAt({required DateTime placedAt}) => _mf(LocalizationKeys.mfPlacedAt, args: {'placedAt': DateFormat.yMd(locale?.toLanguageTag() ?? 'en').format(placedAt)});

  /// Translations:
  ///
  /// en:  **'Meeting at {at, time, short}'**
  ///
  /// nl:  **'Vergadering om {at, time, short}'**
  ///
  /// zh-Hans-CN: **'会议时间 {at, time, short}'**
  ///
  /// fi-FI: **'Kokous klo {at, time, short}'**
  String mfMeetingAt({required DateTime at}) => _mf(LocalizationKeys.mfMeetingAt, args: {'at': DateFormat.jm(locale?.toLanguageTag() ?? 'en').format(at)});

  /// Translations:
  ///
  /// en:  **'Lap time: {d, duration, mm:ss}'**
  ///
  /// nl:  **'Rondetijd: {d, duration, mm:ss}'**
  ///
  /// zh-Hans-CN: **'圈速: {d, duration, mm:ss}'**
  ///
  /// fi-FI: **'Kierrosaika: {d, duration, mm:ss}'**
  String mfRace({required Duration d}) => _mf(LocalizationKeys.mfRace, args: {'d': _formatDuration(d, 'mm:ss')});

  String getTranslation(String key, {List<dynamic>? args}) => _t(key, args: args ?? <dynamic>[]);

}
