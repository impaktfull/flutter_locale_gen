import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/format/message_format_util.dart';

/// Produces the Dart expression that pre-formats a [MessageFormatParam] before
/// substitution into a `MessageFormat` template.
///
/// The [localeExpr] is the verbatim Dart expression that yields the locale tag
/// at runtime — e.g.,
/// `"locale?.toLanguageTag() ?? LocalizationDelegate.defaultLocale.toLanguageTag()"`
/// for the Flutter writer, or a literal like `"'en'"` for the per-locale Dart
/// writer.
class MessageFormatArgExpressionBuilder {
  const MessageFormatArgExpressionBuilder._();

  static String build(MessageFormatParam p, String localeExpr) {
    switch (p.formatter) {
      case MessageFormatFormatter.none:
        return p.dartName;
      case MessageFormatFormatter.numberDecimal:
        return 'NumberFormat.decimalPattern($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.numberPercent:
        return 'NumberFormat.percentPattern($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.numberCurrency:
        return 'NumberFormat.simpleCurrency(locale: $localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.numberCustom:
        return "NumberFormat('${MessageFormatUtil.escapeForSingleQuotedString(p.formatterStyle ?? '')}', $localeExpr).format(${p.dartName})";
      case MessageFormatFormatter.dateShort:
        return 'DateFormat.yMd($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.dateMedium:
        return 'DateFormat.yMMMd($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.dateLong:
        return 'DateFormat.yMMMMd($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.dateFull:
        return 'DateFormat.yMMMMEEEEd($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.dateCustom:
        return "DateFormat('${MessageFormatUtil.escapeForSingleQuotedString(p.formatterStyle ?? '')}', $localeExpr).format(${p.dartName})";
      case MessageFormatFormatter.timeShort:
        return 'DateFormat.jm($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.timeMedium:
      case MessageFormatFormatter.timeLong:
      case MessageFormatFormatter.timeFull:
        return 'DateFormat.jms($localeExpr).format(${p.dartName})';
      case MessageFormatFormatter.timeCustom:
        return "DateFormat('${MessageFormatUtil.escapeForSingleQuotedString(p.formatterStyle ?? '')}', $localeExpr).format(${p.dartName})";
      case MessageFormatFormatter.durationDefault:
      case MessageFormatFormatter.durationMedium:
        return '_formatDuration(${p.dartName}, null)';
      case MessageFormatFormatter.durationShort:
        return "_formatDuration(${p.dartName}, 'short')";
      case MessageFormatFormatter.durationLong:
        return "_formatDuration(${p.dartName}, 'long')";
      case MessageFormatFormatter.durationCustom:
        return "_formatDuration(${p.dartName}, '${MessageFormatUtil.escapeForSingleQuotedString(p.formatterStyle ?? '')}')";
    }
  }
}
