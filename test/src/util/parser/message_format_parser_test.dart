import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';
import 'package:test/test.dart';

void main() {
  group('MessageFormatParser placeholders and literals', () {
    test('parses a string with no placeholders as a single literal', () {
      final ast = MessageFormatParser.parse('hello world');
      expect(ast.roots.length, 1);
      expect((ast.roots.first as LiteralNode).text, 'hello world');
    });

    test('parses a single placeholder', () {
      final ast = MessageFormatParser.parse('{name}');
      expect(ast.roots.length, 1);
      expect((ast.roots.first as PlaceholderNode).name, 'name');
    });

    test('parses literal-then-placeholder-then-literal', () {
      final ast = MessageFormatParser.parse('Hi, {name}!');
      expect(ast.roots.length, 3);
      expect((ast.roots[0] as LiteralNode).text, 'Hi, ');
      expect((ast.roots[1] as PlaceholderNode).name, 'name');
      expect((ast.roots[2] as LiteralNode).text, '!');
    });

    test('parses two placeholders separated by literal', () {
      final ast = MessageFormatParser.parse('{a} and {b}');
      expect(ast.roots.length, 4);
      expect((ast.roots[0] as PlaceholderNode).name, 'a');
      expect((ast.roots[1] as LiteralNode).text, ' and ');
      expect((ast.roots[2] as PlaceholderNode).name, 'b');
      expect((ast.roots[3] as LiteralNode).text, '');
    });

    test('throws on unclosed brace', () {
      expect(
        () => MessageFormatParser.parse('hi {name'),
        throwsA(isA<MessageFormatParseException>()),
      );
    });

    test('throws on stray closing brace', () {
      expect(
        () => MessageFormatParser.parse('hi name}'),
        throwsA(isA<MessageFormatParseException>()),
      );
    });

    test('throws on empty placeholder name', () {
      expect(
        () => MessageFormatParser.parse('hi {}'),
        throwsA(isA<MessageFormatParseException>()),
      );
    });
  });

  group('MessageFormatParser typed scalars', () {
    test('parses {n, number}', () {
      final ast = MessageFormatParser.parse('{n, number}');
      final node = ast.roots.first as NumberNode;
      expect(node.name, 'n');
      expect(node.style, isNull);
    });

    test('parses {n, number, percent}', () {
      final ast = MessageFormatParser.parse('{n, number, percent}');
      final node = ast.roots.first as NumberNode;
      expect(node.name, 'n');
      expect(node.style, 'percent');
    });

    test('parses {d, date, short}', () {
      final ast = MessageFormatParser.parse('{d, date, short}');
      final node = ast.roots.first as DateNode;
      expect(node.name, 'd');
      expect(node.style, 'short');
    });

    test('parses {t, time, medium}', () {
      final ast = MessageFormatParser.parse('{t, time, medium}');
      final node = ast.roots.first as TimeNode;
      expect(node.style, 'medium');
    });

    test('parses {d, duration} with no style', () {
      final ast = MessageFormatParser.parse('{d, duration}');
      final node = ast.roots.first as DurationNode;
      expect(node.style, isNull);
    });

    test('parses {d, duration, HH:mm:ss} preserving the custom pattern', () {
      final ast = MessageFormatParser.parse('{d, duration, HH:mm:ss}');
      final node = ast.roots.first as DurationNode;
      expect(node.style, 'HH:mm:ss');
    });

    test('throws on unknown arg type', () {
      expect(
        () => MessageFormatParser.parse('{x, mystery}'),
        throwsA(isA<MessageFormatParseException>()),
      );
    });
  });
}
