# locale_gen

Generate a type-safe, documented Dart API from JSON translation files, for Flutter apps and for plain Dart projects.

[![pub package](https://img.shields.io/pub/v/locale_gen.svg)](https://pub.dev/packages/locale_gen)
[![Validate](https://github.com/impaktfull/flutter_locale_gen/actions/workflows/validate.yml/badge.svg)](https://github.com/impaktfull/flutter_locale_gen/actions/workflows/validate.yml)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

<img src="https://raw.githubusercontent.com/impaktfull/flutter_locale_gen/main/assets/example.gif" alt="The example app switching between English, Dutch, Finnish, Chinese and translation keys" width="320"/>

- **One JSON file per language.** No ARB files and no annotations. Your translators edit plain JSON.
- **A generated Dart API.** Every key becomes a getter or a typed function, with every translation in its doc comment, so your IDE shows the text on hover.
- **sprintf and ICU MessageFormat.** Use `"Hi %1$s"` or `"{count, plural, one {# item} other {# items}}"`. The format is detected per key, so both can live in one project.
- **Two writers.** The `flutter` writer loads translations at runtime through a `LocalizationsDelegate`. The `dart` writer compiles every language into code, for CLIs, servers and shared packages.
- **Made for real apps.** Runtime overrides (translations from your backend), filtering locales at runtime, a "show keys" mode for QA and tests, and warnings when a translation uses the wrong placeholder name.

## Documentation

| Guide                                                    | What is in it                                                                        |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [Configuration](doc/configuration.md)                    | Every `locale_gen:` option in `pubspec.yaml`, the commands and how keys are named      |
| [Flutter writer](doc/flutter-writer.md)                  | App setup, switching language, overrides, locale filtering, show keys, testing        |
| [Dart writer](doc/dart-writer.md)                        | Using translations without Flutter, `LocalizedValue`, requirements                    |
| [Translation formats](doc/translation-formats.md)        | Plain strings, sprintf arguments, ICU MessageFormat, validation and known limitations  |
| [Legacy JSON-object plurals](doc/deprecation/json-object-plurals.md) | The pre-ICU plural format, which is still supported                        |
| [Migration guides](#migration-guides)                    | Step-by-step upgrades across major versions                                           |
| [Contributing](CONTRIBUTING.md)                          | Local development, commit conventions and how releases are published                 |

## Quick start (Flutter)

### 1. Add the dependencies

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  sprintf: ^7.0.0

dev_dependencies:
  locale_gen: ^13.0.0 # x-release-please-version
```

The generated code imports `sprintf` and `intl`, which is why they are regular dependencies of your app.

### 2. Write your translations

One file per language, in `assets/locale/`:

```json
// assets/locale/en.json
{
  "greeting": "Hi, {name}!",
  "cart_count": "{count, plural, one {# item} other {# items}}",
  "welcome_back": "Welcome back %1$s"
}
```

```json
// assets/locale/nl.json
{
  "greeting": "Hallo, {name}!",
  "cart_count": "{count, plural, one {# stuk} other {# stuks}}",
  "welcome_back": "Welkom terug %1$s"
}
```

### 3. Configure `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/locale/

locale_gen:
  languages: ["en", "nl"]
```

All other options have defaults. See [Configuration](doc/configuration.md).

### 4. Generate

```shell
dart run locale_gen
```

This writes four files to `lib/util/locale/`. Commit them and run the command again whenever a JSON file changes.

<img src="https://raw.githubusercontent.com/impaktfull/flutter_locale_gen/main/assets/docs/flutter_writer.png" alt="JSON translations on the left, the generated typed Dart functions on the right, and a widget using them below"/>

### 5. Register the delegate and use your translations

```dart
MaterialApp(
  localizationsDelegates: [
    LocalizationDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: LocalizationDelegate.supportedLocales,
  home: const HomeScreen(),
);
```

```dart
final localization = Localization.of(context);

Text(localization.greeting(name: 'Koen'));   // Hi, Koen!
Text(localization.cartCount(count: 3));      // 3 items
Text(localization.welcomeBack('Koen'));      // Welcome back Koen
```

Switching language at runtime, overrides and testing are covered in the [Flutter writer guide](doc/flutter-writer.md).

## Flutter or Dart output?

Pick the writer with `output_type`. Both read the same JSON files and support the same translation formats, except for [legacy JSON-object plurals](doc/deprecation/json-object-plurals.md), which only the Flutter writer supports.

|                              | `output_type: flutter` (default)                                     | `output_type: dart`                                          |
| ---------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------ |
| Use it for                   | Flutter apps                                                         | CLIs, servers, shared packages, anything without Flutter     |
| Translations are             | Loaded from your asset bundle at runtime                             | Compiled into the generated code                             |
| One call returns             | A `String` in the active locale                                      | A `LocalizedValue` with a field per language (`.en`, `.nl`)  |
| Generated files              | `localization.dart`, `localization_keys.dart`, `localization_delegate.dart`, `localization_overrides.dart` | `localization.dart`                   |
| Runtime overrides, locale filter, show keys | Yes                                                   | No                                                           |
| Missing key in a language    | Falls back to the key at runtime                                     | Generation fails, naming the key and language                |
| Guide                        | [Flutter writer](doc/flutter-writer.md)                              | [Dart writer](doc/dart-writer.md)                            |

<img src="https://raw.githubusercontent.com/impaktfull/flutter_locale_gen/main/assets/docs/dart_writer.png" alt="output_type dart in pubspec.yaml generates a LocalizedValue class, and a Dart program prints the English and Dutch translations"/>

## Translation formats at a glance

| You write                                                  | You call                                   |
| ---------------------------------------------------------- | ------------------------------------------ |
| `"Settings"`                                               | `localization.settings`                    |
| `"Hi %1$s, you have %2$d messages"`                        | `localization.inbox('Koen', 3)`            |
| `"Hi, {name}!"`                                            | `localization.greeting(name: 'Koen')`      |
| `"{count, plural, one {# item} other {# items}}"`          | `localization.cartCount(count: 3)`         |
| `"{gender, select, male {he} female {she} other {they}}"`  | `localization.pronoun(gender: 'female')`   |
| `"Placed on {placedAt, date, medium}"`                     | `localization.placedAt(placedAt: DateTime.now())` |
| `"Total: {total, number, currency}"`                       | `localization.total(total: 12.5)`          |
| `"Lap time: {lap, duration, mm:ss}"`                       | `localization.lapTime(lap: elapsed)`       |

When a translation uses a different placeholder name than the default language, you get a warning at generation time instead of a broken string in production:

<img src="https://raw.githubusercontent.com/impaktfull/flutter_locale_gen/main/assets/docs/cross_locale_warning.png" alt="A Dutch translation uses {naam} instead of {name} and dart run locale_gen prints a warning naming the key and locale"/>

All details, including escaping, strict mode and known limitations: [Translation formats](doc/translation-formats.md).

## Commands

| Command                       | What it does                                                                    |
| ----------------------------- | ------------------------------------------------------------------------------- |
| `dart run locale_gen`         | Generates the Dart code from your JSON files                                    |
| `dart run locale_gen:format`  | Sorts the keys of every JSON file alphabetically and rewrites keys to snake_case |

## Migration guides

Upgrading across a major version? Follow every guide between your version and the one you are moving to.

| From      | To         | Guide                                             | In short                                                         |
| --------- | ---------- | ------------------------------------------------- | ---------------------------------------------------------------- |
| < 8.0.0   | >= 8.0.0   | [doc/migrations/8.0.0.md](doc/migrations/8.0.0.md)   | Add `sprintf`; `%d` is now `int`, use `%f` for `double`           |
| < 11.0.0  | >= 11.0.0  | [doc/migrations/11.0.0.md](doc/migrations/11.0.0.md) | `Localization.of(context)` is back; reverts 7.0.0 and 9.0.0      |
| < 13.0.0  | >= 13.0.0  | [doc/migrations/13.0.0.md](doc/migrations/13.0.0.md) | ICU MessageFormat detection can change a few getters into functions |

Superseded guides, kept for projects pinned to those versions: [7.0.0](doc/migrations/7.0.0.md) (translations without a context) and [9.0.0](doc/migrations/9.0.0.md) (managing `Localization` instances). Both were reverted in 11.0.0.

Every release and its changes are listed in the [CHANGELOG](CHANGELOG.md).

## Examples

- [`example_flutter`](example_flutter): the app from the recording above, with every translation format, runtime overrides, locale switching and show keys.
- [`example_dart`](example_dart): a Dart program using `output_type: dart`.

## Packages built on locale_gen

- [impaktfull_translations](https://pub.dev/packages/impaktfull_translations)
- [icapps_translations](https://pub.dev/packages/icapps_translations)

These reuse `LocaleGenParams` and `LocaleGenWriter`, which are exported from `package:locale_gen/locale_gen.dart`.
