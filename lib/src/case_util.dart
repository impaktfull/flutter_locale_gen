class CaseUtil {
  static final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');
  static final RegExp _symbolRegex = RegExp(r'[ ./_\-]');

  const CaseUtil._();

  static String getCamelcase(String string) {
    final wordsGroup = _groupIntoWords(string);
    final words = wordsGroup.map(_upperCaseFirstLetter).toList();
    words[0] = words[0].toLowerCase();

    return words.join('');
  }

  static List<String> _groupIntoWords(String text) {
    final sb = StringBuffer();
    final words = <String>[];
    final isAllCaps = !text.contains(RegExp('[a-z]'));

    for (var i = 0; i < text.length; i++) {
      final char = String.fromCharCode(text.codeUnitAt(i));
      final nextChar = text.length == i + 1
          ? null
          : String.fromCharCode(text.codeUnitAt(i + 1));

      if (_symbolRegex.hasMatch(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) ||
          _symbolRegex.hasMatch(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  static String _upperCaseFirstLetter(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}
