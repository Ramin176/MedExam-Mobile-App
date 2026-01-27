// // lib/screens/home_screen.dart

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:med_exam_app/auth/login_screen.dart';
// import 'package:med_exam_app/screens/results_screen.dart';
// import 'package:med_exam_app/screens/subject_detail_screen.dart';
// import 'package:med_exam_app/screens/plan_screen.dart'; // وارد کردن صفحه پلن‌ها
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:med_exam_app/models/student_class.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// // --- تنظیمات API ---
// const String API_URL = "http://192.168.86.30:8000/api"; // آدرس را به IP محلی خود تغییر دهید

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // برای نگهداری لیست کلاس‌های فعال و لیست کامل کلاس‌ها (برای پلن)
//   Future<Map<String, List<StudentClass>>>? _classesFuture;
//   String _userName = 'کاربر';
  
//   // متغیرهای موقت برای ذخیره داده
//   List<StudentClass> _activeClasses = [];
//   List<StudentClass> _allClasses = [];


//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();
//     _classesFuture = _fetchClassesData();
//   }

//   // گرفتن نام کاربر از SharedPreferences
//   void _loadUserInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _userName = prefs.getString('userName') ?? 'کاربر محترم';
//     });
//   }
  
//   // متد لاگ اوت
//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
    
//     if (token != null) {
//       try {
//         await Dio().post(
//           '$API_URL/logout',
//           options: Options(headers: {'Authorization': 'Bearer $token'}),
//         );
//       } catch (e) {
//         print("Logout API Error: $e");
//       }
//     }
    
//     await prefs.remove('authToken');
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginScreen()),
//       (Route<dynamic> route) => false,
//     );
//   }
  
//   // متد گرفتن لیست کلاس‌های فعال و غیرفعال از API
//   Future<Map<String, List<StudentClass>>> _fetchClassesData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('authToken');
    
//     if (token == null) return Future.error('کاربر لاگین نیست');
    
//     try {
//       // ۱. دریافت کلاس‌های فعال
//       final activeResponse = await Dio().get(
//         '$API_URL/my-classes',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
      
//       // ۲. دریافت تمام کلاس‌ها (برای بخش پلن‌های خرید)
//       final allResponse = await Dio().get(
//         '$API_URL/all-classes',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
      
//       final List<dynamic> activeJsonList = activeResponse.data;
//       final List<dynamic> allJsonList = allResponse.data;
      
//       _activeClasses = activeJsonList.map((json) => StudentClass.fromJson(json)).toList();
//       _allClasses = allJsonList.map((json) => StudentClass.fromJson(json)).toList();
      
//       return {
//         'active': _activeClasses,
//         'all': _allClasses,
//       };

//     } on DioException catch (e) {
//       print("Error fetching classes: $e");
//       if (e.response?.statusCode == 401) {
//         _logout();
//         return Future.error('نشست کاربری منقضی شده است.');
//       }
//       return Future.error('خطا در دریافت اطلاعات: ${e.message}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('صفحه اصلی'),
//         actions: [
//           // دکمه خروج
//           IconButton(
//             icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
//             onPressed: _logout,
//             tooltip: 'خروج از حساب',
//           ),
//           // دکمه کارنامه
//           IconButton(
//             icon:  Icon(FontAwesomeIcons.solidSquare),
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
//             },
//             tooltip: 'کارنامه',
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // کارت خوش آمدگویی مدرن
//           Container(
//             padding: const EdgeInsets.all(20),
//             color: AppColors.primary,
//             width: double.infinity,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // دکمه خرید پلن (جدید)
//                 SizedBox(
//                   height: 40,
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context, 
//                         MaterialPageRoute(
//                           builder: (_) => PlanScreen(availablePlans: _allClasses),
//                         ),
//                       );
//                     },
//                     icon: const Icon(FontAwesomeIcons.tags, size: 18),
//                     label: const Text('خرید پلن'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryDark,
//                       foregroundColor: AppColors.textLight,
//                     ),
//                   ),
//                 ),
                
//                 // متن خوش آمدید
//                 Text(
//                   'خوش آمدید، $_userName',
//                   style: const TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.right,
//                 ),
//               ],
//             ),
//           ),

