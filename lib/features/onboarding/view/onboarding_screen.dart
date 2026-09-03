import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Control Your Wealth',
      description: 'Manage accounts, cards, and daily expenses securely from a unified executive dashboard.',
      icon: LucideIcons.wallet,
    ),
    OnboardingData(
      title: 'Reach Your Goals',
      description: 'Set ambitious savings targets with live visual tracking and automated allocations.',
      icon: LucideIcons.target,
    ),
    OnboardingData(
      title: 'Master Your Subscriptions',
      description: 'Stay ahead of recurring renewals, avoid surprise charges, and optimize monthly cash flow.',
      icon: LucideIcons.repeat,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/auth-choice');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Obsidian Hero Icon Tile
                        Container(
                          width: 110.r,
                          height: 110.r,
                          decoration: BoxDecoration(
                            color: AppColors.zinc950,
                            borderRadius: BorderRadius.circular(28.r),
                            border: Border.all(color: AppColors.zinc800, width: 1.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 44.r, color: Colors.white),
                        ).animate(key: ValueKey(index)).scale(curve: Curves.easeOutBack, duration: 400.ms),
                        
                        Gap(48.h),
                        
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: AppColors.textDark,
                          ),
                        ).animate(key: ValueKey('title_$index')).fadeIn().slideY(begin: 0.2),
                        
                        Gap(12.h),
                        
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                            height: 1.4,
                          ),
                        ).animate(key: ValueKey('desc_$index')).fadeIn(delay: 100.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: _currentPage == index ? 24.w : 6.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.zinc200,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                  
                  Gap(28.h),
                  
                  // Action Button
                  NeoButton(
                    onPressed: _onNext,
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
