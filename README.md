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

```
dependencies:
  sprintf: ^6.0.2

dev-dependencies:
  locale_gen: <latest-version>
```

### Add config to pubspec

Add your locale folder to the assets to make use all your translations are loaded.

```yaml
flutter:
  assets:
    - assets/locale/
```

Add the local_gen config to generate your dart code from json files

```yaml
locale_gen:
  default_language: "nl"
  languages: ["en", "nl"]
  locale_assets_path: "assets/locale/" #This is the location where your json files should be saved.
  assets_path: "assets/locale/" #This is the location where your json files are located in your flutter app.
  output_path: "lib/util/locale/" #This is the location where your localization files will be created in your flutter app.
  doc_languages: ["en"] #Only generate docs for the given languages. Defaults to all languages. An empty list will skip doc generation
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

Since version _10.0.0_ you can specify the bundle to load the assets from in the `load` function.
This can be used as an alternative to overriding translations, fetching them from the network, ...

### Arguments

Arguments are supported as of 0.1.0

You can pass a String, an integer or a double to as an argument. (int and double since 8.0.0, num before that)

Since 8.0.0 you can use more specifications from C's sprintf to apply format to numbers. If any modifier is causing a mismatch, please create a ticket

Formatting for String: %1$s
Formatting for int: %1$d
Formatting for double: %1$f

The number in between % and $ indicate the index of the argument. It is possible to place an argument in 1 language first but in another second:

ex (Grammatically incorrect but it makes my point):

```
nl '%1$s, ik woon in %2$s. Wist je dat niet?' => KOEN, ik woon in ANTWERPEN. Wist je dat niet?

fr 'I live in %2$s. You didn't knew that %1$s?" => I live in ANTWERP. You didn't knew that KOEN?
```

_Note:_ As of 6.0.0 non-positional arguments are also supported. You **cannot** use both positional and non-positional arguments in the same string.
Example:

```
'%s, ik woon in %s. Wist je dat niet?' => KOEN, ik woon in ANTWERPEN. Wist je dat niet?
```

### Plurals

Plurals are best expressed using ICU MessageFormat — see [MessageFormat → Plural](#plural) below.

> Extra support: locale_gen also supports a legacy JSON-object plural format for backwards compatibility. See [docs/deprecation/json-object-plurals.md](docs/deprecation/json-object-plurals.md) for details.

## Migration guides

When upgrading across a major version, see the relevant guide:

| From   | To      | Guide                                                |
| ------ | ------- | ---------------------------------------------------- |
| <7.0.0 | >=7.0.0 | [docs/migrations/7.0.0.md](docs/migrations/7.0.0.md) |
| <9.0.0 | >=9.0.0 | [docs/migrations/9.0.0.md](docs/migrations/9.0.0.md) |

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
