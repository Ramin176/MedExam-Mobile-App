// lib/models/student_class.dart (شامل Subject)

import 'package:hive/hive.dart';
import 'topic.dart';

part 'student_class.g.dart';

@HiveType(typeId: 3) 
class Subject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<Topic> topics; 

  Subject({required this.id, required this.name, required this.topics});

  factory Subject.fromJson(Map<String, dynamic> json) {
    var topicsList = json['topics'] as List? ?? [];
    List<Topic> topics = topicsList.map((i) => Topic.fromJson(i)).toList();

    return Subject(id: json['id'], name: json['name'], topics: topics);
  }
}

@HiveType(typeId: 4) 
class StudentClass {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String price;
  @HiveField(3)
  final DateTime startDate;
  @HiveField(4)
  final DateTime endDate;
  @HiveField(5)
  final List<Subject> subjects; 

  StudentClass({
    required this.id,
    required this.name,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.subjects,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? []; 
    List<Subject> subjects = subjectsList.map((i) => Subject.fromJson(i)).toList();

    return StudentClass(
      id: json['id'],
      name: json['name'],
      price: json['price'].toString(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      subjects: subjects,
    );
  }
}