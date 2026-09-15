import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/case/case_util.dart';

abstract final class MessageFormatParamExtractor {
  static Map<String, MessageFormatParam> extract(MessageFormatAst ast) {
    final params = <String, MessageFormatParam>{};
    final otherFormats = <String, List<MessageFormatParam>>{};
    final dartNameToOriginal = <String, String>{};

    void record(
      String name,
      MessageFormatParamType type, [
      MessageFormatFormatter formatter = MessageFormatFormatter.none,
      String? style,
    ]) {
      final existing = params[name];
      if (existing != null) {
        if (existing.dartType != type) {
          throw MessageFormatParamConflictException(
              'Param "$name" used with incompatible types '
              '(${existing.dartType.name} vs ${type.name})');
        }
        // The same param in another format, such as the time in
        // `{d, date} at {d, time}`: every format has to be passed on.
        final formats = otherFormats.putIfAbsent(name, () => []);
        final isKnownFormat = [existing, ...formats].any((known) =>
            known.formatter == formatter && known.formatterStyle == style);
        if (!isKnownFormat) {
          formats.add(MessageFormatParam(
            originalName: name,
            dartName: existing.dartName,
            dartType: type,
            formatter: formatter,
            formatterStyle: style,
          ));
        }
        return;
      }
      final dartName = CaseUtil.getCamelcase(name);
      final collidingOriginal = dartNameToOriginal[dartName];
      if (collidingOriginal != null) {
        throw MessageFormatParamConflictException(
            'Params "$collidingOriginal" and "$name" both normalize to "$dartName"');
      }
      dartNameToOriginal[dartName] = name;
      params[name] = MessageFormatParam(
        originalName: name,
        dartName: dartName,
        dartType: type,
        formatter: formatter,
        formatterStyle: style,
      );
    }

    void visit(MessageFormatNode node) {
      switch (node) {
        case LiteralNode():
          break;
        case PlaceholderNode(:final name):
          record(name, MessageFormatParamType.string);
        case PluralNode(:final name, :final branches):
          record(name, MessageFormatParamType.num_);
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case SelectOrdinalNode(:final name, :final branches):
          record(name, MessageFormatParamType.num_);
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case SelectNode(:final name, :final branches):
          record(name, MessageFormatParamType.string);
          for (final list in branches.values) {
            for (final n in list) {
              visit(n);
            }
          }
        case NumberNode(:final name, :final style):
          record(name, MessageFormatParamType.num_, _numberFormatter(style),
              style);
        case DateNode(:final name, :final style):
          record(name, MessageFormatParamType.dateTime, _dateFormatter(style),
              style);
        case TimeNode(:final name, :final style):
          record(name, MessageFormatParamType.dateTime, _timeFormatter(style),
              style);
        case DurationNode(:final name, :final style):
          record(name, MessageFormatParamType.duration,
              _durationFormatter(style), style);
      }
    }

    for (final node in ast.roots) {
      visit(node);
    }
    return {
      for (final MapEntry(key: name, value: param) in params.entries)
        name: MessageFormatParam(
          originalName: param.originalName,
          dartName: param.dartName,
          dartType: param.dartType,
          formatter: param.formatter,
          formatterStyle: param.formatterStyle,
          otherFormats: otherFormats[name] ?? const [],
        ),
    };
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
