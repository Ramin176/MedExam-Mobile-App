
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:med_exam_app/utils/app_theme.dart';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:med_exam_app/screens/home_screen.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'dart:io';

// const String API_URL = "https://medexam.saberyinstitute.com/api";

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _nameController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   String _deviceId = '';
//   String _selectedStudentType = 'internal';

//   @override
//   void initState() {
//     super.initState();
//     _getDeviceId();
//   }

//   Future<void> _getDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       final android = await deviceInfo.androidInfo;
//       _deviceId = android.id;
//     } else if (Platform.isIOS) {
//       final ios = await deviceInfo.iosInfo;
//       _deviceId = ios.identifierForVendor ?? 'ios';
//     }
//     setState(() {});
//   }

//   Future<void> _handleRegister() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     try {
//       final response = await Dio().post('$API_URL/register', data: {
//         'name': _nameController.text,
//         'username': _usernameController.text,
//         'password': _passwordController.text,
//         'password_confirmation': _confirmPasswordController.text,
//         'device_id': _deviceId,
//         'student_type': _selectedStudentType,
//       });

//       if (response.data['status'] == 'success') {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('authToken', response.data['token']);
//         await prefs.setString('userName', response.data['user']['name']);
//         if (response.data['admin_telegram'] != null) {
//           await prefs.setString('adminTelegram', response.data['admin_telegram']);
//         }
//         if (!mounted) return;
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
//       }
//     } on DioException catch (e) {
//       String msg = e.response?.data['message'] ?? 'خطای ثبت‌نام';
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.right), backgroundColor: AppColors.error));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('ثبت‌نام کاربر جدید')),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(25),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Icon(FontAwesomeIcons.userPlus, size: 60, color: AppColors.secondary),
//                 const SizedBox(height: 25),
//                 _buildField(_nameController, 'نام و نام خانوادگی', Icons.person_outline),
//                 const SizedBox(height: 15),
//                 _buildField(_usernameController, 'ID Number (نام کاربری)', Icons.badge_outlined),
//                 const SizedBox(height: 15),
                
//                 // دراپ‌داون استایل‌دهی شده
//                 DropdownButtonFormField<String>(
//                   value: _selectedStudentType,
//                   decoration: const InputDecoration(labelText: 'نوع محصل', prefixIcon: Icon(Icons.school_outlined)),
//                   items: const [
//                     DropdownMenuItem(value: 'internal', child: Text('محصل داخلی')),
//                     DropdownMenuItem(value: 'external', child: Text('محصل خارجی')),
//                   ],
//                   onChanged: (v) => setState(() => _selectedStudentType = v!),
//                 ),
                
//                 const SizedBox(height: 15),
//                 _buildField(_passwordController, 'رمز عبور', Icons.lock_outline, isPass: true),
//                 const SizedBox(height: 15),
//                 _buildField(_confirmPasswordController, 'تکرار رمز عبور', Icons.lock_reset, isPass: true, validator: (v) {
//                   if (v != _passwordController.text) return 'رمز عبور همخوانی ندارد';
//                   return null;
//                 }),
//                 const SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _handleRegister,
//                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
//                   child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ایجاد حساب و ورود'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false, String? Function(String?)? validator}) {
//     return TextFormField(
//       controller: ctrl,
//       obscureText: isPass,
//       decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
//       validator: validator ?? (v) => v!.isEmpty ? 'اجباری' : null,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/screens/home_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

// آدرس API شما
const String API_URL = "https://medexam.saberyinstitute.com/api";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _deviceId = '';
  String _selectedStudentType = 'internal'; // داخلی یا خارجی

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        _deviceId = android.id;
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        _deviceId = ios.identifierForVendor ?? 'ios';
      }
    } catch (e) {
      _deviceId = 'unknown_device';
    }
    if (mounted) setState(() {});
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    // اطمینان از گرفتن دیوایس آیدی
    if (_deviceId.isEmpty || _deviceId == 'error') {
      await _getDeviceId();
    }

    setState(() => _isLoading = true);

    try {
      // تنظیمات Dio برای دریافت پاسخ صحیح بصورت JSON
      final response = await Dio().post(
        '$API_URL/register',
        data: {
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
          'device_id': _deviceId,
          'student_type': _selectedStudentType,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // بررسی ایمن داده‌های دریافتی
      final data = response.data;
      
      if (data is Map && data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        
        // ذخیره توکن و نام کاربر
        await prefs.setString('authToken', data['token'].toString());
        await prefs.setString('userName', data['user']['name'].toString());
        
        // ذخیره ایمیل و نوع محصل برای استفاده در صفحات پلن و آزمون
        await prefs.setString('userEmail', data['user']['email'] ?? "${_usernameController.text}@med.com");
        await prefs.setString('studentType', data['user']['student_type'] ?? _selectedStudentType);

        // ذخیره آیدی تلگرام ادمین که از پنل تنظیمات لاراول می‌آید
        if (data['admin_telegram'] != null) {
          await prefs.setString('adminTelegram', data['admin_telegram'].toString());
        }

        if (!mounted) return;
        _showSnackBar('ثبت نام با موفقیت انجام شد', isError: false);
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const HomeScreen())
        );
      } else {
        _showSnackBar(data['message'] ?? 'خطایی در ثبت‌نام رخ داد');
      }

    } on DioException catch (e) {
      String msg = 'مشکل در اتصال به سرور';
      if (e.response != null && e.response!.data is Map) {
        msg = e.response!.data['message'] ?? 'خطای اعتبارسنجی سرور';
        // اگر خطاهای فیلدها را بخواهید:
        if (e.response!.data['errors'] != null) {
          msg = (e.response!.data['errors'] as Map).values.first[0];
        }
      }
      _showSnackBar(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Vazirmatn')),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ثبت‌نام محصل جدید')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(FontAwesomeIcons.userPlus, size: 60, color: AppColors.primary),
                const SizedBox(height: 25),
                _buildField(_nameController, 'نام و نام خانوادگی', Icons.person_outline),
                const SizedBox(height: 15),
                _buildField(_usernameController, 'آیدی نمبر (نام کاربری)', Icons.badge_outlined),
                const SizedBox(height: 15),
                
                // دراپ‌داون انتخاب نوع محصل
                DropdownButtonFormField<String>(
                  value: _selectedStudentType,
                  decoration: const InputDecoration(
                    labelText: 'نوع محصل', 
                    prefixIcon: Icon(Icons.school_outlined, color: AppColors.primary)
                  ),
                  items: const [
                    DropdownMenuItem(value: 'internal', child: Text('محصل داخلی (انستیتوت)')),
                    DropdownMenuItem(value: 'external', child: Text('محصل خارجی (خرید پلن)')),
                  ],
                  onChanged: (v) => setState(() => _selectedStudentType = v!),
                ),
                
                const SizedBox(height: 15),
                _buildField(_passwordController, 'رمز عبور', Icons.lock_outline, isPass: true),
                const SizedBox(height: 15),
                _buildField(_confirmPasswordController, 'تکرار رمز عبور', Icons.lock_reset, isPass: true, validator: (v) {
                  if (v != _passwordController.text) return 'رمز عبور همخوانی ندارد';
                  if (v!.length < 6) return 'رمز باید حداقل ۶ کاراکتر باشد';
                  return null;
                }),
                const SizedBox(height: 35),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('ایجاد حساب و ورود به صنف', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('قبلاً حساب ساخته‌اید؟ وارد شوید'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon, color: AppColors.primary)
      ),
      validator: validator ?? (v) => v!.isEmpty ? 'تکمیل این فیلد اجباری است' : null,
    );
  }
}