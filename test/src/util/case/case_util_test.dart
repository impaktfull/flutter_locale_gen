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

    test('other separators and all-caps keys to camelCase', () {
      expect(CaseUtil.getCamelcase('settings.title'), 'settingsTitle');
      expect(CaseUtil.getCamelcase('profile/edit button'), 'profileEditButton');
      expect(CaseUtil.getCamelcase('welcomeBack'), 'welcomeBack');
      expect(CaseUtil.getCamelcase('API_KEY'), 'apiKey');
    });

    test('anything to snake_case', () {
      expect(CaseUtil.getSnakeCase('welcomeBack'), 'welcome_back');
      expect(CaseUtil.getSnakeCase('WelcomeBack'), 'welcome_back');
      expect(CaseUtil.getSnakeCase('welcome back'), 'welcome_back');
      expect(CaseUtil.getSnakeCase('welcome-back'), 'welcome_back');
      expect(CaseUtil.getSnakeCase('welcome_back'), 'welcome_back');
      expect(CaseUtil.getSnakeCase('API_KEY'), 'api_key');
    });
  });
}
