import 'topic.dart';
import 'lecture.dart';
import 'package:hive/hive.dart';

part 'student_class.g.dart';

@HiveType(typeId: 3)
class Subject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Topic> topics;
  @HiveField(3)
  final List<Lecture> lectures; 

  Subject({required this.id, required this.name, required this.topics, required this.lectures});

  factory Subject.fromJson(Map<String, dynamic> json) {
    var topicsList = json['topics'] as List? ?? [];
    var lecturesList = json['lectures'] as List? ?? []; // ایمن سازی در برابر نال
    
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'بدون نام',
      topics: topicsList.map((i) => Topic.fromJson(i)).toList(),
      lectures: lecturesList.map((i) => Lecture.fromJson(i)).toList(),
    );
  }
}

@HiveType(typeId: 4)
class StudentClass {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String semesterPrice; 
  @HiveField(3)
  final String monthlyPrice;  
  @HiveField(4)
  final DateTime endDate;
  @HiveField(5)
  final List<Subject> subjects;

  StudentClass({
    required this.id, required this.name, required this.semesterPrice,
    required this.monthlyPrice, required this.endDate, required this.subjects,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? [];
    return StudentClass(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'صنف نامشخص',
      semesterPrice: (json['price'] ?? '0').toString(), 
      monthlyPrice: (json['monthly_price'] ?? '0').toString(), 
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().toString()),
      subjects: subjectsList.map((i) => Subject.fromJson(i)).toList(),
    );
  }
}