//           const Padding(
//             padding: EdgeInsets.only(top: 20, right: 20, bottom: 10),
//             child: Text(
//               'صنف‌ها و مضامین فعال شما:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
//               textAlign: TextAlign.right,
//             ),
//           ),
          
//           // لیست صنف‌ها
//           Expanded(
//             child: FutureBuilder<Map<String, List<StudentClass>>>(
//               future: _classesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('خطا: ${snapshot.error}', textAlign: TextAlign.center));
//                 } else if (!snapshot.hasData || snapshot.data!['active']!.isEmpty) {
//                   return const Center(child: Text('شما در هیچ صنفی فعال نیستید. برای شروع به بخش خرید پلن مراجعه کنید.', 
//                                         textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
//                 } else {
//                   // از لیست کلاس‌های فعال استفاده می‌شود
//                   final activeClasses = snapshot.data!['active']!;
//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     itemCount: activeClasses.length,
//                     itemBuilder: (context, index) {
//                       final studentClass = activeClasses[index];
//                       return _buildClassCard(context, studentClass);
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // ساختار کارت صنف (طراحی مدرن)
//   Widget _buildClassCard(BuildContext context, StudentClass studentClass) {
//     // محاسبه روزهای باقی مانده
//     final daysRemaining = studentClass.endDate.difference(DateTime.now()).inDays;
    
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//       child: ExpansionTile(
//         tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//         leading: const Icon(FontAwesomeIcons.bookOpen, color: AppColors.primary, size: 30),
//         title: Text(
//           studentClass.name,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
//           textAlign: TextAlign.right,
//         ),
//         subtitle: Text(
//           'باقیمانده: $daysRemaining روز (تا ${studentClass.endDate.year}/${studentClass.endDate.month}/${studentClass.endDate.day})',
//           style: TextStyle(color: daysRemaining < 30 ? AppColors.error : Colors.grey),
//           textAlign: TextAlign.right,
//         ),
        
//         // محتوای داخل کارت (لیست مضامین)
//         children: studentClass.subjects.map((subject) {
//           return ListTile(
//             contentPadding: const EdgeInsets.only(right: 40, left: 20, bottom: 5),
//             leading: const Icon(FontAwesomeIcons.chevronLeft, size: 15, color: AppColors.primaryDark),
//             title: Text(subject.name, textAlign: TextAlign.right),
//             onTap: () {
//               // هدایت به صفحه جزئیات مضمون
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SubjectDetailScreen(subject: subject),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:med_exam_app/auth/login_screen.dart';
import 'package:med_exam_app/screens/results_screen.dart';
import 'package:med_exam_app/screens/subject_detail_screen.dart';
import 'package:med_exam_app/screens/plan_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/models/student_class.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 
import 'package:hive_flutter/hive_flutter.dart';

