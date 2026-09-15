#!/usr/bin/env python3
"""Renders the code and terminal images used in the README and doc/.

Every generated line and every terminal line in the images is real: this
script creates throwaway projects, runs locale_gen (from this checkout) in
them and screenshots the result with headless Chrome.

Usage: python3 tool/docs_media/render_snippets.py
Needs: Dart on PATH, Google Chrome.
"""
import html
import os
import re
import shutil
import subprocess
import tempfile
import textwrap
import unicodedata

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "docs")
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

CHAR_WIDTH = 8.43
LINE_HEIGHT = 22
BAR_HEIGHT = 36
PRE_PADDING_X = 20
PRE_PADDING_Y = 16
PAGE_PADDING = 40
GAP = 24
ARROW = 56

COLORS = {
    "comment": "#7f849c",
    "string": "#a6e3a1",
    "keyword": "#cba6f7",
    "type": "#f9e2af",
    "number": "#fab387",
    "function": "#89b4fa",
    "key": "#89dceb",
    "accent": "#f38ba8",
    "prompt": "#a6e3a1",
    "warning": "#f9e2af",
    "muted": "#7f849c",
}

DART_KEYWORDS = (
    "import|class|final|required|return|static|get|const|void|async|await|"
    "var|this|if|else|for|in|late|extends|abstract|typedef|main|print"
)
DART_TYPES = "String|num|int|double|bool|DateTime|Duration|Future|Map|List|Object"


# --------------------------------------------------------------------------
# Highlighting
# --------------------------------------------------------------------------


def span(kind, text):
    return f'<span style="color:{COLORS[kind]}">{html.escape(text)}</span>'


def highlight_placeholders(text):
    """Colors ICU `{name, ...}` openers, closers and sprintf markers in a string."""
    parts = re.split(r"(\{[A-Za-z_]\w*|\{|\}|%\d*\$?\.?\d*[sdf])", text)
    out = []
    for part in parts:
        if not part:
            continue
        if re.fullmatch(r"\{[A-Za-z_]\w*|\{|\}|%\d*\$?\.?\d*[sdf]", part):
            out.append(span("accent", part))
        else:
            out.append(span("string", part))
    return "".join(out)


def highlight_dart(line):
    token = re.compile(
        r"(?P<comment>//.*)"
        r"|(?P<string>'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\")"
        rf"|(?P<keyword>\b(?:{DART_KEYWORDS})\b)"
        rf"|(?P<type>\b(?:{DART_TYPES}|[A-Z]\w*)\b)"
        r"|(?P<function>\b[a-z_]\w*(?=\())"
        r"|(?P<number>\b\d+(?:\.\d+)?\b)"
    )
    return tokenize(line, token)


def highlight_json(line):
    token = re.compile(r'(?P<key>"(?:[^"\\]|\\.)*"(?=\s*:))|(?P<string>"(?:[^"\\]|\\.)*")')
    out, pos = [], 0
    for match in token.finditer(line):
        out.append(html.escape(line[pos : match.start()]))
        if match.lastgroup == "key":
            out.append(span("key", match.group()))
        else:
            out.append(highlight_placeholders(match.group()))
        pos = match.end()
    out.append(html.escape(line[pos:]))
    return "".join(out)


def highlight_yaml(line):
    token = re.compile(
        r"(?P<comment>#.*)"
        r"|(?P<key>^\s*[\w-]+(?=:))"
        r"|(?P<string>\"[^\"]*\"|'[^']*')"
        r"|(?P<keyword>\b(?:true|false|dart|flutter)\b)"
    )
    return tokenize(line, token)


def highlight_terminal(line):
    if line.startswith("$ "):
        return span("prompt", "$ ") + html.escape(line[2:])
    if "Warning" in line:
        return span("warning", line)
    if line.startswith("#"):
        return span("muted", line)
    return html.escape(line)


def tokenize(line, token):
    out, pos = [], 0
    for match in token.finditer(line):
        out.append(html.escape(line[pos : match.start()]))
        out.append(span(match.lastgroup, match.group()))
        pos = match.end()
    out.append(html.escape(line[pos:]))
    return "".join(out)


HIGHLIGHTERS = {
    "dart": highlight_dart,
    "json": highlight_json,
    "yaml": highlight_yaml,
    "terminal": highlight_terminal,
}


# --------------------------------------------------------------------------
# Layout
# --------------------------------------------------------------------------


def visual_width(line):
    return sum(
        1.7 if unicodedata.east_asian_width(c) in "WF" else 1 for c in line
    )


