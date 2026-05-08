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
    bool hasSeenNonEmptyLiteral = false;

    void flushLiteral() {
      final text = literal.toString();
      if (text.isNotEmpty) {
        nodes.add(LiteralNode(text));
        hasSeenNonEmptyLiteral = true;
      } else if (nodes.isNotEmpty && nodes.last is! LiteralNode) {
        // Skip leading empty literals; preserve a trailing empty literal so the AST shape stays predictable for callers.
        nodes.add(const LiteralNode(''));
      }
      literal.clear();
    }

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

    if (depth == 0 && !cursor.isAtEnd && cursor.peek() == '}') {
      throw MessageFormatParseException(
          'Unmatched closing brace at position ${cursor.position}');
    }

    // Final flush
    final text = literal.toString();
    if (text.isNotEmpty) {
      nodes.add(LiteralNode(text));
    } else if (nodes.isNotEmpty && nodes.last is! LiteralNode && hasSeenNonEmptyLiteral) {
      // Add trailing empty literal only if we've seen actual content
      nodes.add(const LiteralNode(''));
    } else if (nodes.isEmpty) {
      // Pure literal case
      nodes.add(LiteralNode(text));
    }

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
      throw const MessageFormatParseException('Expected branch key, got end of input');
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

  String substringFrom(int start) => _input.substring(start, _pos);

  static bool _isWhitespace(String c) => c == ' ' || c == '\t' || c == '\n' || c == '\r';

  static bool _isIdentifierChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || // A-Z
        (code >= 0x61 && code <= 0x7A) || // a-z
        (code >= 0x30 && code <= 0x39) || // 0-9
        c == '_';
  }
}
