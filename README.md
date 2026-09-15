# flutter locale gen

Dart tool that will convert your default locale json to dart code.

[![pub package](https://img.shields.io/pub/v/locale_gen.svg)](https://pub.dartlang.org/packages/locale_gen)
[![Coverage Status](https://coveralls.io/repos/github/Impaktfull/flutter_locale_gen/badge.svg)](https://coveralls.io/github/Impaktfull/flutter_locale_gen)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

## Example

<img src="https://github.com/impaktfull/flutter_locale_gen/blob/main/assets/example.gif?raw=true" alt="Example" width="300"/>

## Setup

### Add dependency to pubspec

[![pub package](https://img.shields.io/pub/v/locale_gen.svg)](https://pub.dartlang.org/packages/locale_gen)

```yaml
dependencies:
  sprintf: ^6.0.2

dev_dependencies:
  locale_gen: <latest-version>
```

### Add config to pubspec

Add your locale folder to the assets so all your translations are loaded at runtime:

```yaml
flutter:
  assets:
    - assets/locale/
```

Add a `locale_gen:` block to your `pubspec.yaml`. All keys other than `languages` are optional — defaults are shown below.

```yaml
locale_gen:
  languages: ["en", "nl"]                # Required: all supported languages.
  default_language: "en"                 # Default: "en" if present in `languages`, otherwise the first entry.
  output_type: "flutter"                 # Default: "flutter". Use "dart" for non-Flutter projects (returns a LocalizedValue per key).
  output_path: "lib/util/locale/"        # Where generated Dart files are written. Must start with `lib/`.
  assets_path: "assets/locale/"          # Where the JSON files live in your app's asset bundle (loaded at runtime).
  locale_assets_path: "assets/locale/"   # Where the JSON files live on disk (read by the generator).
  doc_languages: ["en"]                  # Languages to include in dartdoc comments above each getter. Default: all `languages`. Empty list disables doc comments.
  message_format_strict: false           # When true, sprintf markers in a MessageFormat-aware project emit a warning. See "MessageFormat (ICU) support → Strict mode".
```

### Run package with Flutter

```shell
flutter packages pub run locale_gen
```

### Run package with Dart

```shell
dart pub run locale_gen
```

### Format your locale file in Flutter

```shell
flutter packages pub run locale_gen:format
```

### Format your locale file in Dart

```shell
dart pub run locale_gen:format
```

### Custom asset bundle

Since version _10.0.0_ you can specify the bundle to load the assets from in the `load` function. This can be used as an alternative to overriding translations, fetching them from the network, etc.

## Arguments

Translations can take typed sprintf-style arguments. Three primitive types are supported: `String`, `int`, and `double`. (Available since 0.1.0; `int`/`double` distinction since 8.0.0 — earlier versions used `num`.)

### String — `%s` / `%1$s`

```json
{
  "greeting": "Hi %1$s!"
}
```

generates:

```dart
String greeting(String arg1);
```

### int — `%d` / `%1$d`

```json
{
  "items_count": "You have %1$d items"
}
```

generates:

```dart
String itemsCount(int arg1);
```

### double — `%f` / `%1$f`

```json
{
  "balance": "Your balance is %1$.02f"
}
```

generates:

```dart
String balance(double arg1);
```

The `.02f` modifier follows the [sprintf](https://pub.dev/packages/sprintf) package's format specifiers and controls precision. Other sprintf modifiers work too — open an issue if any cause a mismatch.

### Positional vs non-positional

**Positional** uses `%<index>$<type>`, where the number between `%` and `$` is the argument index. This lets translators reorder arguments per language:

```json
{
  "intro_en": "I live in %2$s. Did you know that %1$s?",
  "intro_nl": "%1$s, ik woon in %2$s. Wist je dat niet?"
}
```

**Non-positional** uses `%<type>` and arguments are taken in declaration order (supported since 6.0.0):

```json
{
  "intro": "%s, ik woon in %s. Wist je dat niet?"
}
```

You **cannot** mix positional and non-positional markers in the same string.

For named parameters, gendered text, locale-aware date/number/duration formatting, or inline plurals, see [MessageFormat (ICU) support](#messageformat-icu-support) below.

## Plurals

Plurals are best expressed using ICU MessageFormat — see [MessageFormat → Plural](#plural) below.

> Extra support: locale_gen also supports a legacy JSON-object plural format for backwards compatibility. See [doc/deprecation/json-object-plurals.md](doc/deprecation/json-object-plurals.md) for details.

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

### Default-locale fallback

If `Localization.locale` is `null` at runtime, MessageFormat substitution and locale-aware number/date/time formatting fall back to the project's default locale (`LocalizationDelegate.defaultLocale`). You don't have to special-case the null path.

### Limitations

- The dynamic `getTranslation(key, args:)` method on `Localization` is sprintf-only; calling it with a MessageFormat key returns the raw template (`"Hi, {name}!"`) without substitution. For MessageFormat keys, use the generated typed function (e.g., `Localization.of(context).greeting(name: 'Alice')`).

## Other packges based on locale_gen

- impaktfull_translations
- icapps_translations

## Migration guides

When upgrading across a major version, see the relevant guide:

| From   | To      | Guide                                                |
| ------ | ------- | ---------------------------------------------------- |
| <7.0.0 | >=7.0.0 | [doc/migrations/7.0.0.md](doc/migrations/7.0.0.md)   |
| <9.0.0 | >=9.0.0 | [doc/migrations/9.0.0.md](doc/migrations/9.0.0.md)   |
