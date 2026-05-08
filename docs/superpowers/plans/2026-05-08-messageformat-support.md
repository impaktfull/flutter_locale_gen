# MessageFormat (ICU) Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add ICU MessageFormat parsing to `flutter_locale_gen` so JSON values like `{count, plural, one {# item} other {# items}}` and `Hi, {profileName}, see <a href="{SC}">link</a>` produce typed Dart functions, while preserving existing sprintf and JSON-object plural support.

**Architecture:** A new ICU parser turns MessageFormat strings into a strongly-typed AST. A param-discovery pass walks the AST of the default-language translation to derive Dart parameter names and types. The core generator detects which style each JSON value uses (sprintf, JSON-plural, MessageFormat) and dispatches to the right code-emission path. Generated code uses `package:intl`'s `MessageFormat` class at runtime, with date/time/number/duration values pre-formatted in Dart before substitution. A cross-locale validator emits warnings when locales disagree about the param set or ICU node type for a key.

**Tech Stack:** Dart 3 (sealed classes), `package:test`, `package:intl` (runtime, already a dep), `package:meta`, `package:yaml`.

**Spec:** [docs/superpowers/specs/2026-05-08-messageformat-support-design.md](../specs/2026-05-08-messageformat-support-design.md)

**Conventions:**
- Tests live under `test/src/...` mirroring `lib/src/...`. The existing tree uses the directory name `test/src/writor/` (typo of "writer"). Match that spelling for new files under that subtree.
- Run all tests with `dart test` from the repo root.
- Each task ends with a commit. Use Conventional Commit prefixes (`feat:`, `fix:`, `test:`, `docs:`, `refactor:`).
- Do **not** include any of the user's private translation strings in tests, fixtures, README, or commits. Use only invented examples.

---

## Task 1: Define MessageFormat AST node types

**Files:**
- Create: `lib/src/model/message_format_ast.dart`
- Test: `test/src/model/message_format_ast_test.dart`

The AST is the contract between the parser, the param-discovery pass, the generator, and the cross-locale validator. Defining it first lets every later task be tested in isolation.

- [ ] **Step 1: Write the failing test**

Create `test/src/model/message_format_ast_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/model/message_format_ast_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:locale_gen/src/model/message_format_ast.dart'`.

- [ ] **Step 3: Implement the AST**

Create `lib/src/model/message_format_ast.dart`:

```dart
sealed class MessageFormatNode {
  const MessageFormatNode();
}

class LiteralNode extends MessageFormatNode {
  final String text;
  const LiteralNode(this.text);
}

class PlaceholderNode extends MessageFormatNode {
  final String name;
  const PlaceholderNode(this.name);
}

class PluralNode extends MessageFormatNode {
  final String name;
  final Map<String, List<MessageFormatNode>> branches;
  const PluralNode({required this.name, required this.branches});
}

class SelectOrdinalNode extends MessageFormatNode {
  final String name;
  final Map<String, List<MessageFormatNode>> branches;
  const SelectOrdinalNode({required this.name, required this.branches});
}

class SelectNode extends MessageFormatNode {
  final String name;
  final Map<String, List<MessageFormatNode>> branches;
  const SelectNode({required this.name, required this.branches});
}

class NumberNode extends MessageFormatNode {
  final String name;
  final String? style;
  const NumberNode({required this.name, required this.style});
}

class DateNode extends MessageFormatNode {
  final String name;
  final String? style;
  const DateNode({required this.name, required this.style});
}

class TimeNode extends MessageFormatNode {
  final String name;
  final String? style;
  const TimeNode({required this.name, required this.style});
}

class DurationNode extends MessageFormatNode {
  final String name;
  final String? style;
  const DurationNode({required this.name, required this.style});
}

class MessageFormatAst {
  final List<MessageFormatNode> roots;
  const MessageFormatAst({required this.roots});
}

class MessageFormatParseException implements Exception {
  final String message;
  const MessageFormatParseException(this.message);
  @override
  String toString() => 'MessageFormatParseException: $message';
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/model/message_format_ast_test.dart`
Expected: PASS — 10 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/model/message_format_ast.dart test/src/model/message_format_ast_test.dart
git commit -m "feat: add MessageFormat AST node model"
```

---

## Task 2: Parse plain placeholders and literals

**Files:**
- Create: `lib/src/util/parser/message_format_parser.dart`
- Test: `test/src/util/parser/message_format_parser_test.dart`

Smallest useful slice: parse strings that contain only literal text and `{name}` placeholders.

- [ ] **Step 1: Write the failing test**

Create `test/src/util/parser/message_format_parser_test.dart`:

```dart
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
```

Note: the "two placeholders separated by literal" test asserts a trailing empty literal — that's the parser's normal output when a placeholder ends the string mid-segment. Keeping it explicit here so later tests can rely on a stable shape.

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: FAIL with `Target of URI doesn't exist: 'package:locale_gen/src/util/parser/message_format_parser.dart'`.

- [ ] **Step 3: Implement minimal parser**

Create `lib/src/util/parser/message_format_parser.dart`:

```dart
import 'package:locale_gen/src/model/message_format_ast.dart';

class MessageFormatParser {
  const MessageFormatParser._();

  static MessageFormatAst parse(String input) {
    final cursor = _Cursor(input);
    final nodes = _parseNodes(cursor, depth: 0);
    if (!cursor.isAtEnd) {
      throw MessageFormatParseException(
          'Unexpected character at position ${cursor.position}: ${cursor.peek()}');
    }
    return MessageFormatAst(roots: nodes);
  }

  static List<MessageFormatNode> _parseNodes(_Cursor cursor,
      {required int depth}) {
    final nodes = <MessageFormatNode>[];
    final literal = StringBuffer();

    void flushLiteral() {
      nodes.add(LiteralNode(literal.toString()));
      literal.clear();
    }

    while (!cursor.isAtEnd) {
      final ch = cursor.peek();
      if (ch == '{') {
        flushLiteral();
        nodes.add(_parsePlaceholder(cursor));
        continue;
      }
      if (ch == '}') {
        if (depth == 0) {
          throw MessageFormatParseException(
              'Unmatched closing brace at position ${cursor.position}');
        }
        break;
      }
      literal.write(ch);
      cursor.advance();
    }

    if (depth == 0 && !cursor.isAtEnd && cursor.peek() == '}') {
      throw MessageFormatParseException(
          'Unmatched closing brace at position ${cursor.position}');
    }

    flushLiteral();
    return nodes;
  }

  static MessageFormatNode _parsePlaceholder(_Cursor cursor) {
    cursor.expect('{');
    cursor.skipWhitespace();
    final name = cursor.readIdentifier();
    if (name.isEmpty) {
      throw MessageFormatParseException(
          'Empty placeholder name at position ${cursor.position}');
    }
    cursor.skipWhitespace();
    if (cursor.isAtEnd) {
      throw MessageFormatParseException(
          'Unclosed placeholder for "$name"');
    }
    final after = cursor.peek();
    if (after == '}') {
      cursor.advance();
      return PlaceholderNode(name);
    }
    throw MessageFormatParseException(
        'Expected "}" after placeholder name "$name" at position ${cursor.position}');
  }
}

class _Cursor {
  final String _input;
  int _pos = 0;
  _Cursor(this._input);

  int get position => _pos;
  bool get isAtEnd => _pos >= _input.length;
  String peek() => _input[_pos];
  void advance() => _pos++;

  void expect(String char) {
    if (isAtEnd || _input[_pos] != char) {
      throw MessageFormatParseException(
          'Expected "$char" at position $_pos');
    }
    _pos++;
  }

  void skipWhitespace() {
    while (!isAtEnd && _isWhitespace(_input[_pos])) {
      _pos++;
    }
  }

  String readIdentifier() {
    final start = _pos;
    while (!isAtEnd && _isIdentifierChar(_input[_pos])) {
      _pos++;
    }
    return _input.substring(start, _pos);
  }

  static bool _isWhitespace(String c) => c == ' ' || c == '\t' || c == '\n' || c == '\r';

  static bool _isIdentifierChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || // A-Z
        (code >= 0x61 && code <= 0x7A) || // a-z
        (code >= 0x30 && code <= 0x39) || // 0-9
        c == '_';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: PASS — 7 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/util/parser/message_format_parser.dart test/src/util/parser/message_format_parser_test.dart
git commit -m "feat: parse MessageFormat placeholders and literals"
```

---

## Task 3: Parse number, date, time, and duration arg types

**Files:**
- Modify: `lib/src/util/parser/message_format_parser.dart`
- Modify: `test/src/util/parser/message_format_parser_test.dart`

Extend `_parsePlaceholder` to recognize `{name, type}` and `{name, type, style}` forms for the four typed scalars.

- [ ] **Step 1: Write the failing tests**

Append a new group to `test/src/util/parser/message_format_parser_test.dart` after the existing `group` block, before the closing `}` of `main()`:

```dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: FAIL — the new tests blow up because `_parsePlaceholder` doesn't handle commas.

- [ ] **Step 3: Extend the parser**

Replace the `_parsePlaceholder` method in `lib/src/util/parser/message_format_parser.dart` with:

```dart
  static MessageFormatNode _parsePlaceholder(_Cursor cursor) {
    cursor.expect('{');
    cursor.skipWhitespace();
    final name = cursor.readIdentifier();
    if (name.isEmpty) {
      throw MessageFormatParseException(
          'Empty placeholder name at position ${cursor.position}');
    }
    cursor.skipWhitespace();
    if (cursor.isAtEnd) {
      throw MessageFormatParseException('Unclosed placeholder for "$name"');
    }
    final after = cursor.peek();
    if (after == '}') {
      cursor.advance();
      return PlaceholderNode(name);
    }
    if (after != ',') {
      throw MessageFormatParseException(
          'Expected "," or "}" after placeholder name "$name" at position ${cursor.position}');
    }
    cursor.advance(); // consume ','
    cursor.skipWhitespace();
    final argType = cursor.readIdentifier();
    if (argType.isEmpty) {
      throw MessageFormatParseException(
          'Expected arg type after "," for placeholder "$name"');
    }
    cursor.skipWhitespace();
    return _parseTypedPlaceholder(cursor, name, argType);
  }

  static MessageFormatNode _parseTypedPlaceholder(
      _Cursor cursor, String name, String argType) {
    switch (argType) {
      case 'number':
        return _parseScalarTyped(cursor, name, argType);
      case 'date':
        return _parseScalarTyped(cursor, name, argType);
      case 'time':
        return _parseScalarTyped(cursor, name, argType);
      case 'duration':
        return _parseScalarTyped(cursor, name, argType);
      case 'plural':
      case 'select':
      case 'selectordinal':
        throw MessageFormatParseException(
            'Sub-message arg type "$argType" not yet supported in this parser stage');
      default:
        throw MessageFormatParseException(
            'Unknown arg type "$argType" for placeholder "$name"');
    }
  }

  static MessageFormatNode _parseScalarTyped(
      _Cursor cursor, String name, String argType) {
    String? style;
    if (!cursor.isAtEnd && cursor.peek() == ',') {
      cursor.advance();
      cursor.skipWhitespace();
      final styleBuffer = StringBuffer();
      while (!cursor.isAtEnd && cursor.peek() != '}') {
        styleBuffer.write(cursor.peek());
        cursor.advance();
      }
      style = styleBuffer.toString().trim();
      if (style.isEmpty) style = null;
    }
    if (cursor.isAtEnd) {
      throw MessageFormatParseException('Unclosed "$argType" arg for "$name"');
    }
    cursor.expect('}');
    switch (argType) {
      case 'number':
        return NumberNode(name: name, style: style);
      case 'date':
        return DateNode(name: name, style: style);
      case 'time':
        return TimeNode(name: name, style: style);
      case 'duration':
        return DurationNode(name: name, style: style);
    }
    throw StateError('unreachable');
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: PASS — 14 tests total (7 from Task 2 + 7 new).

- [ ] **Step 5: Commit**

```bash
git add lib/src/util/parser/message_format_parser.dart test/src/util/parser/message_format_parser_test.dart
git commit -m "feat: parse number/date/time/duration ICU arg types"
```

---

## Task 4: Parse plural, select, and selectordinal sub-messages

**Files:**
- Modify: `lib/src/util/parser/message_format_parser.dart`
- Modify: `test/src/util/parser/message_format_parser_test.dart`

Sub-messages have nested `{branchKey {sub-template}}` shapes and recursively contain other nodes (including other sub-messages).

- [ ] **Step 1: Write the failing tests**

Append a new group to `test/src/util/parser/message_format_parser_test.dart`:

```dart
  group('MessageFormatParser sub-messages', () {
    test('parses a simple plural', () {
      final ast = MessageFormatParser.parse(
          '{count, plural, one {# item} other {# items}}');
      final node = ast.roots.first as PluralNode;
      expect(node.name, 'count');
      expect(node.branches.keys, ['one', 'other']);
      expect((node.branches['one']!.first as LiteralNode).text, '# item');
      expect((node.branches['other']!.first as LiteralNode).text, '# items');
    });

    test('parses a plural with =N exact-match branches', () {
      final ast = MessageFormatParser.parse(
          '{n, plural, =0 {none} =1 {one} other {many}}');
      final node = ast.roots.first as PluralNode;
      expect(node.branches.keys, ['=0', '=1', 'other']);
    });

    test('parses a select with three branches', () {
      final ast = MessageFormatParser.parse(
          '{gender, select, male {he} female {she} other {they}}');
      final node = ast.roots.first as SelectNode;
      expect(node.branches.keys, ['male', 'female', 'other']);
      expect((node.branches['female']!.first as LiteralNode).text, 'she');
    });

    test('parses a selectordinal', () {
      final ast = MessageFormatParser.parse(
          '{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}');
      final node = ast.roots.first as SelectOrdinalNode;
      expect(node.branches.length, 4);
    });

    test('parses a placeholder nested inside a plural branch', () {
      final ast = MessageFormatParser.parse(
          '{count, plural, one {# item for {name}} other {# items for {name}}}');
      final node = ast.roots.first as PluralNode;
      final oneBranch = node.branches['one']!;
      expect(oneBranch.length, 3);
      expect((oneBranch[0] as LiteralNode).text, '# item for ');
      expect((oneBranch[1] as PlaceholderNode).name, 'name');
      expect((oneBranch[2] as LiteralNode).text, '');
    });

    test('throws when plural has no other branch', () {
      expect(
        () => MessageFormatParser.parse('{count, plural, one {# item}}'),
        throwsA(isA<MessageFormatParseException>()),
      );
    });

    test('throws when select has no other branch', () {
      expect(
        () => MessageFormatParser.parse('{g, select, male {he} female {she}}'),
        throwsA(isA<MessageFormatParseException>()),
      );
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: FAIL — sub-message arg types currently throw.

- [ ] **Step 3: Implement sub-message parsing**

Replace the `_parseTypedPlaceholder` method body (the `case 'plural':` etc. branches) with full parsing. The full updated method is:

```dart
  static MessageFormatNode _parseTypedPlaceholder(
      _Cursor cursor, String name, String argType) {
    switch (argType) {
      case 'number':
      case 'date':
      case 'time':
      case 'duration':
        return _parseScalarTyped(cursor, name, argType);
      case 'plural':
      case 'select':
      case 'selectordinal':
        return _parseSubMessage(cursor, name, argType);
      default:
        throw MessageFormatParseException(
            'Unknown arg type "$argType" for placeholder "$name"');
    }
  }

  static MessageFormatNode _parseSubMessage(
      _Cursor cursor, String name, String argType) {
    if (cursor.isAtEnd || cursor.peek() != ',') {
      throw MessageFormatParseException(
          'Expected "," before "$argType" branches for "$name"');
    }
    cursor.advance(); // consume ','
    cursor.skipWhitespace();
    final branches = <String, List<MessageFormatNode>>{};
    while (!cursor.isAtEnd && cursor.peek() != '}') {
      final key = _readBranchKey(cursor);
      cursor.skipWhitespace();
      if (cursor.isAtEnd || cursor.peek() != '{') {
        throw MessageFormatParseException(
            'Expected "{" after branch key "$key" in "$name"');
      }
      cursor.advance(); // consume '{'
      final subNodes = _parseNodes(cursor, depth: 1);
      if (cursor.isAtEnd || cursor.peek() != '}') {
        throw MessageFormatParseException(
            'Unclosed branch "$key" in "$name"');
      }
      cursor.advance(); // consume '}'
      branches[key] = subNodes;
      cursor.skipWhitespace();
    }
    if (cursor.isAtEnd) {
      throw MessageFormatParseException('Unclosed "$argType" arg for "$name"');
    }
    cursor.expect('}');
    if (!branches.containsKey('other')) {
      throw MessageFormatParseException(
          '"$argType" for "$name" must include an "other" branch');
    }
    switch (argType) {
      case 'plural':
        return PluralNode(name: name, branches: branches);
      case 'select':
        return SelectNode(name: name, branches: branches);
      case 'selectordinal':
        return SelectOrdinalNode(name: name, branches: branches);
    }
    throw StateError('unreachable');
  }

  static String _readBranchKey(_Cursor cursor) {
    cursor.skipWhitespace();
    if (cursor.isAtEnd) {
      throw MessageFormatParseException('Expected branch key, got end of input');
    }
    final start = cursor.position;
    if (cursor.peek() == '=') {
      cursor.advance();
      while (!cursor.isAtEnd && _isDigit(cursor.peek())) {
        cursor.advance();
      }
      return cursor.substringFrom(start);
    }
    while (!cursor.isAtEnd && _isBranchKeyChar(cursor.peek())) {
      cursor.advance();
    }
    final key = cursor.substringFrom(start);
    if (key.isEmpty) {
      throw MessageFormatParseException(
          'Expected branch key at position ${cursor.position}');
    }
    return key;
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }

  static bool _isBranchKeyChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) ||
        (code >= 0x61 && code <= 0x7A) ||
        (code >= 0x30 && code <= 0x39) ||
        c == '_';
  }
```

Add a `substringFrom` helper to `_Cursor`:

```dart
  String substringFrom(int start) => _input.substring(start, _pos);
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: PASS — 21 tests total.

- [ ] **Step 5: Commit**

```bash
git add lib/src/util/parser/message_format_parser.dart test/src/util/parser/message_format_parser_test.dart
git commit -m "feat: parse plural/select/selectordinal sub-messages"
```

---

## Task 5: Handle ICU escape sequences

**Files:**
- Modify: `lib/src/util/parser/message_format_parser.dart`
- Modify: `test/src/util/parser/message_format_parser_test.dart`

ICU escapes braces and apostrophes: `''` is a literal apostrophe; `'{'`, `'}'`, `'#'` are literal characters. Anything else inside single quotes is also literal until the closing quote.

- [ ] **Step 1: Write the failing tests**

Append to `test/src/util/parser/message_format_parser_test.dart`:

