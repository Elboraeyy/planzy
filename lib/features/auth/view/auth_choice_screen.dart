import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big Branding
              Text(
                'YOUR FINANCIAL',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.textLight,
                ),
              ).animate().fadeIn().slideY(begin: 0.3),
              Text(
                'FUTURE STARTS',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              Text(
                'HERE',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: AppColors.primary,
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),

              Gap(80.h),

              // Choice 1: Sign Up
              Column(
                children: [
                  Text(
                    'NEW TO PLANZY?',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.sp,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  Gap(16.h),
                  NeoButton(
                    onPressed: () => context.push('/signup'),
                    text: 'START NEW JOURNEY',
                    backgroundColor: AppColors.secondary,
                  ),
                ],
              ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),

              Gap(40.h),

              // Choice 2: Login
              Column(
                children: [
                  Text(
                    'ALREADY A MEMBER?',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.sp,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  Gap(16.h),
                  NeoButton(
                    onPressed: () => context.push('/login'),
                    text: 'WELCOME ME BACK',
                  ),
                ],
              ).animate().scale(delay: 800.ms, curve: Curves.elasticOut),

              Gap(60.h),

              Text(
                'BY JOINING, YOU AGREE TO MASTER YOUR MONEY.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
