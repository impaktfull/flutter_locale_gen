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

### Migration steps <7.0.0 to >=7.0.0
With the newest version of locale_gen the context no longer needs to be provided when accessing the translations. This means there are a couple of breaking changes.

The first one is that you can now directly get the translation from the Localization object without having to pass the context, so instead of:

```dart
Localization.of(context).translation;
```

you can now do

```dart
Localization.translation;
```

The second breaking change is how you initialize/change the locale. Before you could do this by changing the localizationDelegate that is passed to the materialApp, but now you just call the load function of the Localization object. So instead of:

```dart
      localeDelegate = LocalizationDelegate(
        newLocale: locale,
        localizationOverrides: customLocalizationOverrides,
      );
```
you now do:

```dart
await Localization.load(
      locale: locale,
      localizationOverrides: customLocalizationOverrides,
    );
```

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

*Note:* As of 6.0.0 non-positional arguments are also supported. You **cannot** use both positional and non-positional arguments in the same string.
Example:
```
'%s, ik woon in %s. Wist je dat niet?' => KOEN, ik woon in ANTWERPEN. Wist je dat niet?
```

### Plurals

Since 8.0.0 plurals are supported. To specify a plural, you can use the following syntax in the json file:

```json
{
  "example_plural": {
    "zero": "You have no items",
    "one": "You have %1$d item",
    "two": "You have 2 items, party!",
    "few": "You have a few items, nice!",
    "many": "You have many items, fantastic!",
    "other": "You have %1$d items"
  }
}
```
This will generate functions where you pass the number of items as an argument. The function will then return the correct translation based on the number of items.
The count argument *WILL NOT* be passed as an argument for string interpolation.

Note that the "other" key is always required, the other keys are dependant on the language in question

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