// --- تنظیمات API ---
const String API_URL = "http://192.168.86.30:8000/api";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, List<StudentClass>>>? _classesFuture;
  String _userName = 'کاربر';
  
  List<StudentClass> _activeClasses = [];
  List<StudentClass> _allClasses = [];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _classesFuture = _fetchClassesData();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'کاربر محترم';
    });
  }
  
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    if (token != null) {
      try {
        await Dio().post('$API_URL/logout', options: Options(headers: {'Authorization': 'Bearer $token'}));
      } catch (e) {
        print("Logout API Error: $e");
      }
    }
    
    await prefs.remove('authToken');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
  
  // متد اصلی برای دریافت و همگام سازی داده ها (Offline-First)
  Future<Map<String, List<StudentClass>>> _fetchClassesData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    final connection = await Connectivity().checkConnectivity();
    final isOnline = connection != ConnectivityResult.none;
    
    final classBox = await Hive.openBox<StudentClass>('activeClasses');
    
    // اگر آنلاین نبودیم، از Hive می‌خوانیم
    if (!isOnline) {
        _activeClasses = classBox.values.toList();
        _allClasses = _activeClasses; 
        
        if (_activeClasses.isEmpty) {
            return Future.error('اتصال اینترنت قطع است و دیتای آفلاینی موجود نیست.');
        }
        _showSnackBar('شما در حالت آفلاین هستید. دیتای قبلی نمایش داده می‌شود.');
        return {'active': _activeClasses, 'all': _allClasses};
    }
    
    // اگر آنلاین بودیم، دکتا را از API می‌گیریم
    try {
        final activeResponse = await Dio().get('$API_URL/my-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
        final allResponse = await Dio().get('$API_URL/all-classes', options: Options(headers: {'Authorization': 'Bearer $token'}));
        
        final List<dynamic> activeJsonList = activeResponse.data;
        final List<dynamic> allJsonList = allResponse.data;
        
        _activeClasses = activeJsonList.map((json) => StudentClass.fromJson(json)).toList();
        _allClasses = allJsonList.map((json) => StudentClass.fromJson(json)).toList();
        
        // --- ذخیره در Hive (همگام سازی) ---
        await classBox.clear();
        for (var cls in _activeClasses) {
            await classBox.put(cls.id, cls);
        }
        _showSnackBar('داده‌ها با موفقیت از سرور همگام سازی شدند.');
        
        return {'active': _activeClasses, 'all': _allClasses};

    } on DioException catch (e) {
        // اگر آنلاین بودیم ولی خطا داد (مثلاً توکن منقضی)
        if (e.response?.statusCode == 401) _logout();
        
        // تلاش نهایی برای خواندن از Hive در صورت خطای آنلاین
        if (classBox.values.isNotEmpty) {
             _activeClasses = classBox.values.toList();
             _allClasses = _activeClasses;
             _showSnackBar('خطا در اتصال به سرور. دیتای آفلاین نمایش داده می‌شود.');
             return {'active': _activeClasses, 'all': _allClasses};
        }
        return Future.error('خطا در دریافت اطلاعات: ${e.message}');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحه اصلی'),
        actions: [
          // دکمه آپدیت دیتا (Sync)
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowsRotate),
            onPressed: () {
                setState(() {
                    _classesFuture = _fetchClassesData(); // دوباره دیتا را فچ می‌کند
                });
            },
            tooltip: 'به‌روزرسانی داده‌ها',
          ),
          // دکمه کارنامه
          IconButton(
            icon: const Icon(FontAwesomeIcons.squarePollVertical),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
            },
            tooltip: 'کارنامه',
          ),
          // دکمه خروج
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
            onPressed: _logout,
            tooltip: 'خروج از حساب',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // کارت خوش آمدگویی مدرن و دکمه خرید
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primary,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlanScreen(availablePlans: _allClasses)));
                    },
                    icon: const Icon(FontAwesomeIcons.tags, size: 18),
                    label: const Text('خرید پلن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.textLight,
                    ),
                  ),
                ),
                Text(
                  'خوش آمدید، $_userName',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          // ... (بقیه UI)
          const Padding(
            padding: EdgeInsets.only(top: 20, right: 20, bottom: 10),
            child: Text(
              'صنف‌ها و مضامین فعال شما:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              textAlign: TextAlign.right,
            ),
          ),
          
          Expanded(
            child: FutureBuilder<Map<String, List<StudentClass>>>(
              future: _classesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('خطا: ${snapshot.error}', textAlign: TextAlign.center));
                } else if (!snapshot.hasData || snapshot.data!['active']!.isEmpty) {
                  return const Center(child: Text('شما در هیچ صنفی فعال نیستید. برای شروع به بخش خرید پلن مراجعه کنید.', 
                                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
                } else {
                  final activeClasses = snapshot.data!['active']!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    itemCount: activeClasses.length,
                    itemBuilder: (context, index) {
                      final studentClass = activeClasses[index];
                      return _buildClassCard(context, studentClass);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // ساختار کارت صنف (طراحی مدرن)
  Widget _buildClassCard(BuildContext context, StudentClass studentClass) {
    final daysRemaining = studentClass.endDate.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: const Icon(FontAwesomeIcons.bookOpen, color: AppColors.primary, size: 30),
        title: Text(
          studentClass.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          'باقیمانده: $daysRemaining روز (تا ${studentClass.endDate.year}/${studentClass.endDate.month}/${studentClass.endDate.day})',
          style: TextStyle(color: daysRemaining < 30 ? AppColors.error : Colors.grey),
          textAlign: TextAlign.right,
        ),
        children: studentClass.subjects.map((subject) {
          return ListTile(
            contentPadding: const EdgeInsets.only(right: 40, left: 20, bottom: 5),
            leading: const Icon(FontAwesomeIcons.chevronLeft, size: 15, color: AppColors.primaryDark),
            title: Text(subject.name, textAlign: TextAlign.right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectDetailScreen(subject: subject),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}