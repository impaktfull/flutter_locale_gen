enum MessageFormatParamType { string, num_, dateTime, duration }

enum MessageFormatFormatter {
  none,
  numberDecimal,
  numberPercent,
  numberCurrency,
  numberCustom,
  dateShort,
  dateMedium,
  dateLong,
  dateFull,
  dateCustom,
  timeShort,
  timeMedium,
  timeLong,
  timeFull,
  timeCustom,
  durationDefault,
  durationShort,
  durationMedium,
  durationLong,
  durationCustom,
}

class MessageFormatParam {
  final String originalName;
  final String dartName;
  final MessageFormatParamType dartType;
  final MessageFormatFormatter formatter;
  final String? formatterStyle;

  /// The other formats this param is used in within the same message, such as
  /// the `time` in `{d, date, medium} at {d, time, short}`. [formatter] and
  /// [formatterStyle] describe the first one.
  final List<MessageFormatParam> otherFormats;

  const MessageFormatParam({
    required this.originalName,
    required this.dartName,
    required this.dartType,
    required this.formatter,
    this.formatterStyle,
    this.otherFormats = const [],
  });

  /// The key this format is passed under in the args of a message. The
  /// generated `_resolveFormatSpecs` builds the same key from
  /// `{name, type, style}` at runtime.
  String get formatKey =>
      '$originalName|${_icuType(formatter)}|${formatterStyle ?? ''}';

  static String _icuType(MessageFormatFormatter formatter) =>
      switch (formatter) {
        MessageFormatFormatter.none => '',
        MessageFormatFormatter.numberDecimal ||
        MessageFormatFormatter.numberPercent ||
        MessageFormatFormatter.numberCurrency ||
        MessageFormatFormatter.numberCustom =>
          'number',
        MessageFormatFormatter.dateShort ||
        MessageFormatFormatter.dateMedium ||
        MessageFormatFormatter.dateLong ||
        MessageFormatFormatter.dateFull ||
        MessageFormatFormatter.dateCustom =>
          'date',
        MessageFormatFormatter.timeShort ||
        MessageFormatFormatter.timeMedium ||
        MessageFormatFormatter.timeLong ||
        MessageFormatFormatter.timeFull ||
        MessageFormatFormatter.timeCustom =>
          'time',
        MessageFormatFormatter.durationDefault ||
        MessageFormatFormatter.durationShort ||
        MessageFormatFormatter.durationMedium ||
        MessageFormatFormatter.durationLong ||
        MessageFormatFormatter.durationCustom =>
          'duration',
      };
}

class MessageFormatParamConflictException implements Exception {
  final String message;
  const MessageFormatParamConflictException(this.message);
  @override
  String toString() => 'MessageFormatParamConflictException: $message';
}
