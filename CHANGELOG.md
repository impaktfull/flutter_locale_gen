# 12.2.0

## Updated

- Bumped `intl` dependency to ^0.20.0

# 12.1.4

## Updated

- Updated license to 2025

# 12.1.3

## Updated

- Updated intl to support Flutter 3.22.x and above

# 12.1.1 - 12.1.2

## Fixed

- Documentation old references are removed

# 12.1.0

## Feat

- Formatting function added. (`dart run locale_gen:format`)

## Updated

- License to BSD-3-Clause license

## [12.0.0] - 2023-06-05
Updated to intl 0.18.x

## [11.0.0] - 2023-01-11
### BREAKING CHANGE!!
- After some time of using the new locale_gen package. It made our lifes harder than before.
  For now we reverted the
    - `.of(context)` removal
    - `singelton` implementation
  Other changes like `sprintf`, `plurals` and dependency updates are still in place.

## [10.0.0] - 2022-11-14
- Updated the signature of `load` to support getting the bundle to load from. Falls back to `rootBubdle`

## [9.0.1] - 2022-10-06
### Updated
- Updated travis to linux from macOS

## [9.0.0] - 2022-10-03
### Breaking
- Translations can no longer be accessed from static methods on the Localization class. Instead you now need to manually manage the different localization instances. Migration steps are described in the readme.

## [8.0.0] - 2022-09-24
### Breaking
- Arguments are now formatted using the [sprintf](https://pub.dev/packages/sprintf) package. This means %d now refers to integers only. Use %f to format doubles, you can also use some format specifiers, eg: (%.2f will show 2 decimals)
- This means that the sprintf package must be added to the pubspec.yaml (at least ^6.0.2)

### Added
- Support for plurals had been added, see the readme on how to use them

### Updated
- Dependencies

## [7.0.0] - 2022-09-23
### Breaking
- Removed the need of passing a context to get translations. Migration steps are described in the readme.

## [6.0.0] - 2022-09-20
### Added
- Added support for non-positional arguments. You **cannot** use both positional and non-positional arguments in the same string.

## [5.0.0] - 2022-08-23
### Fixed
- Sorting of the default language in the supported languages

## [4.1.2] - 2022-01-01
### Fixed
- changed language code to `toLanguageTag()`

## [4.1.1] - 2021-12-16
### Fixed
- Output path should also be used for the correct imports
### Added
- Extra error handling for the output_path. (output_path should always start with `lib/`)
- Extra unit tests & refactored some code to have smaller tests

## [4.1.0] - 2021-12-16
### Added
- Support for using an other directory instead of `lib/util/locale` for write all the files

## [4.0.0] - 2021-11-12
Breaking
- Dart 2.14.0 is minimum dart version
- Fixed an issue where `kDebugMode` moved to another import

## [3.7.0] - 2021-11-02
- Added better import sorting (alphabetic) so the analyzer won't break everytime

## [3.6.1] - 2021-10-12
- Issue where an exception was thrown even when it was not needed.

## [3.6.0] - 2021-10-12
### Fixed
- #53: Issue where a carriage return `\r` would generate invalid documentation
- #52: Unnecessary string interpolation for '$key' in `localization.dart`
### Added
- #39: Better generated documentation for arguments
- #56: Option to override the localizations. Pass a `LocalizationOverrides` to the `LocalizationDelegate`.
  Refreshing & managing the cached localizations should be done by the developer.

## [3.5.0] - 2021-10-06
### Added
- locale that was used to initialize your Localization is now also included in `localization.dart`

## [3.4.1] - 2021-05-07
### Fixed
- the default language generation
- the supported language list generation

## [3.4.0] - 2021-05-06
### Added
- #45 support for country codes & languages

## [3.3.0] - 2021-04-07
### Added
- #48 useCaching configuration for fetching the json translation files

### Fixed
- #46 default path variables (asset dir, local asset dir, output dir)

## [3.2.1] - 2021-03-30
### Fixed
- #43 Newline documentation issue

## [3.2.0] - 2021-03-30
### Added
- #42 Migrated strict mode code
- #42 Generate strict mode code
- #36 Added support generating documentation so you can see translations in your IDE
- #37 Added config option to configure which languages should be used for generating documentation code

## [3.1.0] - 2021-03-25
### Added
- #34 Support for skipping a locale at runtime. example: only use dutch in alpha but not in beta & production

## [3.0.0] - 2021-03-07
### Added
- #32 Nullsafety implementation. Support for flutter 2.0 & dart 2.12.0
### Removed
- #32 nullsafe flag is removed because from this version we are targeting 2.12 which will use nullsafety by default

## [2.1.0] - 2021-02-09
###
- Added option to generate null safety compatible code 

## [2.0.5] - 2020-10-06
### Fixed
- #24: error when using locale_asset_path in combination with the icapps_translations package

## [2.0.4] - 2020-10-03
### Fixed
- Version bump packages

## [2.0.3] - 2020-10-03
### Added to repo
- Added travis ci integration

## [2.0.2] - 2020-10-03
### Fixed
- Android embedding v2

## [2.0.1] - 2020-10-03
### Updated
- Documentation updated 

## [2.0.0] - 2020-10-03
### Refactor
- Added support for the usage of this package in other once. Mainly because of icapps_translations
### Added
- Strict mode
- Support for a multi module architecture 

## [1.0.0] - 2020-03-28
### Added
- Localization keys support (better support for testing)
### Breaking
- isInTest => showLocalizationKeys
  Behaviour is still the same.
 
## [0.2.0] - 2019-10-13
### Added
- Test support
### Fixed
- Removed the unneeded log

## [0.1.1] - 2019-08-19
### Fixed
- Fixed documentation about arguments

## [0.1.0] - 2019-06-22
### Added
- Support for arguments

### Fixed
- Dart formatting

## [0.0.2] - 2019-06-12
### Added
- Updated README.md

## [0.0.1] - 2019-06-12
### Added
- Initial release
