// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:med_exam_app/models/lecture.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// class LectureListScreen extends StatefulWidget {
//   final int subjectId;
//   final String subjectName;
//   const LectureListScreen({super.key, required this.subjectId, required this.subjectName});

//   @override
//   State<LectureListScreen> createState() => _LectureListScreenState();
// }

// class _LectureListScreenState extends State<LectureListScreen> {
//   bool _isLoading = true;
//   List<Lecture> _lectures = [];
//   Map<int, double> _downloadProgress = {}; // برای نمایش درصد دانلود تکی

//   @override
//   void initState() { super.initState(); _loadLectures(); }

//   Future<void> _loadLectures() async {
//     var box = await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}');
//     if (box.isNotEmpty) {
//       setState(() { _lectures = box.values.toList(); _isLoading = false; });
//     }
//     _fetchFromServer(box);
//   }

//   Future<void> _fetchFromServer(Box<Lecture> box) async {
//     try {
//       final response = await Dio().get("http://192.168.208.30:8000/api/lectures/${widget.subjectId}");
//       List<Lecture> remoteLectures = (response.data as List).map((j) => Lecture.fromJson(j)).toList();
      
//       // آپدیت دیتابیس آفلاین با اطلاعات جدید سرور
//       for (var remote in remoteLectures) {
//         if (!box.containsKey(remote.id)) { await box.put(remote.id, remote); }
//       }
//       setState(() { _lectures = box.values.toList(); _isLoading = false; });
//     } catch (e) { setState(() => _isLoading = false); }
//   }

//  Future<void> _openLecture(Lecture lecture) async {
//     // ۱. چک کردن فایل در حافظه گوشی
//     if (lecture.localPath != null && await File(lecture.localPath!).exists()) {
//       _launchFile(lecture.localPath!, isLocal: true);
//       return;
//     }

//     // ۲. دانلود برای اولین بار
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       String extension = lecture.filePath.split('.').last;
//       String savePath = "${directory.path}/lecture_${lecture.id}.$extension";

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("در حال دانلود و ذخیره در حافظه برای استفاده آفلاین..."))
//       );

//       await Dio().download(
//         lecture.fullFileUrl,
//         savePath,
//         onReceiveProgress: (count, total) {
//           setState(() { _downloadProgress[lecture.id] = count / total; });
//         },
//       );

//       // ۳. ذخیره آدرس در Hive برای همیشه
//       lecture.localPath = savePath;
//       var box = await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}');
//       await box.put(lecture.id, lecture); // 👈 ذخیره در دیتابیس گوشی

//       setState(() { _downloadProgress.remove(lecture.id); });
//       _launchFile(savePath, isLocal: true);

//     } catch (e) {
//       _launchFile(lecture.fullFileUrl, isLocal: false);
//     }
//   }

//   Future<void> _launchFile(String path, {required bool isLocal}) async {
//     final Uri url = isLocal ? Uri.file(path) : Uri.parse(path);
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       throw 'Could not launch $path';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: Text(widget.subjectName)),
//         body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
//           itemCount: _lectures.length,
//           itemBuilder: (context, index) {
//             final lec = _lectures[index];
//             bool isDownloaded = lec.localPath != null;
//             double? progress = _downloadProgress[lec.id];

