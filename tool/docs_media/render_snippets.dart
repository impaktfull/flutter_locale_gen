// Renders the code and terminal images used in the README and doc/.
//
// Every generated line and every terminal line in the images is real: this
// script creates throwaway projects, runs locale_gen (from this checkout) in
// them and screenshots the result with headless Chrome.
//
// Usage, from the repository root:
//   dart run tool/docs_media/render_snippets.dart
// Needs: Google Chrome. Set CHROME to its executable if it is not in the
// default macOS location.
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

const _charWidth = 8.43;
const _lineHeight = 22;
const _barHeight = 36;
const _prePaddingX = 20;
const _prePaddingY = 16;
const _pagePadding = 40;
const _gap = 24;
const _arrow = 56;

const _colors = {
  'comment': '#7f849c',
  'string': '#a6e3a1',
  'keyword': '#cba6f7',
  'type': '#f9e2af',
  'number': '#fab387',
  'function': '#89b4fa',
  'key': '#89dceb',
  'accent': '#f38ba8',
  'prompt': '#a6e3a1',
  'warning': '#f9e2af',
  'muted': '#7f849c',
};

const _dartKeywords =
    'import|class|final|required|return|static|get|const|void|async|await|'
    'var|this|if|else|for|in|late|extends|abstract|typedef|main|print';
const _dartTypes =
    'String|num|int|double|bool|DateTime|Duration|Future|Map|List|Object';

const _htmlEscape = HtmlEscape();

final _root = Directory.current.path;
final _out = join(_root, 'assets', 'docs');
final _chrome = Platform.environment['CHROME'] ??
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

Future<void> main() async {
  if (!File(join(_root, 'pubspec.yaml'))
      .readAsStringSync()
      .contains('name: locale_gen')) {
    stderr.writeln('Run this from the root of the locale_gen repository.');
    exit(1);
  }
  Directory(_out).createSync(recursive: true);
  await _flutterWriter();
  await _dartWriter();
  await _crossLocaleWarning();
}

// ---------------------------------------------------------------------------
// Highlighting
// ---------------------------------------------------------------------------

String _span(String kind, String text) =>
    '<span style="color:${_colors[kind]}">${_htmlEscape.convert(text)}</span>';

/// Renders [line], coloring every match of [token] by the named group that
/// matched. [render] can take over for a group.
String _tokenize(
  String line,
  RegExp token,
  List<String> groups, {
  String Function(String group, String text)? render,
}) {
  final out = StringBuffer();
  var position = 0;
  for (final match in token.allMatches(line)) {
    out.write(_htmlEscape.convert(line.substring(position, match.start)));
    final group = groups.firstWhere((g) => match.namedGroup(g) != null);
    out.write(render?.call(group, match[0]!) ?? _span(group, match[0]!));
    position = match.end;
  }
  out.write(_htmlEscape.convert(line.substring(position)));
  return out.toString();
}

/// Colors ICU `{name, ...}` openers, closers and sprintf markers in a string.
String _highlightPlaceholders(String text) {
  final marker = RegExp(r'\{[A-Za-z_]\w*|\{|\}|%\d*\$?\.?\d*[sdf]');
  final out = StringBuffer();
  var position = 0;
  for (final match in marker.allMatches(text)) {
    if (match.start > position) {
      out.write(_span('string', text.substring(position, match.start)));
    }
    out.write(_span('accent', match[0]!));
    position = match.end;
  }
  if (position < text.length) {
    out.write(_span('string', text.substring(position)));
  }
  return out.toString();
}

String _highlightDart(String line) => _tokenize(
      line,
      RegExp(
        r'(?<comment>//.*)'
        r'''|(?<string>'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")'''
        '|(?<keyword>\\b(?:$_dartKeywords)\\b)'
        '|(?<type>\\b(?:$_dartTypes|[A-Z]\\w*)\\b)'
        r'|(?<function>\b[a-z_]\w*(?=\())'
        r'|(?<number>\b\d+(?:\.\d+)?\b)',
      ),
      ['comment', 'string', 'keyword', 'type', 'function', 'number'],
    );

String _highlightJson(String line) => _tokenize(
      line,
      RegExp(r'(?<key>"(?:[^"\\]|\\.)*"(?=\s*:))|(?<string>"(?:[^"\\]|\\.)*")'),
      ['key', 'string'],
      render: (group, text) =>
          group == 'key' ? _span('key', text) : _highlightPlaceholders(text),
    );

