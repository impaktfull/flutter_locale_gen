import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:locale_gen_example/app.dart';

/// Walks the example app through every locale so
/// `tool/docs_media/record_flutter_example.dart` can record it for the README.
///
/// The START/END markers tell the recording script when to capture.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('docs media walkthrough', (tester) async {
    await tester.pumpWidget(const MyApp(showDebugFlag: false));
    // The example fetches its overrides with a simulated 5 second network
    // call. Wait for it, so the recording does not change halfway through.
    await _hold(tester, const Duration(seconds: 7));
    await tester.tap(find.byKey(const ValueKey('locale_en')));
    await _hold(tester, const Duration(seconds: 1));

    // ignore: avoid_print
    print('DOCS_MEDIA_START');
    await _hold(tester, const Duration(seconds: 3));
    for (final id in ['nl', 'fi-FI', 'zh-Hans-CN', 'keys', 'en']) {
      await tester.tap(find.byKey(ValueKey('locale_$id')));
      await _hold(tester, const Duration(seconds: 3));
    }
    // ignore: avoid_print
    print('DOCS_MEDIA_END');
  });
}

/// Keeps rendering frames for [duration] of real time.
Future<void> _hold(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await tester.pump();
  }
}
