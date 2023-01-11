import 'package:locale_gen/src/extensions/list_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('moveToFirstIndex', () {
    test('Test if move to first index is correct when not yet firsst', () {
      final list = ['Test', 'blabla', 'what'];
      final newList = list.moveToFirstIndex('what');
      expect(newList[0], 'what');
      expect(newList[1], 'blabla');
      expect(newList[2], 'Test');
    });
    test('Test if move to first index is correct when already first', () {
      final list = ['Test', 'blabla', 'what'];
      final newList = list.moveToFirstIndex('Test');
      expect(newList[0], 'Test');
      expect(newList[1], 'blabla');
      expect(newList[2], 'what');
    });
  });
  group('sortedBy', () {
    test('sortBy alphabetic', () {
      final list = ['Test', 'blabla', 'what', 'BLABLA'];
      final newList = list.sortedBy((item) => item);
      expect(newList[0], 'BLABLA');
      expect(newList[1], 'Test');
      expect(newList[2], 'blabla');
      expect(newList[3], 'what');
    });
  });
}
