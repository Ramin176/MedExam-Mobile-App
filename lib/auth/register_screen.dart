// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/screens/home_screen.dart';
import 'package:device_info_plus/device_info_plus.dart'; 
import 'dart:io';

// --- تنظیمات API ---
const String API_URL = "http://192.168.86.30:8000/api"; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    // ... (همان منطق قبلی در LoginScreen)
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;
    
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; 
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
  }

  Future<void> _handleRegister() async {
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
        '$API_URL/register',
        options: Options(
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ),
        data: {
          'name': _nameController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text, // مهم
          'device_id': _deviceId,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userName', response.data['user']['name']);
        
        _showSnackBar('ثبت نام موفقیت‌آمیز.');
        
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); 
      }

    } on DioException catch (e) {
      
      String errorMessage = 'مشکلی رخ داد، دوباره تلاش کنید.';
      // if (e.response != null && e.response!.data.containsKey('message')) {
      //    errorMessage = e.response!.data['message'];
      // } else if (e.response != null && e.response!.data.containsKey('errors')) {
      //    // نمایش خطای ولیدیشن لاراول
      //    final errors = e.response!.data['errors'];
      //    errorMessage = errors.values.first.first;
      // }
      if (e.response != null) {
      // این خطا HTML را چاپ می‌کند تا دلیل اصلی را ببینیم
      print("LARAVEL RESPONSE: ${e.response!.data}"); 
      errorMessage = "خطای سرور: لطفاً ترمینال را چک کنید.";
  }
      _showSnackBar(errorMessage, isError: true);

    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(title: const Text('ثبت نام محصل جدید')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            const Icon(FontAwesomeIcons.solidAddressCard, size: 60, color: AppColors.primaryDark),
            const SizedBox(height: 20),
            const Text(
              'ایجاد حساب کاربری',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // فیلد نام
                      _buildTextField(controller: _nameController, label: 'نام کامل', icon: FontAwesomeIcons.user, isRTL: true),
                      const SizedBox(height: 20),
                      // فیلد آیدی نمبر
                      _buildTextField(controller: _usernameController, label: 'ID Number (نام کاربری)', icon: FontAwesomeIcons.idCard, isRTL: true),
                      const SizedBox(height: 20),
                      // فیلد پسورد
                      _buildTextField(controller: _passwordController, label: 'رمز عبور', icon: FontAwesomeIcons.lock, isPassword: true, isRTL: true),
                      const SizedBox(height: 20),
                      // فیلد تکرار پسورد
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'تکرار رمز عبور',
                        icon: FontAwesomeIcons.lockOpen,
                        isPassword: true,
                        isRTL: true,
                        validator: (value) {
                            if (value != _passwordController.text) {
                                return 'رمز عبور با تکرار آن مطابقت ندارد.';
                            }
                            return null;
                        }
                      ),
                      const SizedBox(height: 30),

                      // دکمه ثبت نام
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleRegister,
                          icon: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.textLight, strokeWidth: 3))
                              : const Icon(FontAwesomeIcons.rightToBracket, size: 20),
                          label: Text(
                            _isLoading ? 'درحال ثبت نام...' : 'ثبت نام و ورود',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.textLight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // دکمه بازگشت به لاگین
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('قبلاً حساب کاربری دارم. (بازگشت به ورود)'),
            )
          ],
        ),
      ),
    );
  }
  
  // تابع کمکی برای ساخت فیلدها
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isRTL = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      textAlign: isRTL ? TextAlign.right : TextAlign.left,
      keyboardType: isRTL ? TextInputType.text : TextInputType.text,
      style: const TextStyle(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textDark),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Icon(icon, color: AppColors.primaryDark),
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'این فیلد الزامی است';
        }
        return null;
      },
    );
  }
}