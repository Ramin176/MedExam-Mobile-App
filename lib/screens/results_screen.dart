
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:med_exam_app/models/result.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:intl/intl.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'dart:ui' as ui;

// const String API_URL = "https://medexam.saberyinstitute.com/api";

// // const String API_URL = "http://192.168.173.30:8000/api"; 
// class ResultsScreen extends StatefulWidget {
//   const ResultsScreen({super.key});
//   @override
//   State<ResultsScreen> createState() => _ResultsScreenState();
// }

// class _ResultsScreenState extends State<ResultsScreen> {
//   Future<List<Result>>? _resultsFuture;
  
//   @override
//   void initState() { super.initState(); _resultsFuture = _fetchAndCacheResults(); }

//   Future<List<Result>> _fetchAndCacheResults() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
    
//     // ۱. دریافت دیتای کش شده از Hive (موقتا برای نمایش سریع)
//     // var box = await Hive.openBox<Result>('cached_results'); // نیاز به رجیستر آداپتور دارد، فعلا لیست ساده

//     try {
//       final response = await Dio().get(
//         '$API_URL/my-results', 
//         options: Options(headers: {'Authorization': 'Bearer $token'}) // ارسال توکن الزامی
//       );
//       final List<dynamic> jsonList = response.data;
//       return jsonList.map((json) => Result.fromJson(json)).toList();
//     } catch (e) {
//       throw Exception('خطا در دریافت نتایج از سرور');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('کارنامه آزمون‌ها')),
//         body: FutureBuilder<List<Result>>(
//           future: _resultsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//             if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
//             if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('آزمونی ثبت نشده است.'));
            
//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) => _buildResultCard(snapshot.data![index]),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildResultCard(Result result) {
//     final isPassed = result.scoreOutOf20 >= 10;
//     final color = isPassed ? AppColors.success : AppColors.error;
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Text(result.scoreOutOf20.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.bold))),
//         title: Text(result.topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text('صحیح: ${result.correctAnswers} از ${result.totalQuestions}'),
//         trailing: Icon(isPassed ? FontAwesomeIcons.trophy : FontAwesomeIcons.circleXmark, color: color, size: 20),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/models/result.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:ui' as ui;

// آدرس آی‌پی خود را چک کنید
// const String API_URL = "http://192.168.173.30:8000/api"; 
const String API_URL = "https://medexam.saberyinstitute.com/api";
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
    _resultsFuture = _fetchAndCacheResults(); 
  }

  Future<List<Result>> _fetchAndCacheResults() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    // ۱. باز کردن باکس Hive برای کش کردن نتایج
    var resultsBox = await Hive.openBox('results_cache');
    
    // ۲. بررسی وضعیت اینترنت
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    bool isOffline = connectivityResult.contains(ConnectivityResult.none);

    // ۳. اگر آفلاین بود، دیتای ذخیره شده را برگردان
    if (isOffline) {
      final List<dynamic>? cachedData = resultsBox.get('my_results');
      if (cachedData != null) {
        return cachedData.map((json) => Result.fromJson(Map<String, dynamic>.from(json))).toList();
      } else {
        throw Exception('شما آفلاین هستید و کارنامه‌ای ذخیره نشده است.');
      }
    }

    // ۴. اگر آنلاین بود، از سرور بگیر و کش را آپدیت کن
    try {
      final response = await Dio().get(
        '$API_URL/my-results', 
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        })
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        
        // ذخیره در Hive برای استفاده آفلاین بعدی
        await resultsBox.put('my_results', jsonList);
        
        return jsonList.map((json) => Result.fromJson(json)).toList();
      } else {
        throw Exception('خطا در دریافت اطلاعات از سرور');
      }
    } catch (e) {
      // اگر در هنگام درخواست آنلاین خطایی رخ داد، سعی کن دیتای آفلاین را نشان دهی
      final List<dynamic>? cachedData = resultsBox.get('my_results');
      if (cachedData != null) {
        return cachedData.map((json) => Result.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      throw Exception('خطا در ارتباط با سرور');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('کارنامه آزمون‌ها'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() { _resultsFuture = _fetchAndCacheResults(); }),
            )
          ],
        ),
        body: FutureBuilder<List<Result>>(
          future: _resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(snapshot.error.toString(), textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () => setState(() { _resultsFuture = _fetchAndCacheResults(); }),
                        child: const Text('تلاش مجدد'),
                      )
                    ],
                  ),
                ),
              );
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('آزمونی ثبت نشده است.'));
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => _buildResultCard(snapshot.data![index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultCard(Result result) {
    final isPassed = result.scoreOutOf20 >= 11; // نمره قبولی را ۱۱ فرض کردیم
    final color = isPassed ? AppColors.success : AppColors.error;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            result.scoreOutOf20.toStringAsFixed(1), 
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
        title: Text(result.topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('مضمون: ${result.subject.name}', style: const TextStyle(fontSize: 12)),
            Text('صحیح: ${result.correctAnswers} از ${result.totalQuestions}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Icon(
          isPassed ? FontAwesomeIcons.trophy : FontAwesomeIcons.circleXmark, 
          color: color, 
          size: 22
        ),
      ),
    );
  }
}