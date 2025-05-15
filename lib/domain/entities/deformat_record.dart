class DeformatRecord {
  final DateTime date;
  final double defMass;
  final int iceLine;
  final double iceMass;
  final String iceName;
  final String lineName;
  final double defPercent;

  DeformatRecord({
    required this.date,
    required this.defMass,
    required this.iceLine,
    required this.iceMass,
    required this.iceName,
    required this.lineName,
    required this.defPercent,
  });

  factory DeformatRecord.fromJson(Map<String, dynamic> json, DateTime date) {
    return DeformatRecord(
      date: date,
      defMass: json['def_mass'].toDouble(),
      defPercent: json['def_percent'].toDouble(),
      iceLine: json['ice_line'],
      iceMass: json['ice_mass'].toDouble(),
      iceName: json['ice_name'],
      lineName: json['line_name'],
    );
  }
}
