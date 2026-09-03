import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(2200.ms);
    
    if (!mounted) return;

    final settings = ref.read(settingsProvider).value;
    
    if (settings == null) {
      context.go('/onboarding');
      return;
    }

    if (settings.isProfileComplete) {
      context.go('/home');
    } else if (settings.hasCompletedOnboarding) {
      context.go('/auth-choice');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.zinc950,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.r,
              height: 96.r,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.zinc800, width: 1.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: EdgeInsets.all(18.r),
              child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
            )
            .animate()
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 400.ms),

            Gap(28.h),

            Text(
              'Planzy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, curve: Curves.easeOutCubic),

            Gap(6.h),

            Text(
              'Personal Wealth Workspace',
              style: TextStyle(
                color: AppColors.zinc400,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.8,
              ),
            )
            .animate()
            .fadeIn(delay: 350.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
