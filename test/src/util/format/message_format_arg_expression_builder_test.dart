import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/format/message_format_arg_expression_builder.dart';
import 'package:test/test.dart';

MessageFormatParam _param(MessageFormatFormatter formatter, [String? style]) {
  return MessageFormatParam(
    originalName: 'placed_at',
    dartName: 'placedAt',
    dartType: MessageFormatParamType.string,
    formatter: formatter,
    formatterStyle: style,
  );
}

void main() {
  const locale = "'en'";

  // One expected expression per formatter. The last test fails when a
  // formatter is added without a case here.
  final withoutStyle = <MessageFormatFormatter, String>{
    MessageFormatFormatter.none: 'placedAt',
    MessageFormatFormatter.numberDecimal:
        "NumberFormat.decimalPattern('en').format(placedAt)",
    MessageFormatFormatter.numberPercent:
        "NumberFormat.percentPattern('en').format(placedAt)",
    MessageFormatFormatter.numberCurrency:
        "NumberFormat.simpleCurrency(locale: 'en').format(placedAt)",
    MessageFormatFormatter.dateShort: "DateFormat.yMd('en').format(placedAt)",
    MessageFormatFormatter.dateMedium:
        "DateFormat.yMMMd('en').format(placedAt)",
    MessageFormatFormatter.dateLong: "DateFormat.yMMMMd('en').format(placedAt)",
    MessageFormatFormatter.dateFull:
        "DateFormat.yMMMMEEEEd('en').format(placedAt)",
    MessageFormatFormatter.timeShort: "DateFormat.jm('en').format(placedAt)",
    MessageFormatFormatter.timeMedium: "DateFormat.jms('en').format(placedAt)",
    MessageFormatFormatter.timeLong: "DateFormat.jms('en').format(placedAt)",
    MessageFormatFormatter.timeFull: "DateFormat.jms('en').format(placedAt)",
    MessageFormatFormatter.durationDefault: '_formatDuration(placedAt, null)',
    MessageFormatFormatter.durationMedium: '_formatDuration(placedAt, null)',
    MessageFormatFormatter.durationShort: "_formatDuration(placedAt, 'short')",
    MessageFormatFormatter.durationLong: "_formatDuration(placedAt, 'long')",
  };
  final withStyle = <MessageFormatFormatter, (String, String)>{
    MessageFormatFormatter.numberCustom: (
      '#,##0.0',
      "NumberFormat('#,##0.0', 'en').format(placedAt)",
    ),
    MessageFormatFormatter.dateCustom: (
      'dd/MM/yyyy',
      "DateFormat('dd/MM/yyyy', 'en').format(placedAt)",
    ),
    MessageFormatFormatter.timeCustom: (
      'HH:mm',
      "DateFormat('HH:mm', 'en').format(placedAt)",
    ),
    MessageFormatFormatter.durationCustom: (
      'mm:ss',
      "_formatDuration(placedAt, 'mm:ss')",
    ),
  };

  group('MessageFormatArgExpressionBuilder.build', () {
    withoutStyle.forEach((formatter, expected) {
      test(formatter.name, () {
        expect(
            MessageFormatArgExpressionBuilder.build(_param(formatter), locale),
            expected);
      });
    });

    withStyle.forEach((formatter, styleAndExpected) {
      final (style, expected) = styleAndExpected;
      test('${formatter.name} with style "$style"', () {
        expect(
            MessageFormatArgExpressionBuilder.build(
                _param(formatter, style), locale),
            expected);
      });
    });

    test('escapes quotes and backslashes in a custom style', () {
      expect(
        MessageFormatArgExpressionBuilder.build(
            _param(MessageFormatFormatter.dateCustom, r"h 'o''clock' \"),
            locale),
        r"DateFormat('h \'o\'\'clock\' \\', 'en').format(placedAt)",
      );
    });

    test('uses an empty pattern when a custom formatter has no style', () {
      expect(
        MessageFormatArgExpressionBuilder.build(
            _param(MessageFormatFormatter.numberCustom), locale),
        "NumberFormat('', 'en').format(placedAt)",
      );
    });

    test('uses the locale expression as given', () {
      expect(
        MessageFormatArgExpressionBuilder.build(
            _param(MessageFormatFormatter.dateShort),
            'locale?.toLanguageTag()'),
        'DateFormat.yMd(locale?.toLanguageTag()).format(placedAt)',
      );
    });

    test('has a case for every formatter', () {
      expect(
        {...withoutStyle.keys, ...withStyle.keys},
        MessageFormatFormatter.values.toSet(),
      );
    });
  });
}