String _highlightYaml(String line) => _tokenize(
      line,
      RegExp(
        r'(?<comment>#.*)'
        r'|(?<key>^\s*[\w-]+(?=:))'
        r'''|(?<string>"[^"]*"|'[^']*')'''
        r'|(?<keyword>\b(?:true|false|dart|flutter)\b)',
      ),
      ['comment', 'key', 'string', 'keyword'],
    );

String _highlightTerminal(String line) {
  if (line.startsWith(r'$ ')) {
    return _span('prompt', r'$ ') + _htmlEscape.convert(line.substring(2));
  }
  if (line.contains('Warning')) return _span('warning', line);
  if (line.startsWith('#')) return _span('muted', line);
  return _htmlEscape.convert(line);
}

const _highlighters = <String, String Function(String)>{
  'dart': _highlightDart,
  'json': _highlightJson,
  'yaml': _highlightYaml,
  'terminal': _highlightTerminal,
};

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------

/// East Asian wide characters take roughly 1.7 monospace cells in the page's
/// font stack.
double _visualWidth(String line) => line.runes.fold(0, (width, rune) {
      final wide = (rune >= 0x1100 && rune <= 0x115F) ||
          (rune >= 0x2E80 && rune <= 0xA4CF) ||
          (rune >= 0xAC00 && rune <= 0xD7A3) ||
          (rune >= 0xF900 && rune <= 0xFAFF) ||
          (rune >= 0xFE30 && rune <= 0xFE4F) ||
          (rune >= 0xFF00 && rune <= 0xFF60) ||
          (rune >= 0xFFE0 && rune <= 0xFFE6);
      return width + (wide ? 1.7 : 1);
    });

/// Removes the common indentation and the surrounding blank lines.
String _dedent(String text) {
  final lines = text.split('\n');
  final indents = lines
      .where((l) => l.trim().isNotEmpty)
      .map((l) => l.length - l.trimLeft().length);
  final indent = indents.isEmpty ? 0 : indents.reduce((a, b) => a < b ? a : b);
  final dedented =
      lines.map((l) => l.length >= indent ? l.substring(indent) : l.trimLeft());
  return dedented.join('\n').replaceAll(RegExp(r'^\n+|\n+$'), '');
}

class _Window {
  final String title;
  final String language;
  final List<String> lines;

  _Window(this.title, this.language, String code)
      : lines = _dedent(code).split('\n');

  int get width {
    final chars = [
      ...lines.map(_visualWidth),
      title.length * 0.8,
    ].reduce((a, b) => a > b ? a : b);
    return ((chars + 2) * _charWidth + 2 * _prePaddingX).round();
  }

  int get height => lines.length * _lineHeight + _barHeight + 2 * _prePaddingY;

  String get html {
    final body = lines.map(_highlighters[language]!).join('\n');
    return '<div class="window" style="width:${width}px">'
        '<div class="bar"><i></i><i></i><i></i>'
        '<span>${_htmlEscape.convert(title)}</span></div>'
        '<pre>$body</pre></div>';
  }
}

int _max(Iterable<int> values) => values.reduce((a, b) => a > b ? a : b);

int _sum(Iterable<int> values) => values.fold(0, (a, b) => a + b);

