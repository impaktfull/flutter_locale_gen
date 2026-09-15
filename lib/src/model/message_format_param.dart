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

  const MessageFormatParam({
    required this.originalName,
    required this.dartName,
    required this.dartType,
    required this.formatter,
    this.formatterStyle,
  });
}

class MessageFormatParamConflictException implements Exception {
  final String message;
  const MessageFormatParamConflictException(this.message);
  @override
  String toString() => 'MessageFormatParamConflictException: $message';
}
