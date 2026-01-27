// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/auth/register_screen.dart';
import 'package:med_exam_app/screens/home_screen.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart'; // این پکیج را در pubspec اضافه کنید
import 'dart:io';

// --- تنظیمات API ---
const String API_URL = "http://192.168.86.30:8000/api"; // آدرس API لاراول شما
// const String API_URL = "http://127.0.0.1:8000/api"; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _deviceId = '';
  
  // برای گرفتن Device ID
  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }
  
  // متد گرفتن شناسه دستگاه (بسیار حیاتی برای امنیت)
  Future<void> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;
    
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // یا androidInfo.fingerprint
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_unknown';
      } else {
        deviceId = 'unknown_device';
      }
    } catch (e) {
      deviceId = 'error_getting_id';
    }

    setState(() {
      _deviceId = deviceId;
    });
    print("Device ID: $_deviceId"); // برای تست
  }


  // متد اصلی لاگین
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deviceId.isEmpty) {
      _showSnackBar('خطا: شناسه دستگاه دریافت نشد.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Dio().post(
        '$API_URL/login',
        data: {
          'username': _usernameController.text,
          'password': _passwordController.text,
          'device_id': _deviceId,
        },
      );

      // اگر لاگین موفق بود
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userName', response.data['user']['name']);
        
        // --- رفتن به صفحه اصلی ---
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); 
        _showSnackBar('ورود موفقیت‌آمیز. به صفحه اصلی هدایت می‌شوید.');

      } else {
         _showSnackBar('ورود ناموفق. لطفاً دوباره تلاش کنید.', isError: true);
      }

    } on DioException catch (e) {
      String errorMessage = 'مشکلی رخ داد، دوباره تلاش کنید.';
      if (e.response != null) {
        // خطاهای ارسالی از سمت لاراول (مثل رمز اشتباه یا محدودیت دستگاه)
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      _showSnackBar(errorMessage, isError: true);

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // متد نمایش پیغام
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
    // برای ریسپانسیو بودن، از SingleChildScrollView و MediaQuery استفاده می‌کنیم
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(30.0),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // لوگو و عنوان
              const Icon(FontAwesomeIcons.graduationCap, size: 80, color: AppColors.textLight),
              const SizedBox(height: 15),
              const Text(
                'سیستم آزمون هوشمند',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 50),

              // کارت فرم ورود
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // فیلد آیدی نمبر
                        _buildTextField(
                          controller: _usernameController,
                          label: 'ID Number (نام کاربری)',
                          icon: FontAwesomeIcons.user,
                          isRTL: true,
                        ),
                        const SizedBox(height: 20),

                        // فیلد پسورد
                        _buildTextField(
                          controller: _passwordController,
                          label: 'رمز عبور',
                          icon: FontAwesomeIcons.lock,
                          isPassword: true,
                          isRTL: true,
                        ),
                        const SizedBox(height: 30),

                        // دکمه ورود
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleLogin,
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: AppColors.textLight, strokeWidth: 3),
                                  )
                                : const Icon(FontAwesomeIcons.rightToBracket, size: 20),
                            label: Text(
                              _isLoading ? 'درحال ورود...' : 'ورود به سیستم',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 5,
                            ),
                          ),
                        ),
                         const SizedBox(height: 20), 
              TextButton(
                onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                }, 
                child: const Text(
                    'حساب کاربری ندارم. (ثبت نام جدید)',
                    style: TextStyle(color: AppColors.textLight),
                ),
              )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // نمایش Device ID (برای تست)
              Text(
                'شناسه دستگاه: $_deviceId',
                style: const TextStyle(color: AppColors.textLight, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // تابع کمکی برای ساخت فیلدها با طراحی مدرن
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isRTL = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      textAlign: isRTL ? TextAlign.right : TextAlign.left,
      // keyboardType: isRTL ? TextInputType.number : TextInputType.text, // برای ID Number
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textDark),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Icon(icon, color: AppColors.primaryDark),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'این فیلد الزامی است';
        }
        return null;
      },
    );
  }
}