import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:locale_gen_example_dart/util/locale/localization.dart';

Future<void> main() async {
  Intl.defaultLocale = 'en';
  await initializeDateFormatting();
  final localization = Localization.instance;

  // List of translations to demonstrate (with demo arguments for parameterized examples)
  final translations = <String, LocalizedValue>{
    'test': localization.test,
    'testArg1': localization.testArg1('Arg1'),
    'testArg2': localization.testArg2(42),
    'testArg3': localization.testArg3('Arg1', 17),
    'testArg4': localization.testArg4('Arg1', 3.14),
    'testNewLine': localization.testNewLine('Arg1', 87),
    'testNewLineCarriageReturn': localization.testNewLineCarriageReturn,
    'testNonPositional': localization.testNonPositional('Hello', 99.9),
    'welcomeMessage': localization.welcomeMessage,
    'mfGreeting': localization.mfGreeting(name: 'John'),
    'mfCartCount': localization.mfCartCount(count: 3),
    'mfPronoun': localization.mfPronoun(gender: 'female'),
    'mfRank': localization.mfRank(place: 2),
    'mfTotal': localization.mfTotal(total: 1234.56),
    'mfPlacedAt': localization.mfPlacedAt(placedAt: DateTime(2024, 3, 11, 13, 37)),
    'mfMeetingAt': localization.mfMeetingAt(at: DateTime(2024, 3, 11, 15, 0)),
    'mfRace': localization.mfRace(d: const Duration(minutes: 2, seconds: 15)),
  };

  for (final entry in translations.entries) {
    print('==== ${entry.key} ====');
    print('en:       ${entry.value.en}');
    print('nl:       ${entry.value.nl}');
    print('zhHansCN: ${entry.value.zhHansCN}');
    print('fiFI:     ${entry.value.fiFI}');
    print('');
  }
}
