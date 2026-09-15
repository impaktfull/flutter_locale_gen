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
}