/// Renders [rows] of windows, with an arrow between the windows of a row.
Future<void> _render(String name, List<List<_Window>> rows) async {
  final width = _max(rows.map(
          (row) => _sum(row.map((w) => w.width)) + _arrow * (row.length - 1))) +
      2 * _pagePadding;
  final height = _sum(rows.map((row) => _max(row.map((w) => w.height)))) +
      _gap * (rows.length - 1) +
      2 * _pagePadding;
  final rowsHtml = rows
      .map((row) =>
          '<div class="row">${row.map((w) => w.html).join('<div class="arrow">→</div>')}</div>')
      .join();
  final page = '''<!doctype html><meta charset="utf-8"><style>
  html, body { margin: 0; width: ${width}px; height: ${height}px; overflow: hidden;
    background: linear-gradient(135deg, #7b61ff, #5b3fd9); }
  body { box-sizing: border-box; padding: ${_pagePadding}px;
    display: flex; flex-direction: column; gap: ${_gap}px; }
  .row { display: flex; align-items: flex-start; }
  .arrow { width: ${_arrow}px; text-align: center; color: #fff; font: 600 28px -apple-system, sans-serif;
    align-self: center; }
  .window { background: #1e1e2e; border-radius: 12px; overflow: hidden; flex: none;
    box-shadow: 0 18px 40px rgba(30, 10, 90, .45); }
  .bar { height: ${_barHeight}px; display: flex; align-items: center; gap: 8px; padding: 0 14px;
    background: #181825; }
  .bar i { width: 12px; height: 12px; border-radius: 50%; background: #45475a; }
  .bar i:nth-child(1) { background: #f38ba8; } .bar i:nth-child(2) { background: #f9e2af; }
  .bar i:nth-child(3) { background: #a6e3a1; }
  .bar span { margin-left: 8px; color: #a6adc8; font: 12px -apple-system, sans-serif; }
  pre { margin: 0; padding: ${_prePaddingY}px ${_prePaddingX}px; color: #cdd6f4;
    font: 14px/${_lineHeight}px Menlo, "PingFang SC", monospace; white-space: pre; }
</style>$rowsHtml''';

  final tmp = Directory.systemTemp.createTempSync('locale_gen_page_');
  try {
    final pagePath = join(tmp.path, 'page.html');
    File(pagePath).writeAsStringSync(page);
    final out = join(_out, '$name.png');
    await _run(_chrome, [
      '--headless=new',
      '--disable-gpu',
      '--hide-scrollbars',
      '--force-device-scale-factor=2',
      '--window-size=$width,$height',
      '--screenshot=$out',
      Uri.file(pagePath).toString(),
    ]);
    print('rendered ${relative(out, from: _root)}');
  } finally {
    tmp.deleteSync(recursive: true);
  }
}

// ---------------------------------------------------------------------------
// Throwaway projects
// ---------------------------------------------------------------------------

Future<String> _run(String executable, List<String> arguments,
    {String? workingDirectory}) async {
  final result = await Process.run(executable, arguments,
      workingDirectory: workingDirectory);
  if (result.exitCode != 0) {
    throw StateError('${[executable, ...arguments].join(' ')} failed:\n'
        '${result.stdout}\n${result.stderr}');
  }
  return result.stdout as String;
}

Future<String> _dart(List<String> arguments, String workingDirectory) =>
    _run(Platform.resolvedExecutable, arguments,
        workingDirectory: workingDirectory);

class _Project {
  final String path;

  /// The output of the second `dart run locale_gen`: the steady state rather
  /// than the first-run "Creating localization.dart ..." lines.
  final String output;

  _Project(this.path, this.output);

  String read(String relativePath) =>
      File(join(path, relativePath)).readAsStringSync();

  void delete() => Directory(path).deleteSync(recursive: true);
}

/// Creates a project that depends on this checkout and runs locale_gen in it.
Future<_Project> _project(
  String config,
  Map<String, String> translations, {
  String dependencies = '',
  Map<String, String> files = const {},
}) async {
  final path = Directory.systemTemp.createTempSync('locale_gen_docs_').path;
  File(join(path, 'pubspec.yaml')).writeAsStringSync('name: my_app\n'
      'environment:\n'
      '  sdk: ">=3.8.0 <4.0.0"\n'
      'dependencies:\n'
      '${dependencies.split('\n').where((l) => l.isNotEmpty).map((l) => '  $l\n').join()}'
      'dev_dependencies:\n'
      '  locale_gen:\n'
      '    path: $_root\n'
      '$config');
  translations.forEach((language, content) {
    File(join(path, 'assets', 'locale', '$language.json'))
      ..createSync(recursive: true)
      ..writeAsStringSync('${content.trim()}\n');
  });
  files.forEach((relativePath, content) {
    File(join(path, relativePath))
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  });
  await _dart(['pub', 'get'], path);
  await _dart(['run', 'locale_gen'], path);
  return _Project(path, await _dart(['run', 'locale_gen'], path));
}

/// Pulls the generated members for [names] out of a raw generated file.
String _members(String source, List<String> names,
    {List<String> keepDocsFor = const []}) {
  final lines = source.split('\n');
  final picked = <String>[];
  for (final name in names) {
    final index = lines.indexWhere(RegExp('^  \\w+ (get )?$name\\b').hasMatch);
    if (index == -1) {
      throw StateError('member $name not found in generated code');
    }
    if (keepDocsFor.contains(name)) {
      var start = index;
      while (start > 0 && lines[start - 1].startsWith('  ///')) {
        start--;
      }
      picked.addAll(lines.sublist(start, index).map((l) => l.substring(2)));
    }
    var signature = lines[index].substring(2);
    if (signature.contains('=>')) {
      signature = '${signature.split('=>').first}=> …';
    }
    picked
      ..add(signature)
      ..add('');
  }
  return picked.join('\n').trimRight();
}

