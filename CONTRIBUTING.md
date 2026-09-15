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

dart test                  # unit tests
flutter analyze            # the package and both examples
./tool/translations.sh     # regenerate both examples with your changes, then format
```

A change to the generator usually changes the generated code in the examples. Run `./tool/translations.sh` and commit the result: CI fails when the checked-in example code is out of date.

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

```shell
# Code and terminal images in assets/docs/. Needs Dart and Google Chrome.
# Every generated line and terminal line in them comes from a real run of this checkout.
python3 tool/docs_media/render_snippets.py

# assets/example.gif and assets/example.png. Needs a booted iOS simulator,
# Flutter and python3 with Pillow (pip install pillow).
./tool/docs_media/record_flutter_example.sh
```

The recording drives `example_flutter/integration_test/docs_media_test.dart` through every language while screenshots are taken. Change the app, or that test, to change what the recording shows. Close other apps on the simulator first: iOS otherwise shows a "◀ previous app" breadcrumb in the status bar of the recording.
