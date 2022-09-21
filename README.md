# flutter locale gen

Dart tool that will convert your default locale json to dart code.

[![pub package](https://img.shields.io/pub/v/locale_gen.svg)](https://pub.dartlang.org/packages/locale_gen)
[![Build Status](https://travis-ci.org/vanlooverenkoen/locale_gen.svg?branch=master)](https://travis-ci.org/vanlooverenkoen/locale_gen)
[![Coverage Status](https://coveralls.io/repos/github/vanlooverenkoen/locale_gen/badge.svg)](https://coveralls.io/github/vanlooverenkoen/locale_gen)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

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
```yaml
flutter:
  assets:
    - assets/locale/
```

Add the local_gen config to generate your dart code from json files
```yaml
locale_gen:
  default_language: 'nl'
  languages: ['en', 'nl']
  locale_assets_path: 'assets/locale/' #This is the location where your json files should be saved.
  assets_path: 'assets/locale/' #This is the location where your json files are located in your flutter app.
  output_path: 'lib/util/locale/' #This is the location where your localization files will be created in your flutter app.
  doc_languages: ['en'] #Only generate docs for the given languages. Defaults to all languages. An empty list will skip doc generation
```

### Run package with Flutter

```shell
flutter packages pub run locale_gen
```

### Run package with Dart

```shell
pub run locale_gen
```

### Arguments

Arguments are supported as of 0.1.0

You can pass a String or a num to as an argument.

Formatting for String: %1$s
Formatting for num: %1$d

The number in between % and $ indicate the index of the argument. It is possible to place an argument in 1 language first but in another second:

ex (Grammatically incorrect but it makes my point):

```
nl '%1$s, ik woon in %2$s. Wist je dat niet?' => KOEN, ik woon in ANTWERPEN. Wist je dat niet?

fr 'I live in %2$s. You didn't knew that %1$s?" => I live in ANTWERP. You didn't knew that KOEN?
```

*Note:* As of 6.0.0 non-positional arguments are also supported. You **cannot** use both positional and non-positional arguments in the same string.
Example:
```
'%s, ik woon in %s. Wist je dat niet?' => KOEN, ik woon in ANTWERPEN. Wist je dat niet?
```

### Working on mac?

add this to you .bash_profile

```shell
flutterlocalegen(){
 flutter packages get && flutter packages pub run locale_gen
}
```

now you can use the locale_gen with a single command.

```shell
flutterlocalegen
```

## Example
This repo contains an example how to use this package.

Packages used:
 - flutter_localizations
 - shared_preferences
 - provider
 - kiwi

## Other packges based on locale_gen
 - icapps_translations