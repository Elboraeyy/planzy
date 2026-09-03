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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers for inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  String _selectedCurrency = 'EGP';
  final List<String> _currencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED'];

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0: // Name & Email
        if (_nameController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Please enter your name');
          return false;
        }
        if (_emailController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'Please enter your email');
          return false;
        }
        if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
          setState(() => _errorMessage = 'Please enter a valid email');
          return false;
        }
        return true;
      case 1: // Password
        if (_passwordController.text.length < 6) {
          setState(() => _errorMessage = 'Password must be at least 6 characters');
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() => _errorMessage = 'Passwords do not match');
          return false;
        }
        return true;
      case 2: // Currency & Income
        return true;
      default:
        return true;
    }
  }

  void _onNext() {
    setState(() => _errorMessage = null);

    if (!_validateStep()) return;

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finalizeSignUp();
    }
  }

  Future<void> _finalizeSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final income = double.tryParse(_incomeController.text.trim()) ?? 0.0;

    final result = await ref.read(authNotifierProvider.notifier).signUp(
          email: email,
          password: password,
          displayName: name,
        );

    if (!mounted) return;

    if (result.success) {
      await ref.read(settingsProvider.notifier).updateCurrency(_selectedCurrency);
      if (income > 0) {
        await ref.read(settingsProvider.notifier).updateIncome(income);
      }
      if (name.isNotEmpty) {
        await ref.read(settingsProvider.notifier).updateName(name);
      }

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

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.pop();
    }
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
                      'Creating your account...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Header Progress
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _goBack,
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
                        Gap(16.w),
                        Expanded(
                          child: Row(
                            children: List.generate(3, (index) {
                              final isActive = index <= _currentStep;
                              return Expanded(
                                child: Container(
                                  height: 3.h,
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primary : AppColors.zinc200,
                                    borderRadius: BorderRadius.circular(1.5.r),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (val) => setState(() => _currentStep = val),
                      children: [
                        _buildNameEmailStep(),
                        _buildPasswordStep(),
                        _buildCurrencyIncomeStep(),
                      ],
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      child: Container(
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
                    ),

                  // Next Button
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: NeoButton(
                      onPressed: _onNext,
                      text: _currentStep == 2 ? 'Create Account' : 'Continue',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNameEmailStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12.h),
          Text(
            'Create Account',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              color: AppColors.textDark,
              letterSpacing: -0.4,
            ),
          ),
          Gap(4.h),
          Text(
            'Enter your basic information to get started.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
          Gap(28.h),
          Text(
            'Full Name',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
          ),
          Gap(8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'What should we call you?',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                prefixIcon: Icon(LucideIcons.user, size: 18.r, color: AppColors.zinc400),
              ),
            ),
          ),
          Gap(20.h),
          Text(
            'Email Address',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
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
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12.h),
          Text(
            'Set Password',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              color: AppColors.textDark,
              letterSpacing: -0.4,
            ),
          ),
          Gap(4.h),
          Text(
            'Choose a strong password with at least 6 characters.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
          Gap(28.h),
          Text(
            'Password',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
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
                hintText: 'At least 6 characters',
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
          Gap(20.h),
          Text(
            'Confirm Password',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
          ),
          Gap(8.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                prefixIcon: Icon(LucideIcons.shieldCheck, size: 18.r, color: AppColors.zinc400),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(_obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 18.r, color: AppColors.zinc400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyIncomeStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12.h),
          Text(
            'Preferences',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24.sp,
              color: AppColors.textDark,
              letterSpacing: -0.4,
            ),
          ),
          Gap(4.h),
          Text(
            'Select your primary currency and optional monthly income.',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
          Gap(24.h),
          Text(
            'Primary Currency',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
          ),
          Gap(10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.5,
            ),
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final curr = _currencies[index];
              final isSelected = _selectedCurrency == curr;
              return GestureDetector(
                onTap: () => setState(() => _selectedCurrency = curr),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      curr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Gap(24.h),
          Text(
            'Monthly Income (Optional)',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
          ),
          Gap(10.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: _selectedCurrency,
                suffixStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
