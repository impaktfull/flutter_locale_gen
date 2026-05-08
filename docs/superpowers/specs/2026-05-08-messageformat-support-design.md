# MessageFormat (ICU) Support — Design

**Status:** draft
**Date:** 2026-05-08

## Goal

Add ICU MessageFormat support to `flutter_locale_gen` so JSON translation values can use named placeholders (`{name}`), inline plurals (`{count, plural, one {# item} other {# items}}`), `select`, `selectordinal`, plus locale-aware `number`, `date`, `time`, and `duration` formatting. The codegen must produce type-safe Dart functions whose parameter names mirror the ICU placeholder names. Existing sprintf-style placeholders (`%s`, `%d`, `%1$s`) and JSON-object plurals must keep working unchanged.

## Non-goals

- Migrating existing translation files automatically.
- Deprecating the JSON-object plural format.
- Translator tooling, lint rules outside the generator, or runtime hot-reload of translations.

## Background

`flutter_locale_gen` parses JSON locale files and emits a typed `Localization` class. Today it supports two parameter styles:

- **sprintf-positional**: `%1$s`, `%1$d`, `%2$f` → `arg1`, `arg2` Dart parameters.
- **sprintf-non-positional**: `%s`, `%d` → `arg1`, `arg2` Dart parameters in textual order.

Plurals are encoded as a JSON object (`{ "one": "...", "other": "..." }`) and emitted as a function taking `num count`.

The runtime uses `package:sprintf` for substitution and `package:intl`'s `Intl.plural` for plural selection.

This design adds a third parameter style — ICU MessageFormat — that coexists with the two existing styles on a per-key basis.

## Detection

Detection happens per JSON key inside `core_generator.buildTranslationFunction`:

