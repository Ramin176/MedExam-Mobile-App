// lib/models/question.dart
import 'package:hive/hive.dart';

part 'question.g.dart'; 

@HiveType(typeId: 0) 
class Question {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String questionText;
  @HiveField(2)
  final String? image; 
  @HiveField(3)
  final String optionA;
  @HiveField(4)
  final String optionB;
  @HiveField(5)
  final String optionC;
  @HiveField(6)
  final String optionD;
  @HiveField(7)
  final String correctAnswer; 
  @HiveField(8)
  final String type; 
  @HiveField(9)
  final String? explanation; // فیلد جدید اضافه شد

  Question({
    required this.id,
    required this.questionText,
    this.image,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.type,
     this.explanation,
  });

  // متد جادویی برای نمایش عکس از هاستینگر
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;
    // لینک هاست شما + مسیر استوریج
    return "https://medexam.saberyinstitute.com/storage/$image";
    //  return "http://127.0.0.1:8000/storage/$image"; // آدرس سرور شما
  }
  
 
  factory Question.fromJson(Map<String, dynamic> json) {
    // تابعی برای پاک کردن تگ‌های HTML
    String stripHtml(String htmlString) {
      RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      return htmlString.replaceAll(exp, '').trim();
    }

    return Question(
      id: json['id'],
      questionText: json['question_text'],
      image: json['image'],
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
      type: json['type'] ?? 'mcq',
      // اگر توضیحات تگ HTML داشت، آن را پاک کن
      explanation: json['explanation'] != null ? stripHtml(json['explanation']) : null,
    );
  }
}