import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/case/case_util.dart';

class MessageFormatParamExtractor {
  const MessageFormatParamExtractor._();

  static Map<String, MessageFormatParam> extract(MessageFormatAst ast) {
    final params = <String, MessageFormatParam>{};
    final dartNameToOriginal = <String, String>{};

    void visit(MessageFormatNode node) {
      switch (node) {
        case LiteralNode():
          break;
        case PlaceholderNode(:final name):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.string, MessageFormatFormatter.none, null);
        case PluralNode(:final name, :final branches):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.num_, MessageFormatFormatter.none, null);
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case SelectOrdinalNode(:final name, :final branches):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.num_, MessageFormatFormatter.none, null);
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case SelectNode(:final name, :final branches):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.string, MessageFormatFormatter.none, null);
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case NumberNode(:final name, :final style):
          final formatter = _numberFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.num_, formatter, style);
        case DateNode(:final name, :final style):
          final formatter = _dateFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.dateTime, formatter, style);
        case TimeNode(:final name, :final style):
          final formatter = _timeFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.dateTime, formatter, style);
        case DurationNode(:final name, :final style):
          final formatter = _durationFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.duration, formatter, style);
      }
    }

    for (final node in ast.roots) {
      visit(node);
    }
    return params;
  }

  static void _record(
    Map<String, MessageFormatParam> params,
    Map<String, String> dartNameToOriginal,
    String originalName,
    MessageFormatParamType type,
    MessageFormatFormatter formatter,
    String? style,
  ) {
    final dartName = CaseUtil.getCamelcase(originalName);
    final existing = params[originalName];
    if (existing != null) {
      if (existing.dartType != type) {
        throw MessageFormatParamConflictException(
            'Param "$originalName" used with incompatible types '
            '(${existing.dartType.name} vs ${type.name})');
      }
      return;
    }
    final collidingOriginal = dartNameToOriginal[dartName];
    if (collidingOriginal != null && collidingOriginal != originalName) {
      throw MessageFormatParamConflictException(
          'Params "$collidingOriginal" and "$originalName" both normalize to "$dartName"');
    }
    dartNameToOriginal[dartName] = originalName;
    params[originalName] = MessageFormatParam(
      originalName: originalName,
      dartName: dartName,
      dartType: type,
      formatter: formatter,
      formatterStyle: style,
    );
  }

  static MessageFormatFormatter _numberFormatter(String? style) {
    if (style == null) return MessageFormatFormatter.numberDecimal;
    if (style == 'percent') return MessageFormatFormatter.numberPercent;
    if (style == 'currency') return MessageFormatFormatter.numberCurrency;
    return MessageFormatFormatter.numberCustom;
  }

  static MessageFormatFormatter _dateFormatter(String? style) {
    switch (style) {
      case null:
      case 'short':
        return MessageFormatFormatter.dateShort;
      case 'medium':
        return MessageFormatFormatter.dateMedium;
      case 'long':
        return MessageFormatFormatter.dateLong;
      case 'full':
        return MessageFormatFormatter.dateFull;
      default:
        return MessageFormatFormatter.dateCustom;
    }
  }

  static MessageFormatFormatter _timeFormatter(String? style) {
    switch (style) {
      case null:
      case 'short':
        return MessageFormatFormatter.timeShort;
      case 'medium':
        return MessageFormatFormatter.timeMedium;
      case 'long':
        return MessageFormatFormatter.timeLong;
      case 'full':
        return MessageFormatFormatter.timeFull;
      default:
        return MessageFormatFormatter.timeCustom;
    }
  }

  static MessageFormatFormatter _durationFormatter(String? style) {
    switch (style) {
      case null:
      case 'medium':
        return MessageFormatFormatter.durationMedium;
      case 'short':
        return MessageFormatFormatter.durationShort;
      case 'long':
        return MessageFormatFormatter.durationLong;
      default:
        return MessageFormatFormatter.durationCustom;
    }
  }
}
