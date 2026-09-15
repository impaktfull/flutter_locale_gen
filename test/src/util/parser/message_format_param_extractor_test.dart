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

    test('a repeated param with the same type is one param', () {
      final ast = MessageFormatParser.parse('{name} and {name}');
      expect(MessageFormatParamExtractor.extract(ast).keys, ['name']);
    });
  });

  group('MessageFormatParamExtractor with a param in several formats', () {
    MessageFormatParam extractSingle(String message) =>
        MessageFormatParamExtractor.extract(MessageFormatParser.parse(message))
            .values
            .single;

    test('keeps the first format and lists the others', () {
      final param = extractSingle('{d, date, medium} at {d, time, short}');
      expect(param.formatter, MessageFormatFormatter.dateMedium);
      expect(param.formatterStyle, 'medium');
      expect(
        param.otherFormats.map((f) => (f.formatter, f.formatterStyle)),
        [(MessageFormatFormatter.timeShort, 'short')],
      );
    });

    test('lists a repeated format once', () {
      final param = extractSingle(
          '{d, time, short} to {d, date} or {d, time, short} and {d, date}');
      expect(param.otherFormats.map((f) => f.formatter),
          [MessageFormatFormatter.dateShort]);
    });

    test('lists a format used next to an unformatted use', () {
      final param =
          extractSingle('{n, plural, other {#}} ({n, number, percent})');
      expect(param.formatter, MessageFormatFormatter.none);
      expect(param.otherFormats.map((f) => f.formatter),
          [MessageFormatFormatter.numberPercent]);
    });

    test('keeps the names and the type in every format', () {
      final other = extractSingle('{placed_at, date} {placed_at, time}')
          .otherFormats
          .single;
      expect(other.originalName, 'placed_at');
      expect(other.dartName, 'placedAt');
      expect(other.dartType, MessageFormatParamType.dateTime);
      expect(other.otherFormats, isEmpty);
    });
  });

  group('MessageFormatParamExtractor formatters', () {
    final formatters = {
      '{v, number}': (MessageFormatFormatter.numberDecimal, null),
      '{v, number, percent}': (MessageFormatFormatter.numberPercent, 'percent'),
      '{v, number, currency}': (
        MessageFormatFormatter.numberCurrency,
        'currency'
      ),
      '{v, number, #,##0.0}': (MessageFormatFormatter.numberCustom, '#,##0.0'),
      '{v, date}': (MessageFormatFormatter.dateShort, null),
      '{v, date, short}': (MessageFormatFormatter.dateShort, 'short'),
      '{v, date, medium}': (MessageFormatFormatter.dateMedium, 'medium'),
      '{v, date, long}': (MessageFormatFormatter.dateLong, 'long'),
      '{v, date, full}': (MessageFormatFormatter.dateFull, 'full'),
      '{v, date, dd/MM}': (MessageFormatFormatter.dateCustom, 'dd/MM'),
      '{v, time}': (MessageFormatFormatter.timeShort, null),
      '{v, time, short}': (MessageFormatFormatter.timeShort, 'short'),
      '{v, time, medium}': (MessageFormatFormatter.timeMedium, 'medium'),
      '{v, time, long}': (MessageFormatFormatter.timeLong, 'long'),
      '{v, time, full}': (MessageFormatFormatter.timeFull, 'full'),
      '{v, time, HH:mm}': (MessageFormatFormatter.timeCustom, 'HH:mm'),
      '{v, duration}': (MessageFormatFormatter.durationMedium, null),
      '{v, duration, medium}': (
        MessageFormatFormatter.durationMedium,
        'medium'
      ),
      '{v, duration, short}': (MessageFormatFormatter.durationShort, 'short'),
      '{v, duration, long}': (MessageFormatFormatter.durationLong, 'long'),
      '{v, duration, mm:ss}': (MessageFormatFormatter.durationCustom, 'mm:ss'),
    };

    formatters.forEach((input, expected) {
      final (formatter, style) = expected;
      test('$input uses ${formatter.name}', () {
        final param = MessageFormatParamExtractor.extract(
                MessageFormatParser.parse(input))
            .values
            .single;
        expect(param.formatter, formatter);
        expect(param.formatterStyle, style);
      });
    });
  });
}
