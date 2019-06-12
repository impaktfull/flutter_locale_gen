# flutter locale gen

Dart tool that will convert your default locale json to dart code.

[![pub package](https://img.shields.io/pub/v/locale_gen.svg)](https://pub.dartlang.org/packages/locale_gen)

This repo contains an example how to use this package.

based on a package I made at icapps for the icapps translations -> https://github.com/icapps/flutter-icapps-translations

Packages used:
 - flutter_localizations
 - shared_preferences
 - provider
 - kiwi
 - locale_gen

## Example

<img src="https://github.com/vanlooverenkoen/locale_gen/blob/master/assets/example.gif?raw=true" alt="Example" width="300"/>

## Setup

### Add dependency to pubspec

[![pub package](https://img.shields.io/pub/v/locale_gen.svg)](https://pub.dartlang.org/packages/locale_gen)
```
dev-dependencies:
  locale_gen: <latest-version>
```

### Add config to pubspec

Add your locale folder to the assets to make use all your translations are loaded.
```
flutter:
  assets:
    - assets/locale/
```

Add the local_gen config to generate your dart code from json files
```
locale_gen:
  default_language: 'nl'
  languages: ['en', 'nl']
```

if nothing is configured the following config will be used:
```
locale_gen:
  default_language: 'en'
  languages: ['en']
```

### Run package with Flutter

```
flutter packages pub run locale_gen
```

### Run package with Dart

```
pub run locale_gen
```
