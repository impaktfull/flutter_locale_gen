# Configuration

locale_gen reads a `locale_gen:` block from the `pubspec.yaml` of the project you run it in. Run every command from that project's root.

```yaml
locale_gen:
  languages: ["en", "nl", "zh-Hans-CN", "fi-FI"]  # Required
  default_language: "en"
  output_type: flutter
  output_path: "lib/util/locale/"
  assets_path: "assets/locale/"
  locale_assets_path: "assets/locale/"
  doc_languages: ["en"]
  message_format_strict: false
```

## Options

| Option                  | Default                                              | Description |
| ----------------------- | ---------------------------------------------------- | ----------- |
| `languages`             | none, required                                       | Every language you ship. Each needs a `<language>.json` file. Use language tags such as `en`, `fi-FI` or `zh-Hans-CN`. |
| `default_language`      | `en` if it is in `languages`, otherwise the first entry | The language every other language is compared against. Its keys decide which getters and functions are generated. Must be in `languages`. |
| `output_type`           | `flutter`                                            | `flutter` or `dart`. See [Flutter or Dart output?](../README.md#flutter-or-dart-output). Any other value falls back to `flutter`. |
| `output_path`           | `lib/util/locale/`                                   | Where the generated files are written. Must start with `lib/`, because the generated files import each other through `package:` imports. |
| `assets_path`           | `assets/locale/`                                     | Flutter writer: where the JSON files live in your **asset bundle**. The generated `Localization.load` reads `<assets_path><language>.json`. Also the folder `locale_gen:format` formats. |
| `locale_assets_path`    | `assets/locale/`                                     | Where the JSON files live **on disk**, read by the generator. Only different from `assets_path` when another tool or package puts your translations in the bundle. |
| `doc_languages`         | all `languages`                                      | Which translations appear in the doc comment above every generated member. `[]` disables doc comments. Every entry must be in `languages`. |
| `message_format_strict` | `false`                                              | When `true`, a key that uses sprintf markers (`%s`, `%1$d`) prints a warning and is generated as a plain getter. Use it to keep an ICU-only project ICU-only. See [Translation formats](translation-formats.md#strict-mode). |

Without a `locale_gen:` block at all, the generator assumes `languages: ["en"]` and every default above.

## Commands

```shell
dart run locale_gen          # generate
dart run locale_gen:format   # format the JSON files
```

`flutter pub run locale_gen` and `flutter packages pub run locale_gen` still work in older setups, but `dart run` is the current command for both Flutter and Dart projects.

### Generating

Generation prints the default and supported languages, any [warnings](translation-formats.md#warnings) and `Done!!!`. The output files are regular Dart files: commit them, and regenerate after every change to a JSON file. The example projects use a small script for this, see [`example_flutter/tool/translations.sh`](../example_flutter/tool/translations.sh).

### Formatting

`dart run locale_gen:format` rewrites `<assets_path><language>.json` for every language:

- keys are sorted alphabetically,
- keys are converted to snake_case (`welcomeBack` becomes `welcome_back`),
- the file is indented with two spaces.

It formats `assets_path`, not `locale_assets_path`. If the two differ in your project, format the files in `locale_assets_path` another way.

## Keys and generated names

A JSON key becomes a camelCase Dart name. Spaces, `.`, `/`, `_` and `-` separate words, and so does an uppercase letter:

| JSON key               | Dart member           |
| ---------------------- | --------------------- |
| `welcome_back`         | `welcomeBack`         |
| `settings.title`       | `settingsTitle`       |
| `profile/edit-button`  | `profileEditButton`   |
| `cartCount`            | `cartCount`           |

Keep keys unique after that conversion: `welcome_back` and `welcomeBack` would both generate `welcomeBack`.

ICU placeholder names are converted the same way to become parameter names, so `{placed_at, date}` becomes a `placedAt` parameter.

## Documentation comments

Every generated member gets a doc comment with its translation in each of `doc_languages`, so hovering a call in your IDE shows the text:

```dart
/// Translations:
///
/// en:  **'Hi, {name}!'**
///
/// nl:  **'Hallo, {name}!'**
String greeting({required String name}) => _mf(LocalizationKeys.greeting, args: {'name': name});
```

Positional sprintf arguments are shown as `[arg1 string]` and `[arg1 number]`. In a project with many languages, limit `doc_languages` to the one or two you read, to keep the generated files small.
