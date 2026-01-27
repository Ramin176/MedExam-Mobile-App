// lib/screens/subject_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/models/topic.dart';
import 'package:med_exam_app/screens/quiz/quiz_start_screen.dart';
import 'package:med_exam_app/utils/app_theme.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // کارت عنوان مضمون
            Card(
              color: AppColors.primaryDark,
              child: ListTile(
                leading: const Icon(FontAwesomeIcons.tag, color: AppColors.textLight, size: 20),
                title: Text(
                  'تعداد کل عناوین: ${subject.topics.length}',
                  style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // عنوان لیست
            const Padding(
              padding: EdgeInsets.only(right: 5, bottom: 10),
              child: Text(
                'فصول و عناوین درس:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                textAlign: TextAlign.right,
              ),
            ),

            // لیست عناوین (Topics)
            ListView.builder(
              shrinkWrap: true, // مهم: برای قرار گرفتن داخل SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // مهم: چون اسکرول اصلی توسط SingleChildScrollView انجام می‌شود
              itemCount: subject.topics.length,
              itemBuilder: (context, index) {
                final topic = subject.topics[index];
                return _buildTopicCard(context, topic, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ساختار کارت هر عنوان (Topic Card)
  Widget _buildTopicCard(BuildContext context, Topic topic, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell( // برای افکت کلیک زیبا
        onTap: () {
          // هدایت به صفحه شروع آزمون/تمرین
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizStartScreen(topic: topic),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // آیکون برای ورود به آزمون
              const Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryDark),
              
              // عنوان و شماره فصل
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'فصل $index: ${topic.title}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'آماده برای آزمون یا تمرین',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
              
              // شماره فصل
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  '$index',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}