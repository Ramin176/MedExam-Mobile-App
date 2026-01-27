// lib/models/result.dart

import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/models/student_class.dart'; 

class Result {
  final int id;
  final int totalQuestions;
  final int correctAnswers;
  final double scoreOutOf20;
  final DateTime createdAt;
  final Topic topic; 
  final Subject subject;

  Result({
    required this.id,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scoreOutOf20,
    required this.createdAt,
    required this.topic,
    required this.subject,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    // مدل داده نمرات در API به صورت 'topic' و داخل آن 'subject' را می‌گیرد
    final topicJson = json['topic'];
    final subjectJson = topicJson['subject']; 

    return Result(
      id: json['id'],
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'],
     scoreOutOf20: json['score_out_of_20'] is String 
    ? double.tryParse(json['score_out_of_20']) ?? 0.0 // اگر رشته بود، به double تبدیل کن
    : json['score_out_of_20'] is int 
        ? (json['score_out_of_20'] as int).toDouble() // اگر عدد صحیح بود، به double تبدیل کن
        : json['score_out_of_20'] ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      topic: Topic.fromJson(topicJson),
      subject: Subject.fromJson(subjectJson),
    );
  }
}