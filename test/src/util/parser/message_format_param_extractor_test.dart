import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';
import 'package:locale_gen/src/util/parser/message_format_param_extractor.dart';
import 'package:test/test.dart';

void main() {
  group('MessageFormatParamExtractor', () {
    test('extracts a single placeholder as a String param', () {
      final ast = MessageFormatParser.parse('Hi, {name}!');
      final params = MessageFormatParamExtractor.extract(ast);
      expect(params.length, 1);
      final p = params.values.first;
      expect(p.originalName, 'name');
      expect(p.dartName, 'name');
      expect(p.dartType, MessageFormatParamType.string);
    });

    test('camelCases uppercase original names', () {
      final ast = MessageFormatParser.parse('See {SC}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.originalName, 'SC');
      expect(p.dartName, 'sc');
    });

    test('preserves first-occurrence order across literals and types', () {
      final ast = MessageFormatParser.parse(
          'I, {profileName}, accept terms at {SC} on {placedAt, date, short}');
      final names = MessageFormatParamExtractor.extract(ast)
          .values
          .map((p) => p.originalName)
          .toList();
      expect(names, ['profileName', 'SC', 'placedAt']);
    });

    test('plural argument becomes a num param', () {
      final ast = MessageFormatParser.parse(
          '{count, plural, one {# item} other {# items}}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.dartType, MessageFormatParamType.num_);
    });

    test('selectordinal becomes a num param', () {
      final ast = MessageFormatParser.parse(
          '{place, selectordinal, one {#st} other {#th}}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.dartType, MessageFormatParamType.num_);
    });

    test('select becomes a String param', () {
      final ast = MessageFormatParser.parse(
          '{gender, select, male {he} female {she} other {they}}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.dartType, MessageFormatParamType.string);
    });

    test('number becomes a num param with formatter info', () {
      final ast = MessageFormatParser.parse('{total, number, currency}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.dartType, MessageFormatParamType.num_);
      expect(p.formatter, MessageFormatFormatter.numberCurrency);
    });

    test('date becomes a DateTime param with style passed through', () {
      final ast = MessageFormatParser.parse('{d, date, short}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.dartType, MessageFormatParamType.dateTime);
      expect(p.formatter, MessageFormatFormatter.dateShort);
    });

    test('duration becomes a Duration param with style stored verbatim', () {
      final ast = MessageFormatParser.parse('{d, duration, mm:ss}');
      final p = MessageFormatParamExtractor.extract(ast).values.first;
      expect(p.dartType, MessageFormatParamType.duration);
      expect(p.formatter, MessageFormatFormatter.durationCustom);
      expect(p.formatterStyle, 'mm:ss');
    });

    test('walks into plural branches to discover nested params', () {
      final ast = MessageFormatParser.parse(
          '{count, plural, one {# item for {name}} other {# items for {name}}}');
      final params = MessageFormatParamExtractor.extract(ast);
      expect(params.keys, ['count', 'name']);
      expect(params['count']!.dartType, MessageFormatParamType.num_);
      expect(params['name']!.dartType, MessageFormatParamType.string);
    });

    test('throws when same param appears with incompatible Dart types', () {
      final ast = MessageFormatParser.parse('{x, number} and {x, date, short}');
      expect(
        () => MessageFormatParamExtractor.extract(ast),
        throwsA(isA<MessageFormatParamConflictException>()),
      );
    });

    test('throws when camelCase normalization collides', () {
      final ast = MessageFormatParser.parse('{SC} and {sc}');
      expect(
        () => MessageFormatParamExtractor.extract(ast),
        throwsA(isA<MessageFormatParamConflictException>()),
      );
    });
  });
}
