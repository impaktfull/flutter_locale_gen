import 'package:locale_gen/src/util/case/case_util.dart';
import 'package:test/test.dart';

void main() {
  group('Case Util', () {
    test('snakecase to camelCase', () {
      expect(CaseUtil.getCamelcase('test_test'), 'testTest');
      expect(CaseUtil.getCamelcase('test_Test'), 'testTest');
      expect(CaseUtil.getCamelcase('Test_Test'), 'testTest');
      expect(CaseUtil.getCamelcase('Test_test'), 'testTest');
      expect(CaseUtil.getCamelcase('test-test'), 'testTest');
      expect(CaseUtil.getCamelcase('test-Test'), 'testTest');
      expect(CaseUtil.getCamelcase('Test-test'), 'testTest');
      expect(CaseUtil.getCamelcase('Test-Test'), 'testTest');
    });
  });
}
