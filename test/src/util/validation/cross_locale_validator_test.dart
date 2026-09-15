import 'dart:async';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/util/validation/cross_locale_validator.dart';
import 'package:test/test.dart';

void main() {
  group('CrossLocaleValidator', () {
    test('returns no warnings when locales agree', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'nl': 'Hallo, {name}!'},
      );
      expect(warnings, isEmpty);
    });

    test('warns when a locale uses a different placeholder name', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'nl': 'Hallo, {naam}!'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('greeting'));
      expect(warnings.first, contains('nl'));
      expect(warnings.first, contains('naam'));
    });

    test('warns when a locale is missing a placeholder', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'fr': 'Bonjour!'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('name'));
    });

    test('warns when a locale uses a different ICU node type for the same name',
        () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'cart_count',
        defaultLanguage: 'en',
        defaultValue: '{count, plural, one {# item} other {# items}}',
        otherLocales: const {'fr': 'Total: {count}'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('plural'));
    });

    test('warns once per failing locale, returns rest of validation', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {
          'nl': 'Hallo, {naam}!',
          'fr': 'Bonjour, {nom}!',
        },
      );
      expect(warnings, hasLength(2));
    });

    test('warns when a non-default locale fails to parse', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi, {name}!',
        otherLocales: const {'broken': 'Hi {name'},
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('broken'));
      expect(warnings.first, contains('parse'));
    });

    test('ignores style differences in number/date/time/duration', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'paid_at',
        defaultLanguage: 'en',
        defaultValue: 'Paid at {t, date, short}',
        otherLocales: const {'nl': 'Betaald op {t, date, long}'},
      );
      expect(warnings, isEmpty);
    });

    test('returns no warnings when the default value does not parse', () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'greeting',
        defaultLanguage: 'en',
        defaultValue: 'Hi {name',
        otherLocales: const {'nl': 'Hallo, {naam}!'},
      );
      expect(warnings, isEmpty);
    });

    test('compares placeholders nested in select and selectordinal branches',
        () {
      final warnings = CrossLocaleValidator.validateKey(
        key: 'rank',
        defaultLanguage: 'en',
        defaultValue:
            '{g, select, other {{p, selectordinal, other {# for {name}}}}}',
        otherLocales: const {
          'nl':
              '{g, select, other {{p, selectordinal, other {# voor {naam}}}}}',
        },
      );
      expect(warnings, hasLength(1));
      expect(warnings.first, contains('uses params [g, naam, p]'));
      expect(warnings.first, contains('uses [g, name, p]'));
    });
  });

  group('CrossLocaleValidator.validateAndPrint', () {
    test('prints the warnings of MessageFormat keys only', () {
      final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en', 'nl']
''');
      final printed = <String>[];

      runZoned(
        () => CrossLocaleValidator.validateAndPrint(
          params: params,
          defaultTranslations: {
            'greeting': 'Hi, {name}!',
            'farewell': 'Bye, {name}!',
            'title': 'Title',
            'hours': {'other': '%d hours'},
          },
          allTranslations: {
            'en': {},
            'nl': {
              'greeting': 'Hallo, {naam}!',
              'farewell': {'other': 'Doei'},
              'title': 'Titel',
            },
          },
        ),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => printed.add(line),
        ),
      );

      expect(printed, [
        '[locale_gen] Warning: key "greeting" — locale "nl" uses params [naam]; '
            'default language "en" uses [name]. '
            'The translated string must use the same placeholder names as the default language.',
      ]);
    });
  });
}
