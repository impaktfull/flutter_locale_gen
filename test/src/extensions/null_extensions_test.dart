import 'package:locale_gen/src/extensions/null_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('let', () {
    test('Check if let can be completed because of call on not null', () {
      const String? item = 'not-null';
      var letCompleted = false;
      item.let((value) {
        letCompleted = true;
      });
      expect(letCompleted, true);
    });
    test('Check if let is not completed because of call on null', () {
      const String? item = null;
      var letCompleted = false;
      item.let((value) {
        letCompleted = true;
      });
      expect(letCompleted, false);
    });
  });
}
