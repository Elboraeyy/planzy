import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';

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
      // Load user settings
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 3),
        ),
        title: const Text(
          'RESET PASSWORD',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email and we\'ll send you a reset link.',
              style: TextStyle(color: AppColors.textLight),
            ),
            const Gap(16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'email@example.com',
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                final result = await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.success
                        ? 'Password reset email sent!'
                        : result.errorMessage ?? 'Failed to send reset email'),
                    backgroundColor: result.success ? AppColors.secondary : AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('SEND'),
          ),
        ],
      ),
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
                    const Gap(24),
                    Text(
                      'Signing you in...',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(40),

                    // Back button
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, size: 28),
                    ).animate().fadeIn(),

                    const Gap(20),

                    const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2),

                    const Gap(8),

                    const Text(
                      'LET\'S GET YOU BACK IN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1,
                        color: AppColors.textLight,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const Gap(60),

                    // Email field
                    const Text(
                      'EMAIL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                        color: AppColors.textLight,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const Gap(12),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'email@example.com',
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ).animate().scale(delay: 400.ms, curve: Curves.elasticOut, duration: 800.ms),

                    const Gap(32),

                    // Password field
                    const Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                        color: AppColors.textLight,
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const Gap(12),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        contentPadding: const EdgeInsets.all(20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                    ).animate().scale(delay: 600.ms, curve: Curves.elasticOut, duration: 800.ms),

                    const Gap(16),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),

                    const Gap(24),

                    // Error message
                    if (_errorMessage != null)
                      NeoCard(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().shake(),

                    const Gap(24),

                    NeoButton(
                      onPressed: _handleLogin,
                      text: 'LET\'S GO',
                    ).animate().fadeIn(delay: 800.ms),

                    const Gap(32),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 900.ms),

                    const Gap(40),
                  ],
                ),
              ),
      ),
    );
  }
}