1. If the value is a `Map<String, dynamic>` → existing JSON-object plural path. Unchanged.
2. If the value is a `String`:
   - Contains ICU placeholder braces (`{...}` matching the parser's grammar) → **MessageFormat path**.
   - Contains `%s` / `%d` / `%1$s` style markers → existing sprintf path.
   - Contains both at once → generation warning, fall back to default getter.
   - Contains neither → existing default getter path.

A new optional flag `messageFormatStrict: bool` (default `false`) on `LocaleGenParams`: when `true`, encountering any sprintf marker triggers a warning and the key falls back to the default getter. This lets new projects commit to MessageFormat-only translations without forbidding the legacy format on existing projects.

Detection inspects only the **default-language** translation, matching the existing behavior for parameter discovery.

## Parser

A new module `lib/src/util/parser/message_format_parser.dart` parses ICU MessageFormat strings into an AST.

**Node types:**

- `LiteralNode(text)` — plain text, including ICU-escaped braces (`'{'`, `'}'`, `''`).
- `PlaceholderNode(name)` — `{name}`.
- `PluralNode(name, branches: { "zero" | "one" | "two" | "few" | "many" | "other" | "=N" → List<Node> })`.
- `SelectOrdinalNode(name, branches: ...)` — same shape as `PluralNode`.
- `SelectNode(name, branches: { String → List<Node> })`.
- `NumberNode(name, style)` — style is `null`, `"percent"`, `"currency"`, or a custom skeleton string.
- `DateNode(name, style)` — `"short" | "medium" | "long" | "full" | <custom skeleton>`.
- `TimeNode(name, style)` — same enum as `DateNode`.
- `DurationNode(name, style)` — `null | "short" | "medium" | "long" | <custom pattern>`.

The parser:

- Tracks brace depth and respects ICU escapes.
- Returns a `MessageFormatAst` containing the root node list and a discovered-params map keyed by original placeholder name.
- Throws `MessageFormatParseException` on malformed input. Callers downgrade this to a warning and fall back to the default getter for that key.

## Parameter discovery and naming

Parameter discovery walks the AST of the **default-language** translation and produces, per key, an ordered map of:

```
originalName → MessageFormatParam(
  originalName,        // exact ICU name as written (e.g., "SC")
  dartName,            // CaseUtil.getCamelcase(originalName) (e.g., "sc")
  dartType,            // String | num | DateTime | Duration
  formatter,           // null | NumberFormatter | DateFormatter | TimeFormatter | DurationFormatter
)
```

**Type inference table:**

| AST node | dartType |
|---|---|
| `PlaceholderNode` | `String` |
| `PluralNode` | `num` |
| `SelectOrdinalNode` | `num` |
| `SelectNode` | `String` |
| `NumberNode` | `num` |
| `DateNode` | `DateTime` |
| `TimeNode` | `DateTime` |
| `DurationNode` | `Duration` |

**Conflict policy:**

- If the same `originalName` appears in the AST with two incompatible `dartType`s (e.g., once as `{x, number}`, again as `{x, date}`), the generator logs a warning and falls back to the default getter for that key.
- After camelCase normalization, if two distinct `originalName`s collide on the same `dartName` (e.g., `{SC}` and `{sc}` both → `sc`), the generator logs a warning and falls back to the default getter for that key.

Other locales are not parsed for parameter discovery, matching the current behavior.

## Generated function shape

For a MessageFormat key, the generator emits a function with **named, required** Dart parameters in the order ICU placeholders first appear in the default-language string. The Dart parameter names are camelCased; the runtime arg map preserves the original ICU names so substitution still matches the JSON.

Example — `confirm_terms` defined as `I, {profileName}, accept the <a href="{SC}">terms</a>.`:

```dart
String confirmTerms({
  required String profileName,
  required String sc,
}) =>
    _mf(LocalizationKeys.confirmTerms, args: {
      'profileName': profileName,
      'SC': sc,
    });
```

Example — `cart_count` defined as `{count, plural, one {# item} other {# items}}`:

```dart
String cartCount({required num count}) =>
    _mf(LocalizationKeys.cartCount, args: {'count': count});
```

Example — `order_placed` defined as `Order on {placedAt, date, short} for {total, number, currency}`:

```dart
String orderPlaced({required DateTime placedAt, required num total}) {
  final tag = locale?.toLanguageTag();
  return _mf(LocalizationKeys.orderPlaced, args: {
    'placedAt': DateFormat.yMd(tag).format(placedAt),
    'total': NumberFormat.simpleCurrency(locale: tag).format(total),
  });
}
```

Sprintf keys keep their existing positional `arg1`, `arg2` signatures untouched.

## Runtime helpers

When a project contains at least one MessageFormat key, the generator adds the following private helpers to `Localization`:

```dart
String _mf(String key, {required Map<String, Object> args}) {
  try {
    final value = (_localisedOverrideValues[key] ?? _localisedValues[key]) as String?;
    if (value == null) return key;
    final stripped = _stripFormatSpecs(value);
    return MessageFormat(stripped, locale: locale?.toLanguageTag()).format(args);
  } catch (e) {
    return '⚠$key⚠';
  }
}

String _stripFormatSpecs(String value) { /* regex rewrite */ }
```

`_stripFormatSpecs` rewrites `{name, date, ...}`, `{name, time, ...}`, `{name, number, ...}`, and `{name, duration, ...}` to plain `{name}` so the runtime `MessageFormat` parser (which doesn't understand those arg types) accepts the template. `plural`, `select`, and `selectordinal` are left untouched. The regex must respect ICU escaping rules.

When duration is used, an additional helper `_formatDuration(Duration d, String? style)` is emitted. It supports:

| Style | Output |
|---|---|
| `null` (default) | zero-padded `HH:mm:ss` |
| `short` | zero-padded `mm:ss` |
| `medium` | zero-padded `HH:mm:ss` |
| `long` | localized `1h 5m 30s`-style using a small label table generated alongside |
| custom pattern (e.g., `HH:mm:ss`, `H'h' mm'm'`) | `H` / `m` / `s` substituted with zero-padded values; literal text in single quotes preserved |

Date/time/number formatters use the existing `package:intl` factories:

| ICU style | intl factory |
|---|---|
| `{x, date, short}` | `DateFormat.yMd(tag)` |
| `{x, date, medium}` | `DateFormat.yMMMd(tag)` |
| `{x, date, long}` | `DateFormat.yMMMMd(tag)` |
| `{x, date, full}` | `DateFormat.yMMMMEEEEd(tag)` |
| `{x, time, short}` | `DateFormat.jm(tag)` |
| `{x, time, medium\|long\|full}` | `DateFormat.jms(tag)` |
| `{x, date, <skeleton>}` | `DateFormat(skeleton, tag)` |
| `{x, number}` | `NumberFormat.decimalPattern(tag)` |
| `{x, number, percent}` | `NumberFormat.percentPattern(tag)` |
| `{x, number, currency}` | `NumberFormat.simpleCurrency(locale: tag)` |
| `{x, number, <skeleton>}` | `NumberFormat(skeleton, tag)` |

If a style doesn't match any of the above, the generator logs a warning and falls back to the default getter for that key.

## Imports

When MessageFormat keys exist, the generated localization file adds:

- `import 'package:intl/intl.dart';` (already conditionally imported for plurals — reused unconditionally now)
- `import 'package:intl/message_format.dart';` (new)

The Dart writer adds the same imports without the Flutter-specific `flutter/services.dart` and `flutter/widgets.dart`.

## Configuration

`LocaleGenParams` gains one new field:

```dart
final bool messageFormatStrict; // defaults to false
```

Loaded from the same YAML config that already feeds `LocaleGenParams`. No CLI flag — config-only.

## File layout

**New files:**

- `lib/src/util/parser/message_format_parser.dart`
- `lib/src/model/message_format_param.dart`
- `lib/src/model/message_format_ast.dart`
- `lib/src/util/format/duration_format_util.dart` (template strings for the emitted runtime helper)

**Modified files:**

- `lib/src/writer/core_generator.dart` — add MessageFormat detection branch and an abstract `buildMessageFormatFunction` callback.
- `lib/src/writer/flutter/flutter_generator.dart` — implement `buildMessageFormatFunction`; emit `_mf`, `_stripFormatSpecs`, conditionally `_formatDuration`; add intl imports.
- `lib/src/writer/dart/dart_generator.dart` — implement `buildMessageFormatFunction`; emit the same helpers without Flutter imports.
- `lib/src/model/locale_gen_params.dart` — add `messageFormatStrict`.
- `lib/src/locale_gen_constants.dart` — add ICU brace-detection regex.

## Tests

- `test/src/util/parser/message_format_parser_test.dart` — coverage for: simple placeholders; plural with `=N` and CLDR keywords; selectordinal; select with default branch; nested plural inside select; date/time/number/duration with each style; ICU escape sequences (`'{'`, `'}'`, `''`); malformed input throwing `MessageFormatParseException`.
- `test/src/model/message_format_param_test.dart` — type inference, camelCase normalization, conflict detection.
- `test/src/writor/flutter/flutter_generator_test.dart` — extended fixtures covering each ICU node type producing expected Dart.
- `test/src/writor/dart/dart_generator_test.dart` — new file mirroring the Flutter cases without Flutter imports.
- `test/assets/locale/` — new JSON fixtures with MessageFormat keys (using generic invented strings; no third-party copy).

## Error handling summary

| Situation | Behavior |
|---|---|
| Malformed ICU template | Warning + default getter |
| Mixed sprintf and ICU markers in same key | Warning + default getter |
| Unknown date/time/number style | Warning + default getter |
| Param type collision (same name, different ICU types) | Warning + default getter |
| camelCase param name collision | Warning + default getter |
| `messageFormatStrict: true` and key contains sprintf markers | Warning + default getter |
| Runtime `MessageFormat.format` throws | Returns `'⚠key⚠'` (matches existing `_t` behavior) |

## Documentation

- README: new "MessageFormat support" section with the table of supported ICU types and end-to-end examples (using invented strings only).
- CHANGELOG: entry under a new minor version describing the additive change.
- `pubspec.yaml`: minor version bump.

## Out of scope

- Validating that all locales declare the same parameter set — current behavior (default-language-only discovery) is preserved.
- A migration tool from sprintf or JSON-object plurals to MessageFormat.
- Removing or deprecating the legacy formats.
