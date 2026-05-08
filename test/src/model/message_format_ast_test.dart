import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:test/test.dart';

void main() {
  group('MessageFormatAst node construction', () {
    test('LiteralNode exposes its text', () {
      const node = LiteralNode('hello');
      expect(node.text, 'hello');
    });

    test('PlaceholderNode exposes its name', () {
      const node = PlaceholderNode('profileName');
      expect(node.name, 'profileName');
    });

    test('PluralNode exposes name and branches', () {
      const node = PluralNode(
        name: 'count',
        branches: {
          'one': [LiteralNode('# item')],
          'other': [LiteralNode('# items')],
        },
      );
      expect(node.name, 'count');
      expect(node.branches.keys, ['one', 'other']);
      expect((node.branches['one']!.first as LiteralNode).text, '# item');
    });

    test('SelectNode exposes name and branches', () {
      const node = SelectNode(
        name: 'gender',
        branches: {
          'male': [LiteralNode('he')],
          'female': [LiteralNode('she')],
          'other': [LiteralNode('they')],
        },
      );
      expect(node.name, 'gender');
      expect(node.branches.length, 3);
    });

    test('SelectOrdinalNode exposes name and branches', () {
      const node = SelectOrdinalNode(
        name: 'place',
        branches: {
          'one': [LiteralNode('#st')],
          'two': [LiteralNode('#nd')],
          'few': [LiteralNode('#rd')],
          'other': [LiteralNode('#th')],
        },
      );
      expect(node.name, 'place');
      expect(node.branches['one']!.length, 1);
    });

    test('NumberNode exposes name and style', () {
      const node = NumberNode(name: 'total', style: 'currency');
      expect(node.name, 'total');
      expect(node.style, 'currency');
    });

    test('DateNode exposes name and style', () {
      const node = DateNode(name: 'placedAt', style: 'short');
      expect(node.name, 'placedAt');
      expect(node.style, 'short');
    });

    test('TimeNode exposes name and style', () {
      const node = TimeNode(name: 't', style: 'medium');
      expect(node.name, 't');
      expect(node.style, 'medium');
    });

    test('DurationNode exposes name and style', () {
      const node = DurationNode(name: 'd', style: null);
      expect(node.name, 'd');
      expect(node.style, isNull);
    });

    test('MessageFormatAst exposes its root nodes', () {
      const ast = MessageFormatAst(roots: [
        LiteralNode('hello, '),
        PlaceholderNode('name'),
      ]);
      expect(ast.roots.length, 2);
      expect((ast.roots.first as LiteralNode).text, 'hello, ');
    });
  });
}
