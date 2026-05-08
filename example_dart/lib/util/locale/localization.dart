import 'package:intl/intl.dart';
import 'package:intl/message_format.dart';
import 'package:sprintf/sprintf.dart';

//============================================================//
//THIS FILE IS AUTO GENERATED. DO NOT EDIT//
//============================================================//

class LocalizedValue {
  final String en;
  final String nl;
  final String zhHansCN;
  final String fiFI;

  LocalizedValue({
    required this.en,
    required this.nl,
    required this.zhHansCN,
    required this.fiFI,
  });
}

class Localization {
  static Localization? _instance;

  static Localization get instance => _instance ??= Localization._();

  Localization._();

  String _t(String value, {List<dynamic>? args}) {
    try {
      if (args == null || args.isEmpty) return value;
      return sprintf(value, args);
    } catch (e) {
      return '⚠$value⚠';
    }
  }

  String _mf(String template, {required Map<String, Object> args, required String locale}) {
    try {
      final stripped = _stripFormatSpecs(template);
      return MessageFormat(stripped, locale: locale).format(args);
    } catch (e) {
      return '⚠$template⚠';
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
        while (i + n < style.length && style[i + n] == 'H') n++;
        buf.write(h.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      if (c == 'm') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 'm') n++;
        buf.write(m.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      if (c == 's') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 's') n++;
        buf.write(s.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      buf.write(c);
      i++;
    }
    return buf.toString();
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
  LocalizedValue get test => LocalizedValue(
    en: _t(r"Testing in English"),
    nl: _t(r"Test in het Nederlands"),
    zhHansCN: _t(r"视频的灯光脚本"),
    fiFI: _t(r"Näet lisää napauttamalla kuvakkeita"),
  );

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string]'**
  LocalizedValue testArg1(String arg1) => LocalizedValue(
    en: _t(r"Testing argument %1\$s", args: <dynamic> [arg1]),
    nl: _t(r"Test argument %1\$s", args: <dynamic> [arg1]),
    zhHansCN: _t(r"频的 %1\$s", args: <dynamic> [arg1]),
    fiFI: _t(r"Lisää napauttamalla %1\$s", args: <dynamic> [arg1]),
  );

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 number]'**
  ///
  /// nl:  **'Test argument [arg1 number]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 number]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 number]'**
  LocalizedValue testArg2(int arg1) => LocalizedValue(
    en: _t(r"Testing argument %1\$d", args: <dynamic> [arg1]),
    nl: _t(r"Test argument %1\$d", args: <dynamic> [arg1]),
    zhHansCN: _t(r"频的 %1\$d", args: <dynamic> [arg1]),
    fiFI: _t(r"Lisää napauttamalla %1\$d", args: <dynamic> [arg1]),
  );

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] [arg2 number]'**
  ///
  /// nl:  **'Test argument [arg1 string] [arg2 number]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] [arg2 number]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] [arg2 number]'**
  LocalizedValue testArg3(String arg1, int arg2) => LocalizedValue(
    en: _t(r"Testing argument %1\$s %2\$d", args: <dynamic> [arg1, arg2]),
    nl: _t(r"Test argument %1\$s %2\$d", args: <dynamic> [arg1, arg2]),
    zhHansCN: _t(r"频的 %1\$s %2\$d", args: <dynamic> [arg1, arg2]),
    fiFI: _t(r"Lisää napauttamalla %1\$s %2\$d", args: <dynamic> [arg1, arg2]),
  );

  /// Translations:
  ///
  /// en:  **'Testing argument [arg1 string] %2$.02f [arg1 string]'**
  ///
  /// nl:  **'Test argument [arg1 string] %2$f [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频的 [arg1 string] %2$f [arg1 string]'**
  ///
  /// fi-FI: **'Lisää napauttamalla [arg1 string] %2$f [arg1 string]'**
  LocalizedValue testArg4(String arg1, double arg2) => LocalizedValue(
    en: _t(r"Testing argument %1\$s %2\$.02f %1\$s", args: <dynamic> [arg1, arg2]),
    nl: _t(r"Test argument %1\$s %2\$f %1\$s", args: <dynamic> [arg1, arg2]),
    zhHansCN: _t(r"频的 %1\$s %2\$f %1\$s", args: <dynamic> [arg1, arg2]),
    fiFI: _t(r"Lisää napauttamalla %1\$s %2\$f %1\$s", args: <dynamic> [arg1, arg2]),
  );

  /// Translations:
  ///
  /// en:  **'Testing\nargument\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// nl:  **'Test\nargument\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// zh-Hans-CN: **'频\n的\n\n[arg1 string] [arg2 number] [arg1 string]'**
  ///
  /// fi-FI: **'Lisää\nLisää napauttamalla\n\n[arg1 string] [arg2 number] [arg1 string]'**
  LocalizedValue testNewLine(String arg1, int arg2) => LocalizedValue(
    en: _t(r"Testing\nargument\n\n%1\$s %2\$d %1\$s", args: <dynamic> [arg1, arg2]),
    nl: _t(r"Test\nargument\n\n%1\$s %2\$d %1\$s", args: <dynamic> [arg1, arg2]),
    zhHansCN: _t(r"频\n的\n\n%1\$s %2\$d %1\$s", args: <dynamic> [arg1, arg2]),
    fiFI: _t(r"Lisää\nLisää napauttamalla\n\n%1\$s %2\$d %1\$s", args: <dynamic> [arg1, arg2]),
  );

  /// Translations:
  ///
  /// en:  **'Carriage\r\nReturn'**
  ///
  /// nl:  **'Carriage\r\nReturn'**
  ///
  /// zh-Hans-CN: **'Carriage\r\nReturn'**
  ///
  /// fi-FI: **'Carriage\r\nReturn'**
  LocalizedValue get testNewLineCarriageReturn => LocalizedValue(
    en: _t(r"Carriage\r\nReturn"),
    nl: _t(r"Carriage\r\nReturn"),
    zhHansCN: _t(r"Carriage\r\nReturn"),
    fiFI: _t(r"Carriage\r\nReturn"),
  );

  /// Translations:
  ///
  /// en:  **'Testing non positional argument %s and %.02f'**
  ///
  /// nl:  **'Test niet positioneel argument %s en %f'**
  ///
  /// zh-Hans-CN: **'测试非位置参数 %s 和 %f'**
  ///
  /// fi-FI: **'Testataan ei-positiaalista argumenttia %s ja %f'**
  LocalizedValue testNonPositional(String arg1, double arg2) => LocalizedValue(
    en: _t(r"Testing non positional argument %s and %.02f", args: <dynamic> [arg1, arg2]),
    nl: _t(r"Test niet positioneel argument %s en %f", args: <dynamic> [arg1, arg2]),
    zhHansCN: _t(r"测试非位置参数 %s 和 %f", args: <dynamic> [arg1, arg2]),
    fiFI: _t(r"Testataan ei-positiaalista argumenttia %s ja %f", args: <dynamic> [arg1, arg2]),
  );

  /// Translations:
  ///
  /// en:  **'Welcome'**
  ///
  /// nl:  **'Hallo daar'**
  ///
  /// zh-Hans-CN: **'欢迎'**
  ///
  /// fi-FI: **'Lisää napauttamalla'**
  LocalizedValue get welcomeMessage => LocalizedValue(
    en: _t(r"Welcome"),
    nl: _t(r"Hallo daar"),
    zhHansCN: _t(r"欢迎"),
    fiFI: _t(r"Lisää napauttamalla"),
  );

  /// Translations:
  ///
  /// en:  **'Hi, {name}!'**
  ///
  /// nl:  **'Hallo, {name}!'**
  ///
  /// zh-Hans-CN: **'你好, {name}!'**
  ///
  /// fi-FI: **'Hei, {name}!'**
  LocalizedValue mfGreeting({required String name}) => LocalizedValue(
    en: _mf(r"Hi, {name}!", args: {'name': name}, locale: 'en'),
    nl: _mf(r"Hallo, {name}!", args: {'name': name}, locale: 'nl'),
    zhHansCN: _mf(r"你好, {name}!", args: {'name': name}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"Hei, {name}!", args: {'name': name}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'{count, plural, one {# item} other {# items}}'**
  ///
  /// nl:  **'{count, plural, one {# stuk} other {# stuks}}'**
  ///
  /// zh-Hans-CN: **'{count, plural, other {# 件}}'**
  ///
  /// fi-FI: **'{count, plural, one {# tuote} other {# tuotetta}}'**
  LocalizedValue mfCartCount({required num count}) => LocalizedValue(
    en: _mf(r"{count, plural, one {# item} other {# items}}", args: {'count': count}, locale: 'en'),
    nl: _mf(r"{count, plural, one {# stuk} other {# stuks}}", args: {'count': count}, locale: 'nl'),
    zhHansCN: _mf(r"{count, plural, other {# 件}}", args: {'count': count}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"{count, plural, one {# tuote} other {# tuotetta}}", args: {'count': count}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'{gender, select, male {he} female {she} other {they}}'**
  ///
  /// nl:  **'{gender, select, male {hij} female {zij} other {zij}}'**
  ///
  /// zh-Hans-CN: **'{gender, select, male {他} female {她} other {他们}}'**
  ///
  /// fi-FI: **'{gender, select, male {hän} female {hän} other {he}}'**
  LocalizedValue mfPronoun({required String gender}) => LocalizedValue(
    en: _mf(r"{gender, select, male {he} female {she} other {they}}", args: {'gender': gender}, locale: 'en'),
    nl: _mf(r"{gender, select, male {hij} female {zij} other {zij}}", args: {'gender': gender}, locale: 'nl'),
    zhHansCN: _mf(r"{gender, select, male {他} female {她} other {他们}}", args: {'gender': gender}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"{gender, select, male {hän} female {hän} other {he}}", args: {'gender': gender}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}'**
  ///
  /// nl:  **'{place, selectordinal, other {#e}}'**
  ///
  /// zh-Hans-CN: **'{place, selectordinal, other {第#}}'**
  ///
  /// fi-FI: **'{place, selectordinal, other {#.}}'**
  LocalizedValue mfRank({required num place}) => LocalizedValue(
    en: _mf(r"{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}", args: {'place': place}, locale: 'en'),
    nl: _mf(r"{place, selectordinal, other {#e}}", args: {'place': place}, locale: 'nl'),
    zhHansCN: _mf(r"{place, selectordinal, other {第#}}", args: {'place': place}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"{place, selectordinal, other {#.}}", args: {'place': place}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'Total: {total, number, currency}'**
  ///
  /// nl:  **'Totaal: {total, number, currency}'**
  ///
  /// zh-Hans-CN: **'合计: {total, number, currency}'**
  ///
  /// fi-FI: **'Yhteensä: {total, number, currency}'**
  LocalizedValue mfTotal({required num total}) => LocalizedValue(
    en: _mf(r"Total: {total, number, currency}", args: {'total': NumberFormat.simpleCurrency(locale: 'en').format(total)}, locale: 'en'),
    nl: _mf(r"Totaal: {total, number, currency}", args: {'total': NumberFormat.simpleCurrency(locale: 'nl').format(total)}, locale: 'nl'),
    zhHansCN: _mf(r"合计: {total, number, currency}", args: {'total': NumberFormat.simpleCurrency(locale: 'zh-Hans-CN').format(total)}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"Yhteensä: {total, number, currency}", args: {'total': NumberFormat.simpleCurrency(locale: 'fi-FI').format(total)}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'Placed on {placedAt, date, short}'**
  ///
  /// nl:  **'Geplaatst op {placedAt, date, short}'**
  ///
  /// zh-Hans-CN: **'下单于 {placedAt, date, short}'**
  ///
  /// fi-FI: **'Tehty {placedAt, date, short}'**
  LocalizedValue mfPlacedAt({required DateTime placedAt}) => LocalizedValue(
    en: _mf(r"Placed on {placedAt, date, short}", args: {'placedAt': DateFormat.yMd('en').format(placedAt)}, locale: 'en'),
    nl: _mf(r"Geplaatst op {placedAt, date, short}", args: {'placedAt': DateFormat.yMd('nl').format(placedAt)}, locale: 'nl'),
    zhHansCN: _mf(r"下单于 {placedAt, date, short}", args: {'placedAt': DateFormat.yMd('zh-Hans-CN').format(placedAt)}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"Tehty {placedAt, date, short}", args: {'placedAt': DateFormat.yMd('fi-FI').format(placedAt)}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'Meeting at {at, time, short}'**
  ///
  /// nl:  **'Vergadering om {at, time, short}'**
  ///
  /// zh-Hans-CN: **'会议时间 {at, time, short}'**
  ///
  /// fi-FI: **'Kokous klo {at, time, short}'**
  LocalizedValue mfMeetingAt({required DateTime at}) => LocalizedValue(
    en: _mf(r"Meeting at {at, time, short}", args: {'at': DateFormat.jm('en').format(at)}, locale: 'en'),
    nl: _mf(r"Vergadering om {at, time, short}", args: {'at': DateFormat.jm('nl').format(at)}, locale: 'nl'),
    zhHansCN: _mf(r"会议时间 {at, time, short}", args: {'at': DateFormat.jm('zh-Hans-CN').format(at)}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"Kokous klo {at, time, short}", args: {'at': DateFormat.jm('fi-FI').format(at)}, locale: 'fi-FI'),
  );

  /// Translations:
  ///
  /// en:  **'Lap time: {d, duration, mm:ss}'**
  ///
  /// nl:  **'Rondetijd: {d, duration, mm:ss}'**
  ///
  /// zh-Hans-CN: **'圈速: {d, duration, mm:ss}'**
  ///
  /// fi-FI: **'Kierrosaika: {d, duration, mm:ss}'**
  LocalizedValue mfRace({required Duration d}) => LocalizedValue(
    en: _mf(r"Lap time: {d, duration, mm:ss}", args: {'d': _formatDuration(d, 'mm:ss')}, locale: 'en'),
    nl: _mf(r"Rondetijd: {d, duration, mm:ss}", args: {'d': _formatDuration(d, 'mm:ss')}, locale: 'nl'),
    zhHansCN: _mf(r"圈速: {d, duration, mm:ss}", args: {'d': _formatDuration(d, 'mm:ss')}, locale: 'zh-Hans-CN'),
    fiFI: _mf(r"Kierrosaika: {d, duration, mm:ss}", args: {'d': _formatDuration(d, 'mm:ss')}, locale: 'fi-FI'),
  );

}
