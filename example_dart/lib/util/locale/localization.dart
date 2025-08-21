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
    en: _t(r"Testing argument %1\\$s", args: <dynamic>[arg1]),
    nl: _t(r"Test argument %1\\$s", args: <dynamic>[arg1]),
    zhHansCN: _t(r"频的 %1\\$s", args: <dynamic>[arg1]),
    fiFI: _t(r"Lisää napauttamalla %1\\$s", args: <dynamic>[arg1]),
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
    en: _t(r"Testing argument %1\\$d", args: <dynamic>[arg1]),
    nl: _t(r"Test argument %1\\$d", args: <dynamic>[arg1]),
    zhHansCN: _t(r"频的 %1\\$d", args: <dynamic>[arg1]),
    fiFI: _t(r"Lisää napauttamalla %1\\$d", args: <dynamic>[arg1]),
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
    en: _t(r"Testing argument %1\\$s %2\\$d", args: <dynamic>[arg1, arg2]),
    nl: _t(r"Test argument %1\\$s %2\\$d", args: <dynamic>[arg1, arg2]),
    zhHansCN: _t(r"频的 %1\\$s %2\\$d", args: <dynamic>[arg1, arg2]),
    fiFI: _t(r"Lisää napauttamalla %1\\$s %2\\$d", args: <dynamic>[arg1, arg2]),
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
    en: _t(
      r"Testing argument %1\\$s %2\\$.02f %1\\$s",
      args: <dynamic>[arg1, arg2],
    ),
    nl: _t(r"Test argument %1\\$s %2\\$f %1\\$s", args: <dynamic>[arg1, arg2]),
    zhHansCN: _t(r"频的 %1\\$s %2\\$f %1\\$s", args: <dynamic>[arg1, arg2]),
    fiFI: _t(
      r"Lisää napauttamalla %1\\$s %2\\$f %1\\$s",
      args: <dynamic>[arg1, arg2],
    ),
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
    en: _t(
      r"Testing\nargument\n\n%1\\$s %2\\$d %1\\$s",
      args: <dynamic>[arg1, arg2],
    ),
    nl: _t(
      r"Test\nargument\n\n%1\\$s %2\\$d %1\\$s",
      args: <dynamic>[arg1, arg2],
    ),
    zhHansCN: _t(r"频\n的\n\n%1\\$s %2\\$d %1\\$s", args: <dynamic>[arg1, arg2]),
    fiFI: _t(
      r"Lisää\nLisää napauttamalla\n\n%1\\$s %2\\$d %1\\$s",
      args: <dynamic>[arg1, arg2],
    ),
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
    en: _t(
      r"Testing non positional argument %s and %.02f",
      args: <dynamic>[arg1, arg2],
    ),
    nl: _t(
      r"Test niet positioneel argument %s en %f",
      args: <dynamic>[arg1, arg2],
    ),
    zhHansCN: _t(r"测试非位置参数 %s 和 %f", args: <dynamic>[arg1, arg2]),
    fiFI: _t(
      r"Testataan ei-positiaalista argumenttia %s ja %f",
      args: <dynamic>[arg1, arg2],
    ),
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
}
