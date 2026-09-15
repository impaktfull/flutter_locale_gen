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
