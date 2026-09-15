import 'dart:async';

import 'package:locale_gen/src/model/locale_gen_params.dart';
import 'package:locale_gen/src/writer/core_generator.dart';
import 'package:test/test.dart';

/// Records which builder [LocaleGenCoreGenerator.buildTranslationFunction]
/// picks, so these tests cover the routing without any generated Dart code.
class _RecordingGenerator extends LocaleGenCoreGenerator {
  final calls = <String>[];

  @override
  void buildDefaultFunction(sb, params, key, allTranslations) =>
      calls.add('default $key');

  @override
  void buildDefaultPluralFunction(sb, params, key, plural, allTranslations) =>
      calls.add('plural $key');

  @override
  void buildParameterizedPluralFunction(
          sb, params, key, plural, arguments, allTranslations) =>
      calls.add('plural $key $arguments');

  @override
  void buildParameterizedFunction(
          sb, params, key, arguments, allTranslations) =>
      calls.add('sprintf $key $arguments');

  @override
  void buildMessageFormatFunction(
          sb, params, key, ast, mfParams, allTranslations) =>
      calls.add('messageFormat $key ${mfParams.keys.toList()}');

  /// [getArgument] is protected: only subclasses may call it.
  String argument(String type, int index) => getArgument(type, index);
}

/// What [LocaleGenCoreGenerator.buildTranslationFunction] did for [value]:
/// the builder it called and everything it printed.
({List<String> calls, List<String> printed}) _route(
  dynamic value, {
  bool strict = false,
}) {
  final params = LocaleGenParams.fromYamlString('locale_gen', '''
name: my_app
locale_gen:
  languages: ['en']
  message_format_strict: $strict
''');
  final generator = _RecordingGenerator();
  final printed = <String>[];
  runZoned(
    () => generator
        .buildTranslationFunction(StringBuffer(), params, 'key', value, {}),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => printed.add(line),
    ),
  );
  return (calls: generator.calls, printed: printed);
}

void main() {
  group('buildTranslationFunction', () {
    group('plain values', () {
      test('null builds a default getter', () {
        expect(_route(null).calls, ['default key']);
      });

      test('an empty string builds a default getter', () {
        expect(_route('').calls, ['default key']);
      });

      test('text without markers builds a default getter', () {
        expect(_route('Settings').calls, ['default key']);
      });
    });

    group('sprintf', () {
      test('positional markers become ordered arguments', () {
        expect(_route(r'Hi %2$d, %1$s').calls, ['sprintf key {1: s, 2: d}']);
      });

      test('non-positional markers are numbered in order', () {
        expect(_route('%s paid %.2f').calls, ['sprintf key {1: s, 2: f}']);
      });

      test('a repeated positional marker is one argument', () {
        expect(_route(r'%1$s and %1$s').calls, ['sprintf key {1: s}']);
      });

      test('one index with two types falls back to a default getter', () {
        final result = _route(r'%1$s and %1$d');
        expect(result.calls, ['default key']);
        expect(result.printed, [
          'Exception: key contains a value with more than 1 argument with the same index but different type',
        ]);
      });

      test('mixing positional and non-positional falls back', () {
        final result = _route(r'%1$s and %s');
        expect(result.calls, ['default key']);
        expect(result.printed, [
          'Exception: The translation for key "key" contains both positional and normal format parameters',
        ]);
      });
    });

    group('MessageFormat', () {
      test('builds a MessageFormat function with its parameters', () {
        expect(_route('{count, plural, other {# for {name}}}').calls,
            ['messageFormat key [count, name]']);
      });

      test('a value that does not parse falls back with a warning', () {
        final result = _route('Hi {name');
        expect(result.calls, ['default key']);
        expect(result.printed, [
          '[locale_gen] Warning: key "key" failed to parse as MessageFormat: Unclosed placeholder for "name". Falling back to default getter.',
        ]);
      });

      test('a parameter with two types falls back with a warning', () {
        final result = _route('{n, plural, other {#}} {n}');
        expect(result.calls, ['default key']);
        expect(result.printed, [
          '[locale_gen] Warning: key "key" — Param "n" used with incompatible types (num_ vs string). Falling back to default getter.',
        ]);
      });

      test('sprintf and MessageFormat markers together fall back', () {
        final result = _route(r'Hi {name}, %1$s');
        expect(result.calls, ['default key']);
        expect(result.printed, [
          '[locale_gen] Warning: key "key" contains both sprintf and MessageFormat markers; falling back to default getter.',
        ]);
      });
    });

    group('message_format_strict', () {
      test('turns a sprintf value into a default getter with a warning', () {
        final result = _route(r'Hi %1$s', strict: true);
        expect(result.calls, ['default key']);
        expect(result.printed, [
          '[locale_gen] Warning: key "key" uses sprintf markers but messageFormatStrict is enabled; falling back to default getter.',
        ]);
      });

      test('leaves MessageFormat and plain values alone', () {
        expect(_route('Hi, {name}!', strict: true).calls,
            ['messageFormat key [name]']);
        expect(_route('Settings', strict: true).printed, isEmpty);
      });
    });

    group('JSON-object plurals', () {
      test('without markers builds a plural function', () {
        expect(
            _route({'one': 'An hour', 'other': 'Hours'}).calls, ['plural key']);
      });

      test('collects the arguments of every branch', () {
        final result = _route({
          'zero': 'None',
          'one': r'%1$d item',
          'two': r'%1$d items',
          'few': r'%1$d items',
          'many': r'%1$d items for %2$s',
          'other': r'%1$d items',
        });
        expect(result.calls, ['plural key {1: d, 2: s}']);
      });

      test('without "other" falls back with the reason', () {
        final result = _route({'one': 'An hour'});
        expect(result.calls, ['default key']);
        expect(result.printed,
            ['Exception: Other is required for plurals. Key: key']);
      });
    });
  });

  group('getArgument', () {
    test('maps each sprintf type to a Dart parameter', () {
      final generator = _RecordingGenerator();
      expect(generator.argument('s', 1), 'String arg1');
      expect(generator.argument('d', 2), 'int arg2');
      expect(generator.argument('f', 3), 'double arg3');
    });
  });
}
