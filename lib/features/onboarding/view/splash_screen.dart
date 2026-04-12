import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // Wait for the animation and some delay
    await Future.delayed(2500.ms);
    
    if (!mounted) return;

    final settings = ref.read(settingsProvider).value;
    
    // Fallback if settings aren't loaded yet (though build() handles it)
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
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The "P" logo container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(8, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
            )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 800.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .shimmer(duration: 1200.ms),

            const SizedBox(height: 48),

            const Text(
              'PLANZY',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.5, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
