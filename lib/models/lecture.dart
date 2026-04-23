import 'package:hive/hive.dart';

part 'lecture.g.dart';

@HiveType(typeId: 5)
class Lecture extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final String filePath;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final bool isFree;
  @HiveField(6)
  String? localPath; // آدرس فایل ذخیره شده در گوشی

  Lecture({
    required this.id, required this.title, required this.type,
    required this.filePath, this.description, required this.isFree,
    this.localPath,
  });

  String get fullFileUrl => "https://medexam.saberyinstitute.com/storage/$filePath";

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      filePath: json['file_path'],
      description: json['description'],
      isFree: json['is_free'] == 1 || json['is_free'] == true,
    );
  }
}