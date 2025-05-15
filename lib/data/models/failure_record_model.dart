import '../../domain/entities/failure_record.dart';

class FailureRecordModel extends FailureRecord {
  const FailureRecordModel({
    required int id,
    required String comment,
    required String depName,
    required DateTime dtFinish,
    required DateTime dtStart,
    required String failName,
    required String lineName,
    required int line,
    required double minutes,
  }) : super(
          id: id,
          comment: comment,
          depName: depName,
          dtFinish: dtFinish,
          dtStart: dtStart,
          failName: failName,
          line: line,
          minutes: minutes,
          lineName: lineName,
        );

  factory FailureRecordModel.fromJson(Map<String, dynamic> json) {
    return FailureRecordModel(
      id: json['id'] as int,
      comment: json['coment'] as String,
      depName: json['dep_name'] == 'None'
          ? 'Не заповнено'
          : json['dep_name'] as String,
      dtFinish:
          DateTime.fromMillisecondsSinceEpoch((json['dtFinish'] as int) * 1000),
      dtStart:
          DateTime.fromMillisecondsSinceEpoch((json['dtStart'] as int) * 1000),
      failName: json['fail_name'] as String,
      line: json['line'] as int,
      lineName: (json['line_name'] ?? json['line'].toString()) as String,
      minutes: json['minutes'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coment': comment,
      'dep_name': depName,
      'dtFinish': dtFinish.toIso8601String(),
      'dtStart': dtStart.toIso8601String(),
      'fail_name': failName,
      'line': line,
      'line_name': lineName,
      'minutes': minutes,
    };
  }
}
