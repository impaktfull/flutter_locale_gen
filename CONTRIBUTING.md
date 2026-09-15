# Contributing

## Repository layout

| Path               | Contains |
| ------------------ | -------- |
| `lib/`             | The generator. `locale_gen_writer.dart` reads the JSON files and hands them to a writer in `lib/src/writer/` (`flutter/` or `dart/`) |
| `bin/`             | The `locale_gen` and `locale_gen:format` entry points |
| `test/`            | Unit tests for parsing, generation and validation |
| `example_flutter/` | The Flutter example app, with generated code checked in |
| `example_dart/`    | The Dart example program, with generated code checked in |
| `doc/`             | Guides, migration guides and deprecation notes |
| `assets/`          | The images and GIF used in the documentation |
| `tool/`            | Scripts for regenerating the examples, formatting and documentation media |

## Local development

```shell
dart pub get
(cd example_dart && dart pub get)
(cd example_flutter && flutter pub get)

dart test                  # all tests
dart run tool/coverage.dart  # all tests, plus the 100% coverage gate CI runs
flutter analyze            # the package and both examples
./tool/translations.sh     # regenerate both examples with your changes, then format
```

A change to the generator usually changes the generated code in the examples. Run `./tool/translations.sh` and commit the result: CI fails when the checked-in example code is out of date.

## How it works

```
bin/locale_gen.dart
  └─ LocaleGenParams('locale_gen')          reads the locale_gen: section of pubspec.yaml
  └─ LocaleGenWriter.write(params)          reads <locale_assets_path>/<language>.json
       └─ LocaleGenCoreWriter.fromType(output_type)
            ├─ LocaleGenFlutterWriter  ─► LocaleGenFlutterGenerator   4 files
            └─ LocaleGenDartWriter     ─► LocaleGenDartGenerator      1 file

For every key, LocaleGenCoreGenerator.buildTranslationFunction picks a builder:
  TranslationStyleDetector ─┬─ plain text        ─► buildDefaultFunction
                            ├─ sprintf           ─► buildParameterizedFunction
                            ├─ JSON-object plural ─► build(Parameterized)PluralFunction
                            └─ MessageFormat     ─► MessageFormatParser
                                                     ─► MessageFormatParamExtractor
                                                     ─► buildMessageFormatFunction
```

Generators only build strings, and writers only write files, so almost everything is tested without touching the file system.

## Tests and TDD

Every change starts with a failing test. CI enforces 100% line coverage and one test file per source file, so there is always an obvious place for that test.

| Where                                         | What it tests |
| --------------------------------------------- | ------------- |
| `test/src/**/<name>_test.dart`                | The file with the same path in `lib/src/`. `tool/coverage.dart` fails when one is missing |
| `test/bin/<name>_test.dart`                   | The command in `bin/`, run against a throwaway project |
| `test/locale_gen_test.dart`                   | **The public API.** Every exported signature, and a `LocaleGenParams` subclass used the way impaktfull_translations and icapps_translations use it |
| `test/golden_test.dart`                       | The complete generated code for both writers, compared with `test/goldens/` |
| `test/generated_dart_runtime_test.dart`       | Runs generated Dart code and snapshots what every format renders to |

Helpers in `test/helpers/`:

- `TestProject` creates a temporary project and runs code with it as the current directory, capturing what is printed. Use it for anything that reads or writes files. It is safe with tests running in parallel.
- `expectGolden` compares output with a file in `test/goldens/`.

### When the generated code changes

`test/golden_test.dart` fails and shows the difference. Review it; when the new output is what you intended, update the goldens and commit them with your change:

```shell
UPDATE_GOLDENS=true dart test test/golden_test.dart test/generated_dart_runtime_test.dart
```

To cover a new translation format, add it to `test/goldens/fixture/*.json` first.

### Keeping the public API stable

