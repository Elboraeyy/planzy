import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Logo badge pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 14.r, color: AppColors.textDark),
                    Gap(6.w),
                    Text(
                      'Planzy Finance',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              Gap(20.h),

              Text(
                'Take Control of\nYour Financial Future.',
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.15,
                  color: AppColors.textDark,
                ),
              ),

              Gap(12.h),

              Text(
                'Track subscriptions, grow savings goals, and manage your wealth with precision in one executive space.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Actions
              NeoButton(
                onPressed: () => context.push('/signup'),
                text: 'Create Account',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),

              Gap(12.h),

              GestureDetector(
                onTap: () => context.push('/login'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.border, width: 1.r),
                  ),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),

              Gap(24.h),

              Center(
                child: Text(
                  'By continuing, you agree to our Terms of Service & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              Gap(12.h),
            ],
          ),
        ),
      ),
    );
  }
}
