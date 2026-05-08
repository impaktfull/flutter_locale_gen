import 'package:locale_gen/src/model/message_format_ast.dart';
import 'package:locale_gen/src/model/message_format_param.dart';

/// Raw Dart source for the `_formatDuration` helper emitted into generated
/// localization files when any key uses `{x, duration[, style]}`.
const messageFormatDurationHelperTemplate = r'''
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

/// Maps a [MessageFormatParamType] to the Dart type name used in generated
/// function signatures.
String dartTypeForMessageFormatParam(MessageFormatParamType type) {
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

/// Escapes a string for safe inclusion inside a Dart single-quoted string
/// literal. Used when embedding ICU formatter skeletons (e.g., `'mm:ss'`).
String escapeForSingleQuotedString(String s) =>
    s.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

/// Returns true if any node in the AST is a [DurationNode], including nested
/// branches of plural / select / selectordinal sub-messages.
bool messageFormatAstContainsDuration(MessageFormatAst ast) {
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