class Window:
    def __init__(self, title, language, code):
        self.title = title
        self.language = language
        self.lines = textwrap.dedent(code).strip("\n").split("\n")

    @property
    def width(self):
        chars = max([visual_width(l) for l in self.lines] + [len(self.title) * 0.8])
        return round((chars + 2) * CHAR_WIDTH + 2 * PRE_PADDING_X)

    @property
    def height(self):
        return len(self.lines) * LINE_HEIGHT + BAR_HEIGHT + 2 * PRE_PADDING_Y

    def html(self):
        body = "\n".join(HIGHLIGHTERS[self.language](l) for l in self.lines)
        return (
            f'<div class="window" style="width:{self.width}px">'
            '<div class="bar"><i></i><i></i><i></i>'
            f"<span>{html.escape(self.title)}</span></div>"
            f"<pre>{body}</pre></div>"
        )


def render(name, rows):
    """rows: list of rows; a row is a list of Windows, drawn with arrows between."""
    row_widths = [
        sum(w.width for w in row) + ARROW * (len(row) - 1) for row in rows
    ]
    width = max(row_widths) + 2 * PAGE_PADDING
    height = (
        sum(max(w.height for w in row) for row in rows)
        + GAP * (len(rows) - 1)
        + 2 * PAGE_PADDING
    )
    rows_html = "".join(
        '<div class="row">'
        + '<div class="arrow">→</div>'.join(w.html() for w in row)
        + "</div>"
        for row in rows
    )
    page = f"""<!doctype html><meta charset="utf-8"><style>
      html, body {{ margin: 0; width: {width}px; height: {height}px; overflow: hidden;
        background: linear-gradient(135deg, #7b61ff, #5b3fd9); }}
      body {{ box-sizing: border-box; padding: {PAGE_PADDING}px;
        display: flex; flex-direction: column; gap: {GAP}px; }}
      .row {{ display: flex; align-items: flex-start; }}
      .arrow {{ width: {ARROW}px; text-align: center; color: #fff; font: 600 28px -apple-system, sans-serif;
        align-self: center; }}
      .window {{ background: #1e1e2e; border-radius: 12px; overflow: hidden; flex: none;
        box-shadow: 0 18px 40px rgba(30, 10, 90, .45); }}
      .bar {{ height: {BAR_HEIGHT}px; display: flex; align-items: center; gap: 8px; padding: 0 14px;
        background: #181825; }}
      .bar i {{ width: 12px; height: 12px; border-radius: 50%; background: #45475a; }}
      .bar i:nth-child(1) {{ background: #f38ba8; }} .bar i:nth-child(2) {{ background: #f9e2af; }}
      .bar i:nth-child(3) {{ background: #a6e3a1; }}
      .bar span {{ margin-left: 8px; color: #a6adc8; font: 12px -apple-system, sans-serif; }}
      pre {{ margin: 0; padding: {PRE_PADDING_Y}px {PRE_PADDING_X}px; color: #cdd6f4;
        font: 14px/{LINE_HEIGHT}px Menlo, "PingFang SC", monospace; white-space: pre; }}
    </style>{rows_html}"""

    with tempfile.TemporaryDirectory() as tmp:
        page_path = os.path.join(tmp, "page.html")
        with open(page_path, "w", encoding="utf-8") as f:
            f.write(page)
        out = os.path.join(OUT, f"{name}.png")
        subprocess.run(
            [
                CHROME,
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--force-device-scale-factor=2",
                f"--window-size={width},{height}",
                f"--screenshot={out}",
                f"file://{page_path}",
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        print(f"rendered {os.path.relpath(out, ROOT)}")


# --------------------------------------------------------------------------
# Throwaway projects
# --------------------------------------------------------------------------


def run(cmd, cwd):
    result = subprocess.run(
        cmd, cwd=cwd, capture_output=True, text=True, check=False
    )
    if result.returncode != 0:
        raise SystemExit(f"{' '.join(cmd)} failed:\n{result.stdout}\n{result.stderr}")
    return result.stdout


def project(pubspec_config, translations, dependencies="", files=None):
    """Creates a project that depends on this checkout and runs locale_gen twice.

    Twice, so the captured output is the steady state rather than the
    first-run "Creating localization.dart ..." lines.
    """
    path = tempfile.mkdtemp(prefix="locale_gen_docs_")
    os.makedirs(os.path.join(path, "assets", "locale"))
    with open(os.path.join(path, "pubspec.yaml"), "w") as f:
        f.write(
            "name: my_app\n"
            "environment:\n"
            '  sdk: ">=3.8.0 <4.0.0"\n'
            "dependencies:\n"
            + textwrap.indent(textwrap.dedent(dependencies), "  ")
            + "dev_dependencies:\n"
            "  locale_gen:\n"
            f"    path: {ROOT}\n"
            + textwrap.dedent(pubspec_config)
        )
    for language, content in translations.items():
        with open(os.path.join(path, "assets", "locale", f"{language}.json"), "w") as f:
            f.write(textwrap.dedent(content).strip() + "\n")
    for relative, content in (files or {}).items():
        os.makedirs(os.path.dirname(os.path.join(path, relative)), exist_ok=True)
        with open(os.path.join(path, relative), "w") as f:
            f.write(textwrap.dedent(content))
    run(["dart", "pub", "get"], path)
    run(["dart", "run", "locale_gen"], path)
    output = run(["dart", "run", "locale_gen"], path)
    return path, output


def read(path, relative):
    with open(os.path.join(path, relative), encoding="utf-8") as f:
        return f.read()


def members(source, names, keep_docs_for=()):
    """Pulls the generated members for [names] out of a raw generated file."""
    lines = source.split("\n")
    picked = []
    for name in names:
        pattern = re.compile(rf"^  \w+ (get )?{name}\b")
        for i, line in enumerate(lines):
            if not pattern.match(line):
                continue
            if name in keep_docs_for:
                start = i
                while start > 0 and lines[start - 1].startswith("  ///"):
                    start -= 1
                picked.extend(l[2:] for l in lines[start:i])
            signature = line[2:]
            if "=>" in signature:
                signature = signature.split("=>")[0] + "=> …"
            picked.append(signature)
            picked.append("")
            break
        else:
            raise SystemExit(f"member {name} not found in generated code")
    return "\n".join(picked).rstrip()


# --------------------------------------------------------------------------
# Images
# --------------------------------------------------------------------------

EN = """
{
  "greeting": "Hi, {name}!",
  "cart_count": "{count, plural, one {# item} other {# items}}",
  "total": "Total: {total, number, currency}",
  "welcome_back": "Welcome back %1$s"
}
"""

NL = """
{
  "greeting": "Hallo, {name}!",
  "cart_count": "{count, plural, one {# stuk} other {# stuks}}",
  "total": "Totaal: {total, number, currency}",
  "welcome_back": "Welkom terug %1$s"
}
"""

MAIN = """\
import 'package:my_app/util/locale/localization.dart';

void main() {
  final l = Localization.instance;
  final greeting = l.greeting(name: 'Koen');
  final cart = l.cartCount(count: 3);
  print('en: ${greeting.en} · ${cart.en}');
  print('nl: ${greeting.nl} · ${cart.nl}');
}
"""


def flutter_writer():
    config = """
    locale_gen:
      languages: ["en", "nl"]
    """
    path, output = project(config, {"en": EN, "nl": NL})
    generated = read(path, "lib/util/locale/localization.dart")
    shutil.rmtree(path)
    render(
        "flutter_writer",
        [
            [
                Window("assets/locale/en.json", "json", EN),
                Window(
                    "lib/util/locale/localization.dart (generated)",
                    "dart",
                    members(
                        generated,
                        ["greeting", "cartCount", "total", "welcomeBack"],
                        keep_docs_for=["greeting"],
                    ),
                ),
            ],
            [
                Window(
                    "lib/screen/cart_screen.dart",
                    "dart",
                    """
                    final localization = Localization.of(context);

                    Text(localization.greeting(name: 'Koen'));
                    Text(localization.cartCount(count: items.length));
                    Text(localization.total(total: cart.total));
                    Text(localization.welcomeBack(user.name));
                    """,
                ),
            ],
        ],
    )


def dart_writer():
    config = """
    locale_gen:
      languages: ["en", "nl"]
      output_type: dart
    """
    path, _ = project(
        config,
        {"en": EN, "nl": NL},
        dependencies="intl: ^0.20.2\nsprintf: ^7.0.0\n",
        files={"bin/main.dart": MAIN},
    )
    generated = read(path, "lib/util/locale/localization.dart")
    printed = run(["dart", "run", "bin/main.dart"], path)
    shutil.rmtree(path)

    value_class = re.search(r"class LocalizedValue \{.*?\n\}", generated, re.S).group()
    value_class = "\n".join(
        l for l in value_class.split("\n") if l.strip()
    )
    render(
        "dart_writer",
        [
            [
                Window("pubspec.yaml", "yaml", config),
                Window(
                    "lib/util/locale/localization.dart (generated)",
                    "dart",
                    value_class
                    + "\n\n"
                    + members(generated, ["greeting", "cartCount"]),
                ),
            ],
            [
                Window("bin/main.dart", "dart", MAIN),
                Window("terminal", "terminal", "$ dart run bin/main.dart\n" + printed),
            ],
        ],
    )


def cross_locale_warning():
    config = """
    locale_gen:
      languages: ["en", "nl"]
    """
    nl_with_typo = NL.replace("{name}", "{naam}")
    path, output = project(config, {"en": EN, "nl": nl_with_typo})
    shutil.rmtree(path)
    wrapped = []
    for line in output.strip().split("\n"):
        wrapped.extend(textwrap.wrap(line, 96, subsequent_indent="  ") or [""])
    render(
        "cross_locale_warning",
        [
            [
                Window(
                    "assets/locale/nl.json",
                    "json",
                    "\n".join(nl_with_typo.strip().split("\n")[:2]) + "\n  …\n}",
                ),
            ],
            [Window("terminal", "terminal", "$ dart run locale_gen\n" + "\n".join(wrapped))],
        ],
    )


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    flutter_writer()
    dart_writer()
    cross_locale_warning()
