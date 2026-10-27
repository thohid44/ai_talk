import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/core/widgets/custom_button.dart';
import 'package:ai_talk_test/core/widgets/custom_text_field.dart';
import 'package:ai_talk_test/core/widgets/error_view.dart';
import 'package:ai_talk_test/core/widgets/responsive_frame.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _loginIdError;
  String? _passwordError;

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final auth = context.read<AuthProvider>();
    if (auth.isSubmitting) return;

    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;
    final login = int.tryParse(loginId);
    final loginIdError = loginId.isEmpty
        ? 'Enter your login ID'
        : login == null
        ? 'Login ID must be a number'
        : null;
    final passwordError = password.isEmpty ? 'Enter your password' : null;

    auth.clearError();
    setState(() {
      _loginIdError = loginIdError;
      _passwordError = passwordError;
    });

    if (loginIdError != null || passwordError != null || login == null) return;

    final signedIn = await auth.login(login: login, password: password);
    if (!mounted || !signedIn) return;

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ResponsiveFrame(
                  maxWidth: 420,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
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
                              boxShadow: AppColors.cardShadow,
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
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Sign in with your login ID and password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        _FieldLabel(text: 'Login ID'),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: _loginIdController,
                          hintText: 'Login ID',
                          errorText: _loginIdError,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 16.h),
                        _FieldLabel(text: 'Password'),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: _obscurePassword,
                          errorText: _passwordError,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onLogin(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        if (auth.errorMessage != null) ...[
                          SizedBox(height: 16.h),
                          ErrorBanner(message: auth.errorMessage!),
                        ],
                        SizedBox(height: 24.h),
                        CustomButton(
                          width: double.infinity,
                          height: 48.h,
                          text: auth.isSubmitting ? 'Signing in...' : 'Login',
                          backgroundColor: primary,
                          textColor: Colors.white,
                          onPressed: auth.isSubmitting ? null : _onLogin,
                        ),
                      ],
                    ),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    );
  }
}