The public API is what `lib/locale_gen.dart` exports, the `locale_gen:` options in `pubspec.yaml`, the `bin/` commands and the shape of the generated code. New features go in `lib/src/`: a new format is a new branch in `buildTranslationFunction` with its own builder, a new output is a new `LocaleGenCoreWriter`. Adding an option or a generated member is fine. If `test/locale_gen_test.dart` or an existing golden has to change in a way that breaks users, the change is breaking: use `feat!:` and add a migration guide.

### Lines that can never run

Remove them instead of testing around them. The only exception is a line that exists for the type system, such as the private constructors of the exported `LocaleGenWriter` and `LocaleGenFormatter`: mark those with `// coverage:ignore-line` and a comment saying why.

## Commits and pull requests

This repository uses [Conventional Commits](https://www.conventionalcommits.org), because releases are derived from them. Pull requests are squash-merged, so the **pull request title** is the commit that counts:

| Title                                        | Release            |
| -------------------------------------------- | ------------------ |
| `fix: escape quotes in doc comments`         | patch (13.0.1)     |
| `feat: support ICU number skeletons`         | minor (13.1.0)     |
| `feat!: drop the legacy plural format`       | major (14.0.0)     |
| `docs:`, `test:`, `ci:`, `chore:`, `refactor:` | no release on their own |

A breaking change also needs a migration guide in `doc/migrations/<version>.md` and a row in the README's migration table.

## Releases

Releases are automated with [release-please](https://github.com/googleapis/release-please) and published to pub.dev by GitHub Actions.

1. Every push to `main` runs `.github/workflows/release.yml`. release-please keeps one open **release PR** that bumps `version` in `pubspec.yaml` and adds the new section to `CHANGELOG.md`, based on the commits since the last release.
2. Merging that PR makes release-please create the GitHub release and push the tag `vX.Y.Z`.
3. The tag push runs `.github/workflows/publish.yml`, which publishes to pub.dev.

To release, review and merge the release PR. Nothing else is needed.

### Why the release workflow uses a PAT

pub.dev only accepts an automated publish from a workflow **triggered by a tag push**, and a tag pushed with the default `GITHUB_TOKEN` does not trigger other workflows. release-please therefore runs with the `IMPAKTFULL_GITHUB_PAT` secret. If that token expires, releases are still created but nothing is published, so renew it and re-run the failed workflow.

### pub.dev settings

The package's admin page on pub.dev must have automated publishing from GitHub Actions enabled for `impaktfull/flutter_locale_gen`, with tag pattern `v{{version}}` and the `pub.dev` environment. `publish.yml` depends on both.

### A publish failed

The tag and GitHub release already exist, so do not create them again. Fix the cause, then re-run the failed **Publish to pub.dev** run from the Actions tab: a re-run keeps its original tag-push trigger, which pub.dev accepts. If the fix needs code changes, release them as a new patch version instead.

### Forcing a version

To release a specific version, for example a pre-release, set `"release-as": "x.y.z"` for the package in `release-please-config.json`. Remove it again once that release is merged.

### First release after the switch

The versions up to 13.0.0-alpha.2 were released by hand. `bootstrap-sha` in `release-please-config.json` points at the 12.6.0 commit, so the first release PR only contains the changes after it. It can be removed after the first release-please release is merged.

## Documentation media

The GIF, the still and the code images in `assets/` are generated, so they can be refreshed after a change instead of going stale.

Run both from the repository root:

```shell
# Code and terminal images in assets/docs/. Needs Google Chrome.
# Every generated line and terminal line in them comes from a real run of this checkout.
dart run tool/docs_media/render_snippets.dart

# assets/example.gif and assets/example.png. Needs Flutter and a booted iOS simulator.
dart run tool/docs_media/record_flutter_example.dart
```

The recording drives `example_flutter/integration_test/docs_media_test.dart` through every language while screenshots are taken. Change the app, or that test, to change what the recording shows. Close other apps on the simulator first: iOS otherwise shows a "◀ previous app" breadcrumb in the status bar of the recording.
