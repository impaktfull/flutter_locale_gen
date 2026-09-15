import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/format/message_format_util.dart';
import 'package:test/test.dart';

void main() {
  group('MessageFormatUtil.dartTypeFor', () {
    test('maps every parameter type to its Dart type', () {
      expect(
        {
          for (final type in MessageFormatParamType.values)
            type: MessageFormatUtil.dartTypeFor(type),
        },
        {
          MessageFormatParamType.string: 'String',
          MessageFormatParamType.num_: 'num',
          MessageFormatParamType.dateTime: 'DateTime',
          MessageFormatParamType.duration: 'Duration',
        },
      );
    });
  });

  group('MessageFormatUtil.escapeForSingleQuotedString', () {
    test('escapes backslashes and single quotes', () {
      expect(MessageFormatUtil.escapeForSingleQuotedString(r"it's a \ path"),
          r"it\'s a \\ path");
    });

    test('leaves other text untouched', () {
      expect(MessageFormatUtil.escapeForSingleQuotedString('mm:ss'), 'mm:ss');
    });
  });

  group('MessageFormatUtil.hasMessageFormatKeys', () {
    test('is true when one value uses MessageFormat', () {
      expect(
        MessageFormatUtil.hasMessageFormatKeys({
          'title': 'Title',
          'greeting': 'Hi, {name}!',
        }),
        isTrue,
      );
    });

    test('ignores sprintf values, plain values and JSON-object plurals', () {
      expect(
        MessageFormatUtil.hasMessageFormatKeys({
          'title': 'Title',
          'welcome': 'Welcome %1\$s',
          'hours': {'one': '{%d} hour', 'other': '%d hours'},
        }),
        isFalse,
      );
    });
  });

  group('MessageFormatUtil.hasDurationKeys', () {
    test('is true for a top-level duration', () {
      expect(
          MessageFormatUtil.hasDurationKeys({'lap': '{d, duration}'}), isTrue);
    });

    test('is true for a duration nested in a branch', () {
      expect(
        MessageFormatUtil.hasDurationKeys({
          'laps': '{count, plural, one {Lap {d, duration}} other {# laps}}',
        }),
        isTrue,
      );
    });

    test('is false without a duration', () {
      expect(
        MessageFormatUtil.hasDurationKeys({
          'greeting': 'Hi, {name}!',
          'welcome': 'Welcome %1\$s',
          'hours': {'one': '1 hour', 'other': '%d hours'},
        }),
        isFalse,
      );
    });

    test('is false for a value that does not parse', () {
      expect(MessageFormatUtil.hasDurationKeys({'broken': '{d, duration'}),
          isFalse);
    });
  });

  group('MessageFormatUtil.astContainsDuration', () {
    test('looks through plural, selectordinal and select branches', () {
      const duration = DurationNode(name: 'd', style: null);
      for (final node in <MessageFormatNode>[
        const PluralNode(name: 'n', branches: {
          'other': [duration],
        }),
        const SelectOrdinalNode(name: 'n', branches: {
          'other': [duration],
        }),
        const SelectNode(name: 's', branches: {
          'other': [LiteralNode('a'), duration],
        }),
      ]) {
        expect(
          MessageFormatUtil.astContainsDuration(
              MessageFormatAst(roots: [node])),
          isTrue,
          reason: '${node.runtimeType}',
        );
      }
    });

    test('is false for branches without a duration', () {
      expect(
        MessageFormatUtil.astContainsDuration(const MessageFormatAst(roots: [
          PluralNode(name: 'n', branches: {
            'one': [LiteralNode('one')],
            'other': [PlaceholderNode('x')],
          }),
        ])),
        isFalse,
      );
    });
  });

  group('templates', () {
    test('define the helpers the generated code calls', () {
      expect(MessageFormatUtil.durationHelperTemplate,
          contains('String _formatDuration(Duration d, String? style)'));
      expect(
          MessageFormatUtil.formatSpecsHelperTemplate,
          contains('String _resolveFormatSpecs(String value, '
              'Map<String, Object> args, Map<String, Object> resolvedArgs)'));
    });
  });
}
