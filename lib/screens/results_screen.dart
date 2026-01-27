// lib/screens/results_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/result.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:intl/intl.dart'; // برای فرمت تاریخ (باید در pubspec اضافه شود)

// --- تنظیمات API ---
const String API_URL = "http://192.168.86.30:8000/api";

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<List<Result>>? _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _fetchMyResults();
  }

  // متد دریافت نمرات از API
  Future<List<Result>> _fetchMyResults() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null) return Future.error('کاربر لاگین نیست');
    
    try {
      final response = await Dio().get(
        '$API_URL/my-results',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => Result.fromJson(json)).toList();

    } on DioException catch (e) {
      print("Error fetching results: $e");
      return Future.error('خطا در دریافت نتایج: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارنامه و نتایج آزمون‌ها'),
      ),
      body: FutureBuilder<List<Result>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطا: ${snapshot.error}', textAlign: TextAlign.center));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('تاکنون در هیچ آزمونی شرکت نکرده‌اید.', style: TextStyle(color: Colors.grey)));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final result = snapshot.data![index];
                return _buildResultCard(result);
              },
            );
          }
        },
      ),
    );
  }

  // ساختار کارت نمره
  Widget _buildResultCard(Result result) {
    // رنگ بر اساس قبولی (معمولاً بالای ۱۰ یا ۱۲ از ۲۰)
    final isPassed = result.scoreOutOf20 >= 11;
    final scoreColor = isPassed ? AppColors.success : AppColors.error;
    
    // اگر پکیج intl نصب نیست، این قسمت را کامنت کنید
    final formattedDate = DateFormat('yyyy/MM/dd - HH:mm').format(result.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        
        // نمره از ۲۰ (سمت چپ)
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: scoreColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            result.scoreOutOf20.toStringAsFixed(1),
            style: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        
        // جزئیات آزمون (سمت راست)
        title: Text(
          result.topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.right,
          // textDirection: TextDirection.rtl,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 5),
            Text(
              'مضمون: ${result.subject.name}',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.right,
              // textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 3),
            Text(
              'صحیح: ${result.correctAnswers} از ${result.totalQuestions}',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.right,
              // textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 3),
            Text(
              'تاریخ: $formattedDate',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
              textAlign: TextAlign.right,
              // textDirection: TextDirection.rtl,
            ),
          ],
        ),
        trailing: Icon(isPassed ? FontAwesomeIcons.trophy : FontAwesomeIcons.circleXmark, color: scoreColor),
      ),
    );
  }
}