//             return ListTile(
//               title: Text(lec.title),
//               subtitle: Text(isDownloaded ? "✅ ذخیره شده در حافظه" : "🌐 نیاز به اینترنت (بار اول)"),
//               leading: progress != null 
//                 ? CircularProgressIndicator(value: progress)
//                 : Icon(isDownloaded ? Icons.offline_pin : Icons.cloud_download, color: isDownloaded ? Colors.green : Colors.grey),
//               onTap: () => _openLecture(lec),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:med_exam_app/models/lecture.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // حتما این را اضافه کنید
class LectureListScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;
  const LectureListScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> {
  bool _isLoading = true;
  List<Lecture> _lectures = [];
  Map<int, double> _downloadProgress = {}; 

  @override
  void initState() { super.initState(); _loadLectures(); }

  // Future<void> _loadLectures() async {
  //   var box = await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}');
  //   if (box.isNotEmpty) {
  //     if (mounted) {
  //       setState(() { _lectures = box.values.toList(); _isLoading = false; });
  //     }
  //   }
  //   _fetchFromServer(box);
  // }
Future<void> _loadLectures() async {
  // ۱. اول چک کن آیا از صفحه قبلی لکچرها فرستاده شده (آفلاین)
  // اگر لکچرها در دیتابیس محلی (Hive) همراه با Subject ذخیره شده باشند:
  
  // ۲. چک کردن وضعیت اینترنت
  final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
     // اگر آفلاین بود، از جعبه لکچرهای کش شده استفاده کن
     var box = await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}');
     if (box.isNotEmpty) {
       setState(() { _lectures = box.values.toList(); _isLoading = false; });
       return;
     }
  }

  // ۳. اگر آنلاین بود یا دیتای آفلاین نداشت، از سرور بگیر (کد قبلی شما)
  _fetchFromServer(await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}'));
}
  Future<void> _fetchFromServer(Box<Lecture> box) async {
    try {
      // ۱. دریافت توکن از حافظه گوشی (بسیار مهم)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      // ۲. ارسال درخواست به همراه هدر Authorization
      final response = await Dio().get(
        "https://medexam.saberyinstitute.com/api/lectures/${widget.subjectId}",
        options: Options(headers: {
          'Authorization': 'Bearer $token', // بدون این خط، سرور اجازه دسترسی نمی‌دهد
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        List<Lecture> remoteLectures = (response.data as List).map((j) => Lecture.fromJson(j)).toList();
        
        await box.clear();
        for (var remote in remoteLectures) {
           await box.put(remote.id, remote); 
        }

        if (mounted) {
          setState(() { 
            _lectures = remoteLectures; 
            _isLoading = false; 
          });
        }
      }
    } catch (e) { 
      debugPrint("خطا در دریافت لکچرها: $e");
      if (mounted) setState(() => _isLoading = false); 
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.subjectName)),
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _lectures.isEmpty 
                ? const Center(child: Text("لکچری برای این مضمون یافت نشد."))
                : ListView.builder(
                    itemCount: _lectures.length,
                    itemBuilder: (context, index) {
                      final lec = _lectures[index];
                      bool isDownloaded = lec.localPath != null;
                      double? progress = _downloadProgress[lec.id];

                      return ListTile(
                        title: Text(lec.title),
                        subtitle: Text(isDownloaded ? "✅ ذخیره شده در حافظه" : "🌐 نیاز به اینترنت (بار اول)"),
                        leading: progress != null 
                          ? CircularProgressIndicator(value: progress)
                          : Icon(isDownloaded ? Icons.offline_pin : Icons.cloud_download, color: isDownloaded ? Colors.green : Colors.grey),
                        onTap: () => _openLecture(lec),
                      );
                    },
                  ),
      ),
    );
  }

  // Future<void> _openLecture(Lecture lecture) async {
  //   if (lecture.localPath != null && await File(lecture.localPath!).exists()) {
  //     _launchFile(lecture.localPath!, isLocal: true);
  //     return;
  //   }
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     String extension = lecture.filePath.split('.').last;
  //     String savePath = "${directory.path}/lecture_${lecture.id}.$extension";
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("در حال دانلود...")));
  //     await Dio().download(lecture.fullFileUrl, savePath, onReceiveProgress: (count, total) {
  //         setState(() { _downloadProgress[lecture.id] = count / total; });
  //     });
  //     lecture.localPath = savePath;
  //     var box = await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}');
  //     await box.put(lecture.id, lecture);
  //     setState(() { _downloadProgress.remove(lecture.id); });
  //     _launchFile(savePath, isLocal: true);
  //   } catch (e) { _launchFile(lecture.fullFileUrl, isLocal: false); }
  // }

  // Future<void> _launchFile(String path, {required bool isLocal}) async {
  //   final Uri url = isLocal ? Uri.file(path) : Uri.parse(path);
  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //      debugPrint("Could not launch $path");
  //   }
  // }
  Future<void> _openLecture(Lecture lecture) async {
  // ۱. اولویت با باز کردن مستقیم لینک آنلاین (این روش برای همه فایل‌ها بدون خطا کار می‌کند)
  final Uri url = Uri.parse(lecture.fullFileUrl);

  try {
    // باز کردن فایل با استفاده از مرورگر یا اپلیکیشن‌های پیش‌فرض گوشی
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       throw 'Could not launch $url';
    }
  } catch (e) {
    debugPrint("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("خطا در باز کردن فایل. لطفا اپلیکیشن مرتبط (مثل PowerPoint یا VLC) را نصب کنید."))
    );
  }

  // ۲. بخش دانلود در پس‌زمینه (برای اینکه فایل در حافظه گوشی بماند و حجم مصرف نشود)
  // اگر فایل قبلا دانلود نشده، آن را دانلود کن تا برای دفعات بعد آماده باشد
  if (lecture.localPath == null) {
      _startDownload(lecture);
  }
}

// متد جداگانه برای دانلود در پس‌زمینه بدون درگیر کردن کاربر
Future<void> _startDownload(Lecture lecture) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    String extension = lecture.filePath.split('.').last;
    String savePath = "${directory.path}/lecture_${lecture.id}.$extension";

    await Dio().download(lecture.fullFileUrl, savePath);

    // ذخیره مسیر در دیتابیس گوشی
    lecture.localPath = savePath;
    var box = await Hive.openBox<Lecture>('cached_lectures_${widget.subjectId}');
    await box.put(lecture.id, lecture);
    
    if (mounted) setState(() {}); // آپدیت آیکون دانلود شده
  } catch (e) { debugPrint("Download error: $e"); }
}
//   Future<void> _launchFile(String path, {required bool isLocal}) async {
//   if (isLocal) {
//     // برای فایل‌هایی که در حافظه گوشی ذخیره شده‌اند (آفلاین)
//     // این پکیج مشکل امنیتی اندروید را حل می‌کند
//     final result = await OpenFile.open(path);
    
//     if (result.type != ResultType.done) {
//       debugPrint("خطا در باز کردن فایل: ${result.message}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("برنامه‌ای برای باز کردن این فایل یافت نشد: ${result.message}"))
//       );
//     }
//   } else {
//     // برای لینک‌های مستقیم اینترنتی (آنلاین)
//     final Uri url = Uri.parse(path);
//     if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//       debugPrint("Could not launch $path");
//     }
//   }
// }
}