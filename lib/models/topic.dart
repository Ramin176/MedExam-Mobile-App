// lib/models/topic.dart

import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 2) 
class Topic {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? examPassword; 

  Topic({required this.id, required this.title, this.examPassword});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      title: json['title'],
      examPassword: json['exam_password'],
    );
  }
}