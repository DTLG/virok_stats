class FailureRecord {
  final int id;
  final String comment;
  final String depName;
  final DateTime dtFinish;
  final DateTime dtStart;
  final String failName;
  final int line;
  final double minutes;
  final String lineName;
  const FailureRecord({
    required this.id,
    required this.comment,
    required this.depName,
    required this.dtFinish,
    required this.dtStart,
    required this.failName,
    required this.line,
    required this.minutes,
    required this.lineName,
  });
}
