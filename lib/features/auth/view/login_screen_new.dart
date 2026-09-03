import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authNotifierProvider.notifier).signIn(
          email: email,
          password: password,
        );

    if (!mounted) return;

    if (result.success) {
      await ref.read(settingsProvider.notifier).build();

      if (mounted) {
        context.go('/home');
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Gap(4.h),
                    Text(
                      'Enter your email to receive a password reset link.',
                      style: TextStyle(color: AppColors.textLight, fontSize: 13.sp, fontWeight: FontWeight.w400),
                    ),
                    Gap(16.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: TextField(
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'email@example.com',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          prefixIcon: Icon(LucideIcons.mail, size: 16.r, color: AppColors.zinc400),
                        ),
                      ),
                    ),
                    Gap(20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500, fontSize: 13.sp),
                          ),
                        ),
                        Gap(8.w),
                        ElevatedButton(
                          onPressed: () async {
                            final email = resetEmailController.text.trim();
                            if (email.isNotEmpty) {
                              final messenger = ScaffoldMessenger.of(context);
                              final result = await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }

                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(result.success
                                      ? 'Password reset email sent!'
                                      : result.errorMessage ?? 'Failed to send reset email'),
                                  backgroundColor: result.success ? AppColors.success : AppColors.destructive,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            elevation: 0,
                          ),
                          child: Text('Send Link', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    Gap(20.h),
                    Text(
                      'Signing you in...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(12.h),

                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: AppColors.zinc100,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(LucideIcons.arrowLeft, size: 18.r, color: AppColors.textDark),
                      ),
                    ),

                    Gap(28.h),

                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.textDark,
                      ),
                    ),

                    Gap(4.h),

                    Text(
                      'Sign in to manage your budget and savings.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Gap(36.h),

                    // Email field
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Gap(8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: 'email@example.com',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                          prefixIcon: Icon(LucideIcons.mail, size: 18.r, color: AppColors.zinc400),
                        ),
                      ),
                    ),

                    Gap(20.h),

                    // Password field
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Gap(8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                          prefixIcon: Icon(LucideIcons.lock, size: 18.r, color: AppColors.zinc400),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 18.r, color: AppColors.zinc400),
                          ),
                        ),
                      ),
                    ),

                    Gap(12.h),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),

                    Gap(24.h),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.destructiveLight,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.destructive,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Gap(20.h),
                    ],

                    NeoButton(
                      onPressed: _handleLogin,
                      text: 'Sign In',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),

                    Gap(28.h),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w400,
                            fontSize: 13.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Gap(40.h),
                  ],
                ),
              ),
      ),
    );
  }
}
