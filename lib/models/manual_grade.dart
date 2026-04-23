class ManualGrade {
  final String subjectName;
  final String className;
  final double activity;
  final double midterm;
  final double? chance1;
  final double? chance2;
  final double? chance3;
  final double total;
  final double percentage;
  final String result;
  final String? rank;

  ManualGrade({
    required this.subjectName,
    required this.className,
    required this.activity,
    required this.midterm,
    this.chance1,
    this.chance2,
    this.chance3,
    required this.total,
    required this.percentage,
    required this.result,
    this.rank,
  });

  factory ManualGrade.fromJson(Map<String, dynamic> json) {
    return ManualGrade(
      subjectName: json['subject_name'],
      className: json['class_name'],
      activity: double.parse(json['activity'].toString()),
      midterm: double.parse(json['midterm'].toString()),
      chance1: json['chance_1'] != null ? double.parse(json['chance_1'].toString()) : null,
      chance2: json['chance_2'] != null ? double.parse(json['chance_2'].toString()) : null,
      chance3: json['chance_3'] != null ? double.parse(json['chance_3'].toString()) : null,
      total: double.parse(json['total'].toString()),
      percentage: double.parse(json['percentage'].toString()),
      result: json['result'],
      rank: json['rank']?.toString(),
    );
  }
}