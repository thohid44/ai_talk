import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:ai_talk_test/widgets/custom_button.dart';
import 'package:ai_talk_test/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _loginIdError;
  String? _passwordError;

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_isSubmitting) return;

    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;
    final loginIdError = loginId.isEmpty ? 'Enter your login ID' : null;
    final passwordError = password.isEmpty ? 'Enter your password' : null;

    setState(() {
      _loginIdError = loginIdError;
      _passwordError = passwordError;
    });

    if (loginIdError != null || passwordError != null) return;

    setState(() => _isSubmitting = true);

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: loginId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: Container(
                          height: 72.w,
                          width: 72.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Icon(
                            Icons.show_chart,
                            color: Colors.white,
                            size: 36.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'AI Talk',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Welcome back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2332),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Sign in with your login ID and password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF5C6B7A),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      CustomTextField(
                        controller: _loginIdController,
                        hintText: 'Login ID',
                        errorText: _loginIdError,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: _obscurePassword,
                        errorText: _passwordError,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        width: double.infinity,
                        height: 48.h,
                        text: _isSubmitting ? 'Signing in...' : 'Login',
                        backgroundColor: primary,
                        textColor: Colors.white,
                        onPressed: _isSubmitting ? null : _onLogin,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
