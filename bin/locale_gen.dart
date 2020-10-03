import 'dart:async';
import 'package:locale_gen/locale_gen.dart';

Future<void> main(List<String> args) async {
  final params = LocaleGenParams('locale_gen');
  LocaleGenWriter.write(params);
}
