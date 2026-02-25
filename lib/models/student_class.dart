// lib/models/student_class.dart

import 'topic.dart';
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

  Subject({required this.id, required this.name, required this.topics});

  factory Subject.fromJson(Map<String, dynamic> json) {
    var topicsList = json['topics'] as List? ?? [];
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'بدون نام',
      topics: topicsList.map((i) => Topic.fromJson(i)).toList(),
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
  final String semesterPrice; // قیمت سمستروار (معادل فیلد price در لاراول)
  
  @HiveField(3)
  final String monthlyPrice;  // قیمت ماهوار (فیلد جدید)
  
  @HiveField(4)
  final DateTime startDate;
  
  @HiveField(5)
  final DateTime endDate;
  
  @HiveField(6)
  final List<Subject> subjects;

  StudentClass({
    required this.id,
    required this.name,
    required this.semesterPrice,
    required this.monthlyPrice,
    required this.startDate,
    required this.endDate,
    required this.subjects,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    var subjectsList = json['subjects'] as List? ?? [];
    
    return StudentClass(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'صنف نامشخص',
      // مپ کردن فیلد price از سمت لاراول به semesterPrice در موبایل
      semesterPrice: (json['price'] ?? '0').toString(), 
      // مپ کردن فیلد monthly_price از سمت لاراول به monthlyPrice در موبایل
      monthlyPrice: (json['monthly_price'] ?? '0').toString(), 
      startDate: DateTime.parse(json['start_date'] ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['end_date'] ?? DateTime.now().add(const Duration(days: 365)).toString()),
      subjects: subjectsList.map((i) => Subject.fromJson(i)).toList(),
    );
  }
}