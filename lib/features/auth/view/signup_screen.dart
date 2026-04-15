import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';

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
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOutBack);
    } else {
      _finalizeSignUp();
    }
  }

  Future<void> _finalizeSignUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

    if (!mounted) return;

    if (result.success) {
      // Update local settings
      final income = double.tryParse(_incomeController.text) ?? 0.0;
      await ref.read(settingsProvider.notifier).completeProfile(
            name: _nameController.text.trim(),
            currency: _selectedCurrency,
            monthlyIncome: income,
          );

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
      _pageController.previousPage(duration: 400.ms, curve: Curves.easeOutBack);
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
                    Gap(24.h),
                    Text(
                      'Creating your account...',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Header Progress
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _goBack,
                          icon: Icon(Icons.arrow_back, size: 28.r),
                        ),
                        Gap(16.w),
                        Expanded(
                          child: Row(
                            children: List.generate(3, (index) {
                              final isActive = index <= _currentStep;
                              return Expanded(
                                child: Container(
                                  height: 8.h,
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primary : AppColors.border.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(color: AppColors.border, width: 2.r),
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
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: NeoCard(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().shake(),
                    ),

                  // Next Button
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: NeoButton(
                      onPressed: _onNext,
                      text: _currentStep == 2 ? 'CREATE ACCOUNT' : 'NEXT STEP',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNameEmailStep() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LET\'S GET STARTED',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
              letterSpacing: 1,
              fontSize: 12.sp,
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
          Gap(8.h),
          Text(
            'WHAT SHOULD WE CALL YOU?',
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, height: 1.1),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          Gap(40.h),
          TextField(
            controller: _nameController,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: 'Your name...',
              contentPadding: EdgeInsets.all(24.r),
            ),
          ).animate().scale(delay: 300.ms, curve: Curves.elasticOut, duration: 800.ms),
          Gap(24.h),
          Text(
            'AND YOUR EMAIL?',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
          ).animate().fadeIn(delay: 400.ms),
          Gap(16.h),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'email@example.com',
              contentPadding: EdgeInsets.all(24.r),
            ),
          ).animate().scale(delay: 500.ms, curve: Curves.elasticOut, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SECURITY FIRST',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
              letterSpacing: 1,
              fontSize: 12.sp,
            ),
          ).animate().fadeIn(),
          Gap(8.h),
          Text(
            'CREATE A PASSWORD',
            style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, height: 1.1),
          ).animate().fadeIn(delay: 100.ms),
          Gap(8.h),
          Text(
            'At least 6 characters',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
              fontSize: 14.sp,
            ),
          ).animate().fadeIn(delay: 150.ms),
          Gap(40.h),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Password',
              contentPadding: EdgeInsets.all(24.r),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 24.r),
              ),
            ),
          ).animate().scale(delay: 300.ms, curve: Curves.elasticOut, duration: 800.ms),
          Gap(24.h),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Confirm password',
              contentPadding: EdgeInsets.all(24.r),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 24.r),
              ),
            ),
          ).animate().scale(delay: 400.ms, curve: Curves.elasticOut, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildCurrencyIncomeStep() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINAL TOUCHES',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
              letterSpacing: 1,
              fontSize: 12.sp,
            ),
          ).animate().fadeIn(),
          Gap(8.h),
          Text(
            'SELECT YOUR CURRENCY',
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, height: 1.1),
          ).animate().fadeIn(delay: 100.ms),
          Gap(32.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1,
            ),
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final curr = _currencies[index];
              final isSelected = _selectedCurrency == curr;
              return GestureDetector(
                onTap: () => setState(() => _selectedCurrency = curr),
                child: NeoCard(
                  backgroundColor: isSelected ? AppColors.secondary : AppColors.white,
                  child: Center(
                    child: Text(
                      curr,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp),
                    ),
                  ),
                ),
              ).animate().scale(delay: (index * 50).ms, curve: Curves.elasticOut);
            },
          ),
          Gap(40.h),
          Text(
            'MONTHLY INCOME (OPTIONAL)',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ).animate().fadeIn(delay: 300.ms),
          Gap(16.h),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: _selectedCurrency,
              suffixStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              contentPadding: EdgeInsets.all(24.r),
            ),
          ).animate().scale(delay: 400.ms, curve: Curves.elasticOut, duration: 800.ms),
        ],
      ),
    );
  }
}