```dart
  group('MessageFormatParser escaping', () {
    test('escaped opening brace produces a literal { ', () {
      final ast = MessageFormatParser.parse("price: '{'5}");
      expect(ast.roots.length, 1);
      expect((ast.roots.first as LiteralNode).text, 'price: {5}');
    });

    test('double single-quote produces a literal apostrophe', () {
      final ast = MessageFormatParser.parse("it''s here");
      expect((ast.roots.first as LiteralNode).text, "it's here");
    });

    test('quoted text after a special char is a literal block', () {
      final ast = MessageFormatParser.parse("can't '{escape}' me");
      expect((ast.roots.first as LiteralNode).text, "can't {escape} me");
    });

    test('lone apostrophe with no following special char is literal', () {
      final ast = MessageFormatParser.parse("don't");
      expect((ast.roots.first as LiteralNode).text, "don't");
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: FAIL — current parser treats `'` as a regular literal character without escape semantics.

- [ ] **Step 3: Add escape handling**

Update the literal-collection loop inside `_parseNodes` in `lib/src/util/parser/message_format_parser.dart`:

```dart
    while (!cursor.isAtEnd) {
      final ch = cursor.peek();
      if (ch == "'") {
        _consumeQuotedLiteral(cursor, literal);
        continue;
      }
      if (ch == '{') {
        flushLiteral();
        nodes.add(_parsePlaceholder(cursor));
        continue;
      }
      if (ch == '}') {
        if (depth == 0) {
          throw MessageFormatParseException(
              'Unmatched closing brace at position ${cursor.position}');
        }
        break;
      }
      literal.write(ch);
      cursor.advance();
    }
```

Add a helper at the bottom of the `MessageFormatParser` class:

```dart
  static void _consumeQuotedLiteral(_Cursor cursor, StringBuffer literal) {
    cursor.advance(); // consume opening '
    if (cursor.isAtEnd) {
      literal.write("'");
      return;
    }
    final next = cursor.peek();
    if (next == "'") {
      literal.write("'");
      cursor.advance();
      return;
    }
    if (next != '{' && next != '}' && next != '#' && next != '|') {
      literal.write("'");
      return;
    }
    while (!cursor.isAtEnd) {
      final c = cursor.peek();
      if (c == "'") {
        cursor.advance();
        if (!cursor.isAtEnd && cursor.peek() == "'") {
          literal.write("'");
          cursor.advance();
          continue;
        }
        return;
      }
      literal.write(c);
      cursor.advance();
    }
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/util/parser/message_format_parser_test.dart`
Expected: PASS — 25 tests total.

- [ ] **Step 5: Commit**

```bash
git add lib/src/util/parser/message_format_parser.dart test/src/util/parser/message_format_parser_test.dart
git commit -m "feat: handle ICU apostrophe escaping in parser"
```

---

## Task 6: Param discovery model and walker

**Files:**
- Create: `lib/src/model/message_format_param.dart`
- Create: `lib/src/util/parser/message_format_param_extractor.dart`
- Test: `test/src/util/parser/message_format_param_extractor_test.dart`

A pass over the AST that produces an ordered map keyed by original ICU name. Conflicts (same name with two incompatible Dart types) and camelCase collisions throw — callers downgrade to a warning.

- [ ] **Step 1: Write the failing test**

Create `test/src/util/parser/message_format_param_extractor_test.dart`:

```dart
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
      final ast = MessageFormatParser.parse(
          '{x, number} and {x, date, short}');
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/util/parser/message_format_param_extractor_test.dart`
Expected: FAIL with `Target of URI doesn't exist`.

- [ ] **Step 3: Implement the model and extractor**

Create `lib/src/model/message_format_param.dart`:

```dart
enum MessageFormatParamType { string, num_, dateTime, duration }

enum MessageFormatFormatter {
  none,
  numberDecimal,
  numberPercent,
  numberCurrency,
  numberCustom,
  dateShort,
  dateMedium,
  dateLong,
  dateFull,
  dateCustom,
  timeShort,
  timeMedium,
  timeLong,
  timeFull,
  timeCustom,
  durationDefault,
  durationShort,
  durationMedium,
  durationLong,
  durationCustom,
}

class MessageFormatParam {
  final String originalName;
  final String dartName;
  final MessageFormatParamType dartType;
  final MessageFormatFormatter formatter;
  final String? formatterStyle;

  const MessageFormatParam({
    required this.originalName,
    required this.dartName,
    required this.dartType,
    required this.formatter,
    this.formatterStyle,
  });
}

class MessageFormatParamConflictException implements Exception {
  final String message;
  const MessageFormatParamConflictException(this.message);
  @override
  String toString() => 'MessageFormatParamConflictException: $message';
}
```

Create `lib/src/util/parser/message_format_param_extractor.dart`:

```dart
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/case/case_util.dart';

class MessageFormatParamExtractor {
  const MessageFormatParamExtractor._();

  static Map<String, MessageFormatParam> extract(MessageFormatAst ast) {
    final params = <String, MessageFormatParam>{};
    final dartNameToOriginal = <String, String>{};

    void visit(MessageFormatNode node) {
      switch (node) {
        case LiteralNode():
          break;
        case PlaceholderNode(:final name):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.string, MessageFormatFormatter.none, null);
        case PluralNode(:final name, :final branches):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.num_, MessageFormatFormatter.none, null);
          for (final list in branches.values) {
            for (final n in list) visit(n);
          }
        case SelectOrdinalNode(:final name, :final branches):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.num_, MessageFormatFormatter.none, null);
          for (final list in branches.values) {
            for (final n in list) visit(n);
          }
        case SelectNode(:final name, :final branches):
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.string, MessageFormatFormatter.none, null);
          for (final list in branches.values) {
            for (final n in list) visit(n);
          }
        case NumberNode(:final name, :final style):
          final formatter = _numberFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.num_, formatter, style);
        case DateNode(:final name, :final style):
          final formatter = _dateFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.dateTime, formatter, style);
        case TimeNode(:final name, :final style):
          final formatter = _timeFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.dateTime, formatter, style);
        case DurationNode(:final name, :final style):
          final formatter = _durationFormatter(style);
          _record(params, dartNameToOriginal, name,
              MessageFormatParamType.duration, formatter, style);
      }
    }

    for (final node in ast.roots) {
      visit(node);
    }
    return params;
  }

  static void _record(
    Map<String, MessageFormatParam> params,
    Map<String, String> dartNameToOriginal,
    String originalName,
    MessageFormatParamType type,
    MessageFormatFormatter formatter,
    String? style,
  ) {
    final dartName = CaseUtil.getCamelcase(originalName);
    final existing = params[originalName];
    if (existing != null) {
      if (existing.dartType != type) {
        throw MessageFormatParamConflictException(
            'Param "$originalName" used with incompatible types '
            '(${existing.dartType.name} vs ${type.name})');
      }
      return;
    }
    final collidingOriginal = dartNameToOriginal[dartName];
    if (collidingOriginal != null && collidingOriginal != originalName) {
      throw MessageFormatParamConflictException(
          'Params "$collidingOriginal" and "$originalName" both normalize to "$dartName"');
    }
    dartNameToOriginal[dartName] = originalName;
    params[originalName] = MessageFormatParam(
      originalName: originalName,
      dartName: dartName,
      dartType: type,
      formatter: formatter,
      formatterStyle: style,
    );
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/util/parser/message_format_param_extractor_test.dart`
Expected: PASS — 12 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/model/message_format_param.dart lib/src/util/parser/message_format_param_extractor.dart test/src/util/parser/message_format_param_extractor_test.dart
git commit -m "feat: extract typed MessageFormat params with conflict detection"
```

---

## Task 7: Cross-locale validator

**Files:**
- Create: `lib/src/util/validation/cross_locale_validator.dart`
- Test: `test/src/util/validation/cross_locale_validator_test.dart`

Compares each non-default locale's MessageFormat AST against the default. Returns a list of warning messages — does not throw, does not abort generation.

- [ ] **Step 1: Write the failing test**

Create `test/src/util/validation/cross_locale_validator_test.dart`:

```dart
import 'package:locale_gen/src/util/validation/cross_locale_validator.dart';
import 'package:test/test.dart';