/// Wraps [line] at [width] characters, indenting continuation lines.
List<String> _wrap(String line, int width) {
  const indent = '  ';
  final lines = <String>[];
  var current = '';
  for (final word in line.split(' ')) {
    final prefix = lines.isEmpty ? '' : indent;
    if (current.isNotEmpty &&
        prefix.length + current.length + 1 + word.length > width) {
      lines.add('$prefix$current');
      current = word;
    } else {
      current = current.isEmpty ? word : '$current $word';
    }
  }
  lines.add('${lines.isEmpty ? '' : indent}$current');
  return lines;
}

// ---------------------------------------------------------------------------
// Images
// ---------------------------------------------------------------------------

const _en = r'''
{
  "greeting": "Hi, {name}!",
  "cart_count": "{count, plural, one {# item} other {# items}}",
  "total": "Total: {total, number, currency}",
  "welcome_back": "Welcome back %1$s"
}
''';

const _nl = r'''
{
  "greeting": "Hallo, {name}!",
  "cart_count": "{count, plural, one {# stuk} other {# stuks}}",
  "total": "Totaal: {total, number, currency}",
  "welcome_back": "Welkom terug %1$s"
}
''';

const _main = r'''
import 'package:my_app/util/locale/localization.dart';

void main() {
  final l = Localization.instance;
  final greeting = l.greeting(name: 'Koen');
  final cart = l.cartCount(count: 3);
  print('en: ${greeting.en} · ${cart.en}');
  print('nl: ${greeting.nl} · ${cart.nl}');
}
''';

Future<void> _flutterWriter() async {
  const config = '''
locale_gen:
  languages: ["en", "nl"]
''';
  final project = await _project(config, {'en': _en, 'nl': _nl});
  final generated = project.read('lib/util/locale/localization.dart');
  project.delete();
  await _render('flutter_writer', [
    [
      _Window('assets/locale/en.json', 'json', _en),
      _Window(
        'lib/util/locale/localization.dart (generated)',
        'dart',
        _members(
          generated,
          ['greeting', 'cartCount', 'total', 'welcomeBack'],
          keepDocsFor: ['greeting'],
        ),
      ),
    ],
    [
      _Window('lib/screen/cart_screen.dart', 'dart', '''
final localization = Localization.of(context);

Text(localization.greeting(name: 'Koen'));
Text(localization.cartCount(count: items.length));
Text(localization.total(total: cart.total));
Text(localization.welcomeBack(user.name));
'''),
    ],
  ]);
}

Future<void> _dartWriter() async {
  const config = '''
locale_gen:
  languages: ["en", "nl"]
  output_type: dart
''';
  final project = await _project(
    config,
    {'en': _en, 'nl': _nl},
    dependencies: 'intl: ^0.20.2\nsprintf: ^7.0.0',
    files: {'bin/main.dart': _main},
  );
  final generated = project.read('lib/util/locale/localization.dart');
  final printed = await _dart(['run', 'bin/main.dart'], project.path);
  project.delete();

  final valueClass = RegExp(r'class LocalizedValue \{.*?\n\}', dotAll: true)
      .firstMatch(generated)![0]!
      .split('\n')
      .where((l) => l.trim().isNotEmpty)
      .join('\n');
  await _render('dart_writer', [
    [
      _Window('pubspec.yaml', 'yaml', config),
      _Window(
        'lib/util/locale/localization.dart (generated)',
        'dart',
        '$valueClass\n\n${_members(generated, ['greeting', 'cartCount'])}',
      ),
    ],
    [
      _Window('bin/main.dart', 'dart', _main),
      _Window('terminal', 'terminal', '\$ dart run bin/main.dart\n$printed'),
    ],
  ]);
}

Future<void> _crossLocaleWarning() async {
  const config = '''
locale_gen:
  languages: ["en", "nl"]
''';
  final nlWithTypo = _nl.replaceAll('{name}', '{naam}');
  final project = await _project(config, {'en': _en, 'nl': nlWithTypo});
  project.delete();
  final output = project.output
      .trim()
      .split('\n')
      .expand((line) => _wrap(line, 96))
      .join('\n');
  await _render('cross_locale_warning', [
    [
      _Window(
        'assets/locale/nl.json',
        'json',
        '${nlWithTypo.trim().split('\n').take(2).join('\n')}\n  …\n}',
      ),
    ],
    [_Window('terminal', 'terminal', '\$ dart run locale_gen\n$output')],
  ]);
}
