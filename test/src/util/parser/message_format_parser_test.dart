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
}
