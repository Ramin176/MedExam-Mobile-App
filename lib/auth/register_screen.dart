import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:med_exam_app/utils/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_exam_app/screens/home_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

const String API_URL = "https://medexam.saberyinstitute.com/api";

// const String API_URL = "http://192.168.173.30:8000/api"; 
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // اضافه شده برای محصل خارجی
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _deviceId = '';

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
    } catch (e) { _deviceId = 'unknown_device'; }
    if (mounted) setState(() {});
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await Dio().post(
        '$API_URL/register',
        data: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
          'device_id': _deviceId,
          'student_type': 'external', // به صورت خودکار خارجی ارسال می‌شود
        },
      );

      final data = response.data;
      
      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', data['token']);
        await prefs.setString('userName', data['user']['name']);
        
        final String generatedId = data['username_generated'];

        if (!mounted) return;

        // نمایش دیالوگ حاوی آی‌دی نمبر ساخته شده (بسیار مهم)
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('ثبت‌نام موفقیت‌آمیز', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('محصل گرامی، آی‌دی نمبر شما برای ورود به سیستم ساخته شد:'),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Text(generatedId, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.blue)),
                  ),
                  const SizedBox(height: 15),
                  const Text('لطفاً این کد را یادداشت کنید. برای ورودهای بعدی به این کد نیاز دارید.', style: TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('فهمیدم و ورود به برنامه'),
                )
              ],
            ),
          ),
        );

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on DioException catch (e) {
      String msg = e.response?.data['message'] ?? 'خطایی رخ داد (احتمالاً ایمیل تکراری است)';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.right), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ثبت‌نام محصل خارجی')),
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
                _buildField(_emailController, 'ایمیل آدرس', Icons.email_outlined),
                const SizedBox(height: 15),
                _buildField(_passwordController, 'رمز عبور دلخواه', Icons.lock_outline, isPass: true),
                const SizedBox(height: 15),
                _buildField(_confirmPasswordController, 'تکرار رمز عبور', Icons.lock_reset, isPass: true, validator: (v) {
                  if (v != _passwordController.text) return 'رمز عبور همخوانی ندارد';
                  return null;
                }),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ایجاد حساب و دریافت آی‌دی نمبر'),
                  ),
                ),
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
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.primary)),
      validator: validator ?? (v) => v!.isEmpty ? 'اجباری' : null,
    );
  }
}