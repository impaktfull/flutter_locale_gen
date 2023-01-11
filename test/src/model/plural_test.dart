import 'package:locale_gen/src/model/plural.dart';
import 'package:test/test.dart';

void main() {
  test('Parse plural ', () {
    final json = {
      'one': 'one',
      'two': 'two',
      'few': 'few',
      'many': 'many',
      'other': 'other',
    };
    final plural = Plural.fromJson(json);
    expect(plural.one, 'one');
    expect(plural.two, 'two');
    expect(plural.few, 'few');
    expect(plural.many, 'many');
    expect(plural.other, 'other');
  });
}