void main() {
  group('CrossLocaleValidator', () {
    test('returns no warnings when locales agree', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'nl': 'Hallo, {name}!'},
      );
      expect(warnings, isEmpty);
    });

    test('warns when a locale uses a different placeholder name', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'nl': 'Hallo, {naam}!'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('greeting'));
      expect(warnings.first, contains('nl'));
      expect(warnings.first, contains('naam'));
    });

    test('warns when a locale is missing a placeholder', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'fr': 'Bonjour!'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('name'));
    });

    test('warns when a locale uses a different ICU node type for the same name',
        () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'cart_count',
        defaultLanguage: 'en',
        defaultValue: '{count, plural, one {# item} other {# items}}',
        otherLocales: const {'fr': 'Total: {count}'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('plural'));
    });

    test('warns once per failing locale, returns rest of validation', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {
          'nl': 'Hallo, {naam}!',
          'fr': 'Bonjour, {nom}!',
        },
      );
      expect(warnings, hasLength(2));
    });

    test('warns when a non-default locale fails to parse', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'broken': 'Hi {name'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('broken'));
      expect(warnings.first, contains('parse'));
    });

    test('ignores style differences in number/date/time/duration', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'paid_at',
        defaultLanguage: 'en',
        defaultValue: 'Paid at {t, date, short}',
        otherLocales: const {'nl': 'Betaald op {t, date, long}'},
      );
      expect(warnings, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/util/validation/cross_locale_validator_test.dart`
Expected: FAIL with `Target of URI doesn't exist`.

- [ ] **Step 3: Implement the validator**

Create `lib/src/util/validation/cross_locale_validator.dart`:

```dart
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';

class CrossLocaleValidator {
  const CrossLocaleValidator._();

  static List<String> validateKey({
    required String key,
    required String defaultLanguage,
    required String defaultValue,
    required Map<String, String> otherLocales,
  }) {
    final warnings = <String>[];
    final MessageFormatAst defaultAst;
    try {
      defaultAst = MessageFormatParser.parse(defaultValue);
    } on MessageFormatParseException {
      // The default itself is malformed — handled elsewhere with its own warning.
      return warnings;
    }
    final defaultNodes = _collectNamedNodes(defaultAst);

    for (final entry in otherLocales.entries) {
      final locale = entry.key;
      final value = entry.value;
      MessageFormatAst ast;
      try {
        ast = MessageFormatParser.parse(value);
      } on MessageFormatParseException catch (e) {
        warnings.add(
            '[locale_gen] Warning: key "$key" — locale "$locale" failed to parse as MessageFormat: ${e.message}.');
        continue;
      }
      final localeNodes = _collectNamedNodes(ast);

      final missing = defaultNodes.keys.toSet().difference(localeNodes.keys.toSet());
      final extra = localeNodes.keys.toSet().difference(defaultNodes.keys.toSet());
      if (missing.isNotEmpty || extra.isNotEmpty) {
        final defaultNames = defaultNodes.keys.toList()..sort();
        final localeNames = localeNodes.keys.toList()..sort();
        warnings.add(
            '[locale_gen] Warning: key "$key" — locale "$locale" uses params $localeNames; '
            'default language "$defaultLanguage" uses $defaultNames. '
            'The translated string must use the same placeholder names as the default language.');
        continue;
      }

      for (final name in defaultNodes.keys) {
        final defaultKind = _kindOf(defaultNodes[name]!);
        final localeKind = _kindOf(localeNodes[name]!);
        if (defaultKind != localeKind) {
          warnings.add(
              '[locale_gen] Warning: key "$key" — locale "$locale" uses $localeKind for "$name"; '
              'default language "$defaultLanguage" uses $defaultKind. '
              'The ICU type must match across locales.');
        }
      }
    }

    return warnings;
  }

  static Map<String, MessageFormatNode> _collectNamedNodes(MessageFormatAst ast) {
    final result = <String, MessageFormatNode>{};
    void visit(MessageFormatNode node) {
      switch (node) {
        case LiteralNode():
          break;
        case PlaceholderNode(:final name):
          result[name] ??= node;
        case PluralNode(:final name, :final branches):
          result[name] ??= node;
          for (final list in branches.values) {
            for (final n in list) visit(n);
          }
        case SelectOrdinalNode(:final name, :final branches):
          result[name] ??= node;
          for (final list in branches.values) {
            for (final n in list) visit(n);
          }
        case SelectNode(:final name, :final branches):
          result[name] ??= node;
          for (final list in branches.values) {
            for (final n in list) visit(n);
          }
        case NumberNode(:final name):
          result[name] ??= node;
        case DateNode(:final name):
          result[name] ??= node;
        case TimeNode(:final name):
          result[name] ??= node;
        case DurationNode(:final name):
          result[name] ??= node;
      }
    }

    for (final n in ast.roots) {
      visit(n);
    }
    return result;
  }

  static String _kindOf(MessageFormatNode node) {
    return switch (node) {
      LiteralNode() => 'literal',
      PlaceholderNode() => 'placeholder',
      PluralNode() => 'plural',
      SelectOrdinalNode() => 'selectordinal',
      SelectNode() => 'select',
      NumberNode() => 'number',
      DateNode() => 'date',
      TimeNode() => 'time',
      DurationNode() => 'duration',
    };
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/util/validation/cross_locale_validator_test.dart`
Expected: PASS — 7 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/util/validation/cross_locale_validator.dart test/src/util/validation/cross_locale_validator_test.dart
git commit -m "feat: cross-locale MessageFormat parameter validator"
```

---

## Task 8: Add `messageFormatStrict` config flag

**Files:**
- Modify: `lib/src/model/locale_gen_params.dart`
- Modify: `test/src/model/locale_gen_params_test.dart`

- [ ] **Step 1: Write the failing test**

Append a new test inside the existing `main()` of `test/src/model/locale_gen_params_test.dart`:

```dart
  group('LocaleGenParams messageFormatStrict', () {
    test('defaults to false when not set', () {
      const yaml = '''
name: example
locale_gen:
  languages: ['en']
''';
      final params = LocaleGenParams.fromYamlString('locale_gen', yaml);
      expect(params.messageFormatStrict, isFalse);
    });

    test('reads true when set in pubspec', () {
      const yaml = '''
name: example
locale_gen:
  languages: ['en']
  message_format_strict: true
''';
      final params = LocaleGenParams.fromYamlString('locale_gen', yaml);
      expect(params.messageFormatStrict, isTrue);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/model/locale_gen_params_test.dart`
Expected: FAIL with `The getter 'messageFormatStrict' isn't defined for the type 'LocaleGenParams'`.

- [ ] **Step 3: Add the field**

In `lib/src/model/locale_gen_params.dart`, add the field declaration after `late LocaleGenOutputType outputType;`:

```dart
  bool messageFormatStrict = false;
```

In the early-return branch of `LocaleGenParams.fromYamlString` (where `config == null`) leave `messageFormatStrict` at its default `false` (no change needed).

In the `configure` method, after `final outputType = config['output_type'] as String?;` add:

```dart
    final messageFormatStrict = config['message_format_strict'] as bool? ?? false;
```

And after `this.outputType = LocaleGenOutputType.fromString(outputType);` add:

```dart
    this.messageFormatStrict = messageFormatStrict;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/model/locale_gen_params_test.dart`
Expected: PASS — all existing tests plus the 2 new ones.

- [ ] **Step 5: Commit**

```bash
git add lib/src/model/locale_gen_params.dart test/src/model/locale_gen_params_test.dart
git commit -m "feat: add messageFormatStrict config flag"
```

---

## Task 9: Style detection helper

**Files:**
- Modify: `lib/src/locale_gen_constants.dart`
- Create: `lib/src/util/parser/translation_style_detector.dart`
- Test: `test/src/util/parser/translation_style_detector_test.dart`

A small helper used by the core generator to classify each value as MessageFormat, sprintf, both, or none.

- [ ] **Step 1: Write the failing test**

Create `test/src/util/parser/translation_style_detector_test.dart`:

```dart
import 'package:locale_gen/src/util/parser/translation_style_detector.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationStyleDetector', () {
    test('plain text → none', () {
      expect(TranslationStyleDetector.detect('hello world'),
          TranslationStyle.none);
    });

    test('contains sprintf %s → sprintf', () {
      expect(TranslationStyleDetector.detect('Hello %s'),
          TranslationStyle.sprintf);
    });

    test('contains sprintf %1\$d → sprintf', () {
      expect(TranslationStyleDetector.detect('Got %1\$d'),
          TranslationStyle.sprintf);
    });

    test('contains ICU placeholder → messageFormat', () {
      expect(TranslationStyleDetector.detect('Hi, {name}!'),
          TranslationStyle.messageFormat);
    });

    test('contains both ICU and sprintf → both', () {
      expect(TranslationStyleDetector.detect('Hello {name}, %s'),
          TranslationStyle.both);
    });

    test('escaped opening brace alone is still messageFormat detection',
        () {
      // '{' is an ICU escape — treat as messageFormat-aware string.
      expect(TranslationStyleDetector.detect("price '{'5}"),
          TranslationStyle.messageFormat);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/util/parser/translation_style_detector_test.dart`
Expected: FAIL with `Target of URI doesn't exist`.

- [ ] **Step 3: Implement the detector**

In `lib/src/locale_gen_constants.dart`, add a regex for ICU brace usage. Replace the file contents with:

```dart
class LocaleGenConstants {
  const LocaleGenConstants._();

  static final positionalFormatRegex = RegExp(r'\%(\d*)\$[\\.]?[\d+]*([sdf])');
  static final normalFormatRegex = RegExp(r'\%[\\.]?[\d+]*([sdf])');
  static const regexIndexGroupIndex = 1;
  static const regexTypeGroupIndex = 2;
  static const normalRegexTypeGroupIndex = 1;

  /// Matches an unescaped `{` that begins an ICU placeholder, OR an ICU escape
  /// sequence (`'{'`, `'}'`, `''`). Used to detect whether a translation is
  /// MessageFormat-aware vs sprintf-only.
  static final messageFormatMarkerRegex = RegExp(r"(\{[A-Za-z_])|('\{')|('\}')|('')");
}
```

Create `lib/src/util/parser/translation_style_detector.dart`:

```dart
import 'package:locale_gen/src/locale_gen_constants.dart';

enum TranslationStyle { none, sprintf, messageFormat, both }

class TranslationStyleDetector {
  const TranslationStyleDetector._();

  static TranslationStyle detect(String value) {
    final hasSprintf =
        LocaleGenConstants.positionalFormatRegex.hasMatch(value) ||
            LocaleGenConstants.normalFormatRegex.hasMatch(value);
    final hasMessageFormat =
        LocaleGenConstants.messageFormatMarkerRegex.hasMatch(value);
    if (hasSprintf && hasMessageFormat) return TranslationStyle.both;
    if (hasSprintf) return TranslationStyle.sprintf;
    if (hasMessageFormat) return TranslationStyle.messageFormat;
    return TranslationStyle.none;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/util/parser/translation_style_detector_test.dart`
Expected: PASS — 6 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/locale_gen_constants.dart lib/src/util/parser/translation_style_detector.dart test/src/util/parser/translation_style_detector_test.dart
git commit -m "feat: detect MessageFormat vs sprintf translation style"
```

---

## Task 10: Wire MessageFormat into core_generator dispatch

**Files:**
- Modify: `lib/src/writer/core_generator.dart`

Add an abstract `buildMessageFormatFunction` method, and change `buildTranslationFunction` to dispatch to it when the value is detected as MessageFormat.

This task has no new test — coverage is provided by the generator-specific tests in Tasks 12-15. The change is purely a dispatch addition with the new abstract method default-implemented to fall back to `buildDefaultFunction`. Existing generator subclasses (`LocaleGenFlutterGenerator`, `LocaleGenDartGenerator`) keep working unchanged because the default implementation falls back.

- [ ] **Step 1: Update `core_generator.dart`**

Add imports at the top of `lib/src/writer/core_generator.dart`:

```dart
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
import 'package:locale_gen/src/util/parser/message_format_parser.dart';
import 'package:locale_gen/src/util/parser/message_format_param_extractor.dart';
import 'package:locale_gen/src/util/parser/translation_style_detector.dart';
```

Replace the body of `buildTranslationFunction` with the version below. The change adds a `value is String` MessageFormat branch; the rest is identical.

```dart
  void buildTranslationFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    dynamic value,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    if (value == null || (value is String && value.isEmpty)) {
      buildDefaultFunction(sb, params, key, allTranslations);
      return;
    }
    try {
      // JSON-object plural — unchanged path.
      if (value is Map<String, dynamic>) {
        if (value['other'] == null) {
          throw Exception('Other is required for plurals. Key: $key');
        }
        final plural = Plural.fromJson(value);
        final arguments = <int, String>{};
        plural.zero?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.one?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.two?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.few?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        plural.many?.let((v) =>
            arguments.addAll(_extractParameters(key: key, value: v)));
        arguments.addAll(_extractParameters(key: key, value: plural.other));
        if (arguments.isEmpty) {
          buildDefaultPluralFunction(sb, params, key, plural, allTranslations);
        } else {
          buildParameterizedPluralFunction(
              sb, params, key, plural, arguments, allTranslations);
        }
        return;
      }

      // String value — choose between sprintf and MessageFormat per detection.
      value as String;
      final style = TranslationStyleDetector.detect(value);

      if (style == TranslationStyle.both) {
        print(
            '[locale_gen] Warning: key "$key" contains both sprintf and MessageFormat markers; falling back to default getter.');
        buildDefaultFunction(sb, params, key, allTranslations);
        return;
      }

      if (params.messageFormatStrict && style == TranslationStyle.sprintf) {
        print(
            '[locale_gen] Warning: key "$key" uses sprintf markers but messageFormatStrict is enabled; falling back to default getter.');
        buildDefaultFunction(sb, params, key, allTranslations);
        return;
      }

      if (style == TranslationStyle.messageFormat) {
        try {
          final ast = MessageFormatParser.parse(value);
          final mfParams = MessageFormatParamExtractor.extract(ast);
          buildMessageFormatFunction(
              sb, params, key, ast, mfParams, allTranslations);
        } on MessageFormatParseException catch (e) {
          print('[locale_gen] Warning: key "$key" failed to parse as '
              'MessageFormat: ${e.message}. Falling back to default getter.');
          buildDefaultFunction(sb, params, key, allTranslations);
        } on MessageFormatParamConflictException catch (e) {
          print('[locale_gen] Warning: key "$key" — ${e.message}. Falling back to default getter.');
          buildDefaultFunction(sb, params, key, allTranslations);
        }
        return;
      }

      // Sprintf path — unchanged.
      final arguments = _extractParameters(key: key, value: value);
      if (arguments.isEmpty) {
        buildDefaultFunction(sb, params, key, allTranslations);
      } else {
        buildParameterizedFunction(
            sb, params, key, arguments, allTranslations);
      }
    } on Exception catch (e) {
      print(e);
      buildDefaultFunction(sb, params, key, allTranslations);
    }
  }
```

Add a new abstract method declaration right after the existing `@protected void buildParameterizedFunction(...)` declaration:

```dart
  @protected
  void buildMessageFormatFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    MessageFormatAst ast,
    Map<String, MessageFormatParam> mfParams,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    // Default: subclasses without MessageFormat support fall back.
    buildDefaultFunction(sb, params, key, allTranslations);
  }
```

- [ ] **Step 2: Run all existing tests to confirm nothing regressed**

Run: `dart test`
Expected: PASS — every test that was passing before this task still passes.

- [ ] **Step 3: Commit**

```bash
git add lib/src/writer/core_generator.dart
git commit -m "feat: route MessageFormat-style translations through new builder"
```

---

## Task 11: Emit `_mf` and `_stripFormatSpecs` runtime helpers (Flutter generator)

**Files:**
- Modify: `lib/src/writer/flutter/flutter_generator.dart`
- Modify: `test/src/writor/flutter/flutter_generator_test.dart`

When the project contains at least one MessageFormat key, the generator must emit:
- A `package:intl/message_format.dart` import.
- The private `_mf` runtime helper.
- The `_stripFormatSpecs` helper.

Detection of "any MessageFormat key" is done by scanning `defaultTranslations` values with `TranslationStyleDetector`.

- [ ] **Step 1: Write the failing test**

Append to `test/src/writor/flutter/flutter_generator_test.dart` (within the existing `main()` group structure — adapt to the existing file's style):

```dart
  group('LocaleGenFlutterGenerator MessageFormat helpers', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    test('emits _mf and _stripFormatSpecs when MessageFormat keys exist', () {
      final defaults = <String, dynamic>{'greeting': 'Hi, {name}!'};
      final all = <String, Map<String, dynamic>>{
        'en': {'greeting': 'Hi, {name}!'},
      };
      final output = generator.createLocalizationFile(params, defaults, all);
      expect(output, contains("import 'package:intl/message_format.dart';"));
      expect(output, contains('String _mf('));
      expect(output, contains('String _stripFormatSpecs('));
    });

    test('does not emit MessageFormat helpers when no MessageFormat keys exist',
        () {
      final defaults = <String, dynamic>{'plain': 'hello world'};
      final all = <String, Map<String, dynamic>>{
        'en': {'plain': 'hello world'},
      };
      final output = generator.createLocalizationFile(params, defaults, all);
      expect(output, isNot(contains('package:intl/message_format.dart')));
      expect(output, isNot(contains('String _mf(')));
    });
  });
```

If the existing test file does not import `LocaleGenFlutterGenerator` and `LocaleGenParams`, add:

```dart
import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: FAIL — neither helper is emitted today.

- [ ] **Step 3: Add MessageFormat detection and helper emission**

In `lib/src/writer/flutter/flutter_generator.dart`, add an import:

```dart
import 'package:locale_gen/src/util/parser/translation_style_detector.dart';
```

Replace the top of `createLocalizationFile` (the part that builds `hasPlurals` and the imports list, before the `Localization` class is opened) with a version that also detects MessageFormat usage and conditionally emits the helpers. Specifically:

After `final hasPlurals = ...`, add:

```dart
    final hasMessageFormat = defaultTranslations.values.whereType<String>().any(
        (v) =>
            TranslationStyleDetector.detect(v) ==
            TranslationStyle.messageFormat);
```

Update the imports list builder so it also includes `package:intl/message_format.dart` when needed:

```dart
    [
      if (hasPlurals || hasMessageFormat) ...["import 'package:intl/intl.dart';"],
      if (hasMessageFormat) ...["import 'package:intl/message_format.dart';"],
      "import 'package:sprintf/sprintf.dart';",
      "import 'package:flutter/services.dart';",
      "import 'package:flutter/widgets.dart';",
      "import 'package:${params.projectName}/${importPath}localization_keys.dart';",
      "import 'package:${params.projectName}/${importPath}localization_overrides.dart';",
    ]
```

After the `_t` helper is written and immediately before the `if (hasPlurals)` block, add:

```dart
    if (hasMessageFormat) {
      sb
        ..writeln(
            '  String _mf(String key, {required Map<String, Object> args}) {')
        ..writeln('    try {')
        ..writeln(
            '      final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;')
        ..writeln('      if (value == null) return key;')
        ..writeln('      final stripped = _stripFormatSpecs(value);')
        ..writeln(
            '      return MessageFormat(stripped, locale: locale?.toLanguageTag()).format(args);')
        ..writeln('    } catch (e) {')
        ..writeln("      return '⚠\$key⚠';")
        ..writeln('    }')
        ..writeln('  }')
        ..writeln()
        ..writeln('  String _stripFormatSpecs(String value) {')
        ..writeln(
            "    final regex = RegExp(r'\\{(\\w+)\\s*,\\s*(number|date|time|duration)(\\s*,[^{}]*)?\\}');")
        ..writeln(
            "    return value.replaceAllMapped(regex, (m) => '{\${m.group(1)}}');")
        ..writeln('  }')
        ..writeln();
    }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: PASS — both new tests pass plus all previously passing tests in the file.

- [ ] **Step 5: Commit**

```bash
git add lib/src/writer/flutter/flutter_generator.dart test/src/writor/flutter/flutter_generator_test.dart
git commit -m "feat: emit _mf and _stripFormatSpecs MessageFormat runtime helpers"
```

---

## Task 12: Emit MessageFormat function for placeholder/select/plural/selectordinal (Flutter generator)

**Files:**
- Modify: `lib/src/writer/flutter/flutter_generator.dart`
- Modify: `test/src/writor/flutter/flutter_generator_test.dart`

Implement `buildMessageFormatFunction` for the four "free-tier" ICU types (no formatter wiring needed).

- [ ] **Step 1: Write the failing test**

Append to `test/src/writor/flutter/flutter_generator_test.dart` inside the same `group('LocaleGenFlutterGenerator MessageFormat helpers'` or in a new group:

```dart
  group('LocaleGenFlutterGenerator buildMessageFormatFunction (free-tier)', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    String generate(Map<String, dynamic> defaults) {
      return generator.createLocalizationFile(params, defaults, {'en': defaults});
    }

    test('placeholder generates a named-required String param', () {
      final out = generate({'greeting': 'Hi, {name}!'});
      expect(out, contains('String greeting({required String name})'));
      expect(out, contains("LocalizationKeys.greeting"));
      expect(out, contains("'name': name"));
    });

    test('camelCases uppercase names but preserves original key in args map', () {
      final out = generate({'confirm_terms': 'See {SC} please'});
      expect(out, contains('String confirmTerms({required String sc})'));
      expect(out, contains("'SC': sc"));
    });

    test('plural generates a named-required num count param', () {
      final out =
          generate({'cart_count': '{count, plural, one {# item} other {# items}}'});
      expect(out, contains('String cartCount({required num count})'));
      expect(out, contains("'count': count"));
    });

    test('selectordinal generates a named-required num param', () {
      final out = generate({
        'rank': '{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}'
      });
      expect(out, contains('String rank({required num place})'));
    });

    test('select generates a named-required String param', () {
      final out = generate({
        'pronoun': '{gender, select, male {he} female {she} other {they}}'
      });
      expect(out, contains('String pronoun({required String gender})'));
    });

    test('multiple placeholders generate ordered named params', () {
      final out = generate({'mix': 'A {first} and {second}.'});
      expect(out, contains('String mix({required String first, required String second})'));
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: FAIL — `buildMessageFormatFunction` is not yet implemented in the Flutter generator (it inherits the default that emits a getter).

- [ ] **Step 3: Implement `buildMessageFormatFunction`**

In `lib/src/writer/flutter/flutter_generator.dart`, add imports:

```dart
import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';
```

At the bottom of the class, override `buildMessageFormatFunction`:

```dart
  @override
  void buildMessageFormatFunction(
    StringBuffer sb,
    LocaleGenParams params,
    String key,
    MessageFormatAst ast,
    Map<String, MessageFormatParam> mfParams,
    Map<String, Map<String, dynamic>> allTranslations,
  ) {
    final camelKey = CaseUtil.getCamelcase(key);
    if (mfParams.isEmpty) {
      sb
        ..writeln(
            '  String $camelKey() => _mf(LocalizationKeys.$camelKey, args: const {});')
        ..writeln();
      return;
    }
    final paramSignatures = mfParams.values
        .map((p) => 'required ${_dartTypeFor(p.dartType)} ${p.dartName}')
        .join(', ');
    final argEntries = mfParams.values
        .map((p) =>
            "'${p.originalName}': ${_argExpression(p)}")
        .join(', ');
    final hasFormatter = mfParams.values
        .any((p) => p.formatter != MessageFormatFormatter.none);
    if (!hasFormatter) {
      sb
        ..writeln(
            '  String $camelKey({$paramSignatures}) => _mf(LocalizationKeys.$camelKey, args: {$argEntries});')
        ..writeln();
      return;
    }
    // Formatter cases handled in Task 13.
    sb
      ..writeln(
          '  String $camelKey({$paramSignatures}) => _mf(LocalizationKeys.$camelKey, args: {$argEntries});')
      ..writeln();
  }

  static String _dartTypeFor(MessageFormatParamType type) {
    switch (type) {
      case MessageFormatParamType.string:
        return 'String';
      case MessageFormatParamType.num_:
        return 'num';
      case MessageFormatParamType.dateTime:
        return 'DateTime';
      case MessageFormatParamType.duration:
        return 'Duration';
    }
  }

  static String _argExpression(MessageFormatParam p) {
    // Free-tier types (placeholder/plural/select/selectordinal) pass the value through directly.
    return p.dartName;
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: PASS — all tests including the 6 new ones.

- [ ] **Step 5: Commit**

```bash
git add lib/src/writer/flutter/flutter_generator.dart test/src/writor/flutter/flutter_generator_test.dart
git commit -m "feat: emit MessageFormat functions for placeholder/plural/select/selectordinal"
```

---

## Task 13: Emit number/date/time formatter calls (Flutter generator)

**Files:**
- Modify: `lib/src/writer/flutter/flutter_generator.dart`
- Modify: `test/src/writor/flutter/flutter_generator_test.dart`

Pre-format `num` and `DateTime` args before passing into `_mf`. The simplest output uses an inline expression so the function can stay a one-liner where possible; for multiple formatter args we move to a block body.

- [ ] **Step 1: Write the failing tests**

Append to `test/src/writor/flutter/flutter_generator_test.dart`:

```dart
  group('LocaleGenFlutterGenerator buildMessageFormatFunction (formatters)', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    String generate(Map<String, dynamic> defaults) {
      return generator.createLocalizationFile(params, defaults, {'en': defaults});
    }

    test('number with no style uses NumberFormat.decimalPattern', () {
      final out = generate({'count': 'Total {n, number}'});
      expect(out, contains('String count({required num n})'));
      expect(out, contains('NumberFormat.decimalPattern(locale?.toLanguageTag()).format(n)'));
    });

    test('number percent uses NumberFormat.percentPattern', () {
      final out = generate({'rate': '{r, number, percent}'});
      expect(out, contains('NumberFormat.percentPattern(locale?.toLanguageTag()).format(r)'));
    });

    test('number currency uses NumberFormat.simpleCurrency', () {
      final out = generate({'price': '{p, number, currency}'});
      expect(out, contains('NumberFormat.simpleCurrency(locale: locale?.toLanguageTag()).format(p)'));
    });

    test('date short uses DateFormat.yMd', () {
      final out = generate({'placedAt': 'Placed {placedAt, date, short}'});
      expect(out, contains('String placedAt({required DateTime placedAt})'));
      expect(out, contains('DateFormat.yMd(locale?.toLanguageTag()).format(placedAt)'));
    });

    test('date custom skeleton passes through to DateFormat', () {
      final out = generate({'when': '{when, date, yMMMd}'});
      expect(out, contains("DateFormat('yMMMd', locale?.toLanguageTag()).format(when)"));
    });

    test('time medium uses DateFormat.jms', () {
      final out = generate({'at': '{at, time, medium}'});
      expect(out, contains('DateFormat.jms(locale?.toLanguageTag()).format(at)'));
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: FAIL — `_argExpression` returns the bare param name today.

- [ ] **Step 3: Generate formatter expressions**

Replace `_argExpression` in `lib/src/writer/flutter/flutter_generator.dart` with:

```dart
  static String _argExpression(MessageFormatParam p) {
    final tag = 'locale?.toLanguageTag()';
    switch (p.formatter) {
      case MessageFormatFormatter.none:
        return p.dartName;
      case MessageFormatFormatter.numberDecimal:
        return 'NumberFormat.decimalPattern($tag).format(${p.dartName})';
      case MessageFormatFormatter.numberPercent:
        return 'NumberFormat.percentPattern($tag).format(${p.dartName})';
      case MessageFormatFormatter.numberCurrency:
        return 'NumberFormat.simpleCurrency(locale: $tag).format(${p.dartName})';
      case MessageFormatFormatter.numberCustom:
        return "NumberFormat('${_escape(p.formatterStyle ?? '')}', $tag).format(${p.dartName})";
      case MessageFormatFormatter.dateShort:
        return 'DateFormat.yMd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateMedium:
        return 'DateFormat.yMMMd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateLong:
        return 'DateFormat.yMMMMd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateFull:
        return 'DateFormat.yMMMMEEEEd($tag).format(${p.dartName})';
      case MessageFormatFormatter.dateCustom:
        return "DateFormat('${_escape(p.formatterStyle ?? '')}', $tag).format(${p.dartName})";
      case MessageFormatFormatter.timeShort:
        return 'DateFormat.jm($tag).format(${p.dartName})';
      case MessageFormatFormatter.timeMedium:
      case MessageFormatFormatter.timeLong:
      case MessageFormatFormatter.timeFull:
        return 'DateFormat.jms($tag).format(${p.dartName})';
      case MessageFormatFormatter.timeCustom:
        return "DateFormat('${_escape(p.formatterStyle ?? '')}', $tag).format(${p.dartName})";
      case MessageFormatFormatter.durationDefault:
      case MessageFormatFormatter.durationMedium:
        return '_formatDuration(${p.dartName}, null)';
      case MessageFormatFormatter.durationShort:
        return "_formatDuration(${p.dartName}, 'short')";
      case MessageFormatFormatter.durationLong:
        return "_formatDuration(${p.dartName}, 'long')";
      case MessageFormatFormatter.durationCustom:
        return "_formatDuration(${p.dartName}, '${_escape(p.formatterStyle ?? '')}')";
    }
  }

  static String _escape(String s) => s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: PASS — including the 6 new formatter tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/writer/flutter/flutter_generator.dart test/src/writor/flutter/flutter_generator_test.dart
git commit -m "feat: pre-format number/date/time MessageFormat args at runtime"
```

---

## Task 14: Duration formatter helper

**Files:**
- Modify: `lib/src/writer/flutter/flutter_generator.dart`
- Modify: `test/src/writor/flutter/flutter_generator_test.dart`

When any key uses `{x, duration, ...}`, emit a private `_formatDuration` helper that handles `null`, `short`, `medium`, `long`, and arbitrary patterns containing `H`, `m`, `s`.

- [ ] **Step 1: Write the failing test**

Append to `test/src/writor/flutter/flutter_generator_test.dart`:

```dart
  group('LocaleGenFlutterGenerator duration support', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en']
''');
    final generator = LocaleGenFlutterGenerator();

    test('emits _formatDuration helper when duration is used', () {
      final defaults = <String, dynamic>{'race': '{d, duration}'};
      final out = generator.createLocalizationFile(params, defaults, {'en': defaults});
      expect(out, contains('String _formatDuration(Duration d, String? style)'));
      expect(out, contains('String race({required Duration d})'));
      expect(out, contains('_formatDuration(d, null)'));
    });

    test('does not emit _formatDuration when duration is not used', () {
      final defaults = <String, dynamic>{'plain': 'hello'};
      final out = generator.createLocalizationFile(params, defaults, {'en': defaults});
      expect(out, isNot(contains('_formatDuration')));
    });

    test('custom duration pattern is passed through to _formatDuration', () {
      final defaults = <String, dynamic>{'race': '{d, duration, mm:ss}'};
      final out = generator.createLocalizationFile(params, defaults, {'en': defaults});
      expect(out, contains("_formatDuration(d, 'mm:ss')"));
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: FAIL — `_formatDuration` is referenced by `_argExpression` (Task 13) but never defined.

- [ ] **Step 3: Emit the helper conditionally**

In `lib/src/writer/flutter/flutter_generator.dart`, after `final hasMessageFormat = ...` add:

```dart
    final hasDuration = defaultTranslations.values.whereType<String>().any((v) {
      if (TranslationStyleDetector.detect(v) != TranslationStyle.messageFormat) {
        return false;
      }
      try {
        final ast = MessageFormatParser.parse(v);
        return _astContainsDuration(ast);
      } on MessageFormatParseException {
        return false;
      }
    });
```

Add a private helper at the end of the class:

```dart
  static bool _astContainsDuration(MessageFormatAst ast) {
    bool walk(MessageFormatNode node) {
      switch (node) {
        case DurationNode():
          return true;
        case PluralNode(:final branches):
        case SelectOrdinalNode(:final branches):
        case SelectNode(:final branches):
          for (final list in branches.values) {
            for (final n in list) {
              if (walk(n)) return true;
            }
          }
          return false;
        default:
          return false;
      }
    }

    for (final n in ast.roots) {
      if (walk(n)) return true;
    }
    return false;
  }
```

(Ensure `MessageFormatParser` and `MessageFormatAst` are already imported from earlier tasks.)

Add a top-level constant for the helper template (place near the top of the file, below imports):

```dart
const _durationHelperTemplate = r'''
  String _formatDuration(Duration d, String? style) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    String pad(int n) => n.toString().padLeft(2, '0');
    if (style == null || style == 'medium') {
      return '${pad(h)}:${pad(m)}:${pad(s)}';
    }
    if (style == 'short') {
      return '${pad(d.inMinutes)}:${pad(s)}';
    }
    if (style == 'long') {
      final parts = <String>[];
      if (h > 0) parts.add('${h}h');
      if (m > 0) parts.add('${m}m');
      if (s > 0 || parts.isEmpty) parts.add('${s}s');
      return parts.join(' ');
    }
    final buf = StringBuffer();
    var i = 0;
    while (i < style.length) {
      final c = style[i];
      if (c == "'" && i + 1 < style.length) {
        final end = style.indexOf("'", i + 1);
        if (end == -1) {
          buf.write(style.substring(i + 1));
          break;
        }
        buf.write(style.substring(i + 1, end));
        i = end + 1;
        continue;
      }
      if (c == 'H') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 'H') n++;
        buf.write(h.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      if (c == 'm') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 'm') n++;
        buf.write(m.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      if (c == 's') {
        var n = 1;
        while (i + n < style.length && style[i + n] == 's') n++;
        buf.write(s.toString().padLeft(n, '0'));
        i += n;
        continue;
      }
      buf.write(c);
      i++;
    }
    return buf.toString();
  }
''';
```

After the `_stripFormatSpecs` block emitted in Task 11, write the template — guarded by `hasDuration`:

```dart
    if (hasDuration) {
      sb..write(_durationHelperTemplate)..writeln();
    }
```

Using `r'''...'''` (raw triple-quoted) avoids any need to escape `$`, `'`, or backslashes inside the embedded Dart source.

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: PASS — three new duration tests plus everything from Tasks 11-13.

- [ ] **Step 5: Commit**

```bash
git add lib/src/writer/flutter/flutter_generator.dart test/src/writor/flutter/flutter_generator_test.dart
git commit -m "feat: emit _formatDuration helper for ICU duration arg"
```

---

## Task 15: Wire cross-locale validator into the Flutter writer pipeline

**Files:**
- Modify: `lib/src/writer/flutter/flutter_generator.dart`
- Modify: `test/src/writor/flutter/flutter_generator_test.dart`

After detecting MessageFormat keys, run `CrossLocaleValidator.validateKey` for each one and `print` warnings via the same `[locale_gen] Warning:` prefix.

- [ ] **Step 1: Write the failing test**

Append to `test/src/writor/flutter/flutter_generator_test.dart`. Use Zone-captured stdout to verify warnings without depending on `print`'s default destination:

```dart
  group('LocaleGenFlutterGenerator cross-locale validation', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
''');
    final generator = LocaleGenFlutterGenerator();

    String captureGenerate(Map<String, Map<String, dynamic>> all) {
      final buf = StringBuffer();
      runZoned(
        () => generator.createLocalizationFile(params, all['en']!, all),
        zoneSpecification: ZoneSpecification(
          print: (_, __, ___, line) => buf.writeln(line),
        ),
      );
      return buf.toString();
    }

    test('warns when nl uses a different placeholder name than en', () {
      final printed = captureGenerate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {naam}!'},
      });
      expect(printed, contains('greeting'));
      expect(printed, contains('"nl"'));
    });

    test('does not warn when locales agree', () {
      final printed = captureGenerate({
        'en': {'greeting': 'Hi, {name}!'},
        'nl': {'greeting': 'Hallo, {name}!'},
      });
      expect(printed, isNot(contains('Warning')));
    });
  });
```

Add the imports at the top of the test file if not already present:

```dart
import 'dart:async';
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: FAIL — no warnings are currently printed.

- [ ] **Step 3: Hook validator into `createLocalizationFile`**

In `lib/src/writer/flutter/flutter_generator.dart`, add an import:

```dart
import 'package:locale_gen/src/util/validation/cross_locale_validator.dart';
```

In `createLocalizationFile`, after `final hasMessageFormat = ...` (and before any code emission), add:

```dart
    if (hasMessageFormat) {
      defaultTranslations.forEach((key, dynamic value) {
        if (value is! String) return;
        if (TranslationStyleDetector.detect(value) !=
            TranslationStyle.messageFormat) {
          return;
        }
        final others = <String, String>{};
        for (final entry in allTranslations.entries) {
          if (entry.key == params.defaultLanguage) continue;
          final v = entry.value[key];
          if (v is String) others[entry.key] = v;
        }
        final warnings = CrossLocaleValidator.validateKey(
          key: key,
          defaultLanguage: params.defaultLanguage,
          defaultValue: value,
          otherLocales: others,
        );
        for (final w in warnings) {
          print(w);
        }
      });
    }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test test/src/writor/flutter/flutter_generator_test.dart`
Expected: PASS — including the two new validation tests.

- [ ] **Step 5: Commit**

```bash
git add lib/src/writer/flutter/flutter_generator.dart test/src/writor/flutter/flutter_generator_test.dart
git commit -m "feat: run cross-locale validator during Flutter generation"
```

---

## Task 16: Mirror MessageFormat support into the Dart (non-Flutter) writer

**Files:**
- Modify: `lib/src/writer/dart/dart_generator.dart`
- Create: `test/src/writor/dart/dart_generator_test.dart`

Apply the same changes to the Dart writer. The Dart writer doesn't import Flutter packages — its emitted code uses identical helpers but with the Dart-side runtime imports.

- [ ] **Step 1: Read the existing Dart writer to understand the file shape**

Run: open `lib/src/writer/dart/dart_generator.dart` in the editor. Note where `hasPlurals` is computed and where the imports list and the runtime helpers are emitted. Apply the same pattern of changes.

- [ ] **Step 2: Write the failing tests**

Create `test/src/writor/dart/dart_generator_test.dart`:

```dart
import 'dart:async';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/dart/dart_generator.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleGenDartGenerator MessageFormat support', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
''');
    final generator = LocaleGenDartGenerator();

    String generate(Map<String, dynamic> defaults) {
      return generator.createLocalizationFile(params, defaults, {'en': defaults});
    }

    test('emits _mf and message_format import when MessageFormat keys exist', () {
      final out = generate({'greeting': 'Hi, {name}!'});
      expect(out, contains("import 'package:intl/message_format.dart';"));
      expect(out, contains('String _mf('));
      expect(out, contains('String greeting({required String name})'));
    });

    test('does not emit Flutter imports', () {
      final out = generate({'greeting': 'Hi, {name}!'});
      expect(out, isNot(contains("package:flutter/widgets.dart")));
      expect(out, isNot(contains("package:flutter/services.dart")));
    });

    test('plural generates a num count param', () {
      final out =
          generate({'cart_count': '{count, plural, one {# item} other {# items}}'});
      expect(out, contains('String cartCount({required num count})'));
    });

    test('emits _formatDuration helper when duration is used', () {
      final out = generate({'race': '{d, duration}'});
      expect(out, contains('String _formatDuration(Duration d, String? style)'));
    });

    test('cross-locale validator warns through Dart writer too', () {
      final buf = StringBuffer();
      runZoned(
        () => generator.createLocalizationFile(params, {
          'greeting': 'Hi, {name}!',
        }, {
          'en': {'greeting': 'Hi, {name}!'},
          'nl': {'greeting': 'Hallo, {naam}!'},
        }),
        zoneSpecification: ZoneSpecification(
          print: (_, __, ___, line) => buf.writeln(line),
        ),
      );
      expect(buf.toString(), contains('greeting'));
      expect(buf.toString(), contains('"nl"'));
    });
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `dart test test/src/writor/dart/dart_generator_test.dart`
Expected: FAIL — Dart generator hasn't gained MessageFormat support yet.

- [ ] **Step 4: Apply the same changes as Tasks 11-15 to `lib/src/writer/dart/dart_generator.dart`**

The diff for the Dart generator mirrors the Flutter one exactly except:
- The imports list does **not** add `package:flutter/services.dart` or `package:flutter/widgets.dart`.
- It still adds `package:intl/intl.dart` and `package:intl/message_format.dart` when MessageFormat keys are present.
- The `_mf`, `_stripFormatSpecs`, `_formatDuration` helper bodies are the same byte-for-byte. Copy the emission code from Tasks 11 and 14 verbatim.
- The `buildMessageFormatFunction` override is the same byte-for-byte. Copy from Task 12 (and the `_argExpression` from Task 13).
- The cross-locale validation block is the same. Copy from Task 15.

To avoid duplication, also extract a single shared helper file if the diff feels like cargo-cult copy-paste. Recommended: create `lib/src/writer/message_format_emitter.dart` containing:
- `MessageFormatEmitter.emitRuntimeHelpers(StringBuffer sb, {required bool emitDuration})`
- `MessageFormatEmitter.emitFunction(StringBuffer sb, String key, MessageFormatAst ast, Map<String, MessageFormatParam> mfParams)`
- `MessageFormatEmitter.runValidation({required StringBuffer warningsSink or print, ...})`

If you take the shared-helper route, refactor the Flutter generator first (rerun all Flutter tests to verify nothing regresses), commit, then add the Dart generator usage. If you keep the changes inline (acceptable for two writers), skip the refactor and copy.

Either way, ensure the Dart generator tests above pass.

- [ ] **Step 5: Run all tests**

Run: `dart test`
Expected: PASS — every test in the suite, including the new Dart writer tests.

- [ ] **Step 6: Commit**

```bash
git add lib/src/writer/dart/ test/src/writor/dart/
# include lib/src/writer/message_format_emitter.dart and any Flutter-side refactor changes if you took that route
git commit -m "feat: MessageFormat support in Dart (non-Flutter) writer"
```

---

## Task 17: Integration fixture for end-to-end MessageFormat generation

**Files:**
- Create: `test/assets/locale/messageformat/en.json`
- Create: `test/assets/locale/messageformat/nl.json`
- Modify: `test/src/locale_gen_writer_test.dart` (or add a new file `test/src/locale_gen_writer_messageformat_test.dart`)

End-to-end: feed two JSON files through the writer and snapshot-check the output contains the expected functions and helpers.

- [ ] **Step 1: Write the fixture JSONs**

Create `test/assets/locale/messageformat/en.json`:

```json
{
  "greeting": "Hi, {name}!",
  "cart_count": "{count, plural, one {# item} other {# items}}",
  "order_placed": "Order on {placedAt, date, short} for {total, number, currency}",
  "race": "{d, duration, mm:ss}",
  "pronoun": "{gender, select, male {he} female {she} other {they}}"
}
```

Create `test/assets/locale/messageformat/nl.json`:

```json
{
  "greeting": "Hallo, {name}!",
  "cart_count": "{count, plural, one {# stuk} other {# stuks}}",
  "order_placed": "Besteld op {placedAt, date, long} voor {total, number, currency}",
  "race": "{d, duration, HH:mm:ss}",
  "pronoun": "{gender, select, male {hij} female {zij} other {zij}}"
}
```

- [ ] **Step 2: Write the failing test**

Create `test/src/locale_gen_writer_messageformat_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/flutter/flutter_generator.dart';
import 'package:test/test.dart';

void main() {
  test('end-to-end Flutter generation for MessageFormat fixtures', () {
    final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: example
locale_gen:
  languages: ['en', 'nl']
''');

    final en = json.decode(
        File('test/assets/locale/messageformat/en.json').readAsStringSync()) as Map<String, dynamic>;
    final nl = json.decode(
        File('test/assets/locale/messageformat/nl.json').readAsStringSync()) as Map<String, dynamic>;

    final generator = LocaleGenFlutterGenerator();
    final out = generator.createLocalizationFile(params, en, {'en': en, 'nl': nl});

    expect(out, contains('String greeting({required String name})'));
    expect(out, contains('String cartCount({required num count})'));
    expect(out, contains('String orderPlaced({required DateTime placedAt, required num total})'));
    expect(out, contains('String race({required Duration d})'));
    expect(out, contains('String pronoun({required String gender})'));

    expect(out, contains('String _mf('));
    expect(out, contains('String _stripFormatSpecs('));
    expect(out, contains('String _formatDuration('));
    expect(out, contains("import 'package:intl/message_format.dart';"));
  });
}
```

- [ ] **Step 3: Run the test to verify it passes**

Run: `dart test test/src/locale_gen_writer_messageformat_test.dart`
Expected: PASS.

If it fails, the failure points to a real defect in the per-task work above — fix it in the offending task's source file, do not paper over it here.

- [ ] **Step 4: Commit**

```bash
git add test/assets/locale/messageformat/ test/src/locale_gen_writer_messageformat_test.dart
git commit -m "test: end-to-end MessageFormat generation fixture"
```

---

## Task 18: Update README, CHANGELOG, and pubspec version

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Bump the version**

In `pubspec.yaml`, change `version: 12.6.0` to `version: 12.7.0`.

- [ ] **Step 2: Add CHANGELOG entry**

Insert at the top of `CHANGELOG.md`:

```markdown
## 12.7.0

- feat: MessageFormat (ICU) support — JSON values like `{count, plural, one {# item} other {# items}}` and `Hi, {name}!` now generate type-safe Dart functions with named parameters.
- feat: ICU `select`, `selectordinal`, `number`, `date`, `time`, and `duration` arg types are supported, with locale-aware formatting via `package:intl`.
- feat: cross-locale validation — the generator warns when a non-default locale uses a different placeholder name or ICU node type than the default language for the same key.
- feat: optional `message_format_strict: true` config flag to surface accidental sprintf usage in MessageFormat-only projects.
- The existing sprintf (`%s`, `%d`, `%1$s`) and JSON-object plural formats keep working unchanged. Detection happens per key.
```

- [ ] **Step 3: Add README section**

Append to `README.md` (above the closing footer if any) a new section. Use only invented examples:

```markdown
## MessageFormat (ICU) support

In addition to sprintf-style placeholders (`%s`, `%d`, `%1$s`) and JSON-object plurals, you can use ICU MessageFormat directly inside string values. Detection is automatic per key — projects can mix all three styles.

### Plain placeholders

```json
{
  "greeting": "Hi, {name}!"
}
```

generates:

```dart
String greeting({required String name});
```

### Plural

```json
{
  "cart_count": "{count, plural, one {# item} other {# items}}"
}
```

generates:

```dart
String cartCount({required num count});
```

### Select and selectordinal

```json
{
  "pronoun": "{gender, select, male {he} female {she} other {they}}",
  "rank": "{place, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}"
}
```

### Number, date, time, duration

```json
{
  "order_placed": "Order on {placedAt, date, short} for {total, number, currency}",
  "race": "{d, duration, mm:ss}"
}
```

generates Dart parameters typed as `DateTime`, `num`, and `Duration` respectively, with locale-aware formatting via `package:intl`.

### Strict mode

Add to your `pubspec.yaml` to make the generator warn whenever a sprintf marker appears in a project that should be MessageFormat-only:

```yaml
locale_gen:
  message_format_strict: true
```

### Cross-locale validation

When more than one language defines the same key, the generator warns if the placeholder names or ICU node types differ between locales. Generation continues — the warning helps surface translator typos like `{name}` vs `{naam}`.
```

- [ ] **Step 4: Run all tests one more time**

Run: `dart test`
Expected: PASS — full suite green.

- [ ] **Step 5: Commit**

```bash
git add README.md CHANGELOG.md pubspec.yaml
git commit -m "docs: document MessageFormat (ICU) support and bump to 12.7.0"
```

---

## Final verification

- [ ] **Run the full test suite one last time**

Run: `dart test`
Expected: every test passes.

- [ ] **Run `dart analyze`**

Run: `dart analyze`
Expected: no errors. Warnings should be reviewed; pre-existing warnings can be left alone.

- [ ] **Sanity-check generated code by running it against the example apps if practical**

If `example_dart` or `example_flutter` has a script for regenerating localization, run it and inspect the output for any MessageFormat keys you add. Not required to pass to merge, but valuable.
