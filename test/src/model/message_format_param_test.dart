import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:test/test.dart';

void main() {
  test('MessageFormatParam keeps its values', () {
    const param = MessageFormatParam(
      originalName: 'placed_at',
      dartName: 'placedAt',
      dartType: MessageFormatParamType.dateTime,
      formatter: MessageFormatFormatter.dateCustom,
      formatterStyle: 'dd/MM',
    );

    expect(param.originalName, 'placed_at');
    expect(param.dartName, 'placedAt');
    expect(param.dartType, MessageFormatParamType.dateTime);
    expect(param.formatter, MessageFormatFormatter.dateCustom);
    expect(param.formatterStyle, 'dd/MM');
  });

  test('MessageFormatParamConflictException describes the conflict', () {
    const exception = MessageFormatParamConflictException('two types');

    expect(exception.message, 'two types');
    expect(
        exception.toString(), 'MessageFormatParamConflictException: two types');
  });

  test('MessageFormatParam has no other formats by default', () {
    const param = MessageFormatParam(
      originalName: 'n',
      dartName: 'n',
      dartType: MessageFormatParamType.num_,
      formatter: MessageFormatFormatter.none,
    );

    expect(param.otherFormats, isEmpty);
  });

  group('MessageFormatParam.formatKey', () {
    MessageFormatParam format(MessageFormatFormatter formatter,
            [String? style]) =>
        MessageFormatParam(
          originalName: 'placed_at',
          dartName: 'placedAt',
          dartType: MessageFormatParamType.dateTime,
          formatter: formatter,
          formatterStyle: style,
        );

    test('joins the name, the ICU type and the style', () {
      expect(format(MessageFormatFormatter.dateMedium, 'medium').formatKey,
          'placed_at|date|medium');
    });

    test('leaves the style empty when there is none', () {
      expect(format(MessageFormatFormatter.numberDecimal).formatKey,
          'placed_at|number|');
    });

    test('uses the ICU type of every formatter', () {
      expect(
        {
          for (final formatter in MessageFormatFormatter.values)
            formatter: format(formatter).formatKey.split('|')[1],
        },
        {
          MessageFormatFormatter.none: '',
          MessageFormatFormatter.numberDecimal: 'number',
          MessageFormatFormatter.numberPercent: 'number',
          MessageFormatFormatter.numberCurrency: 'number',
          MessageFormatFormatter.numberCustom: 'number',
          MessageFormatFormatter.dateShort: 'date',
          MessageFormatFormatter.dateMedium: 'date',
          MessageFormatFormatter.dateLong: 'date',
          MessageFormatFormatter.dateFull: 'date',
          MessageFormatFormatter.dateCustom: 'date',
          MessageFormatFormatter.timeShort: 'time',
          MessageFormatFormatter.timeMedium: 'time',
          MessageFormatFormatter.timeLong: 'time',
          MessageFormatFormatter.timeFull: 'time',
          MessageFormatFormatter.timeCustom: 'time',
          MessageFormatFormatter.durationDefault: 'duration',
          MessageFormatFormatter.durationShort: 'duration',
          MessageFormatFormatter.durationMedium: 'duration',
          MessageFormatFormatter.durationLong: 'duration',
          MessageFormatFormatter.durationCustom: 'duration',
        },
      );
    });
  });
}
