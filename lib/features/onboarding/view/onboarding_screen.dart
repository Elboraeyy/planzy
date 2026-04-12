import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: 'CONTROL THE CHAOS',
      description: 'Visualize your subscriptions and regular payments in one bold timeline.',
      icon: LucideIcons.zap,
      color: AppColors.cardYellow,
    ),
    OnboardingData(
      title: 'SMASH YOUR GOALS',
      description: 'Save for what matters most with physical progress tracking.',
      icon: LucideIcons.target,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'MASTER YOUR MONEY',
      description: 'Real-time budget tracking that keeps you ahead of the game.',
      icon: LucideIcons.wallet,
      color: AppColors.cardBlue,
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: 400.ms,
        curve: Curves.easeOutBack,
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
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Large Neo-Brutalist Icon
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: page.color,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppColors.border, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(10, 10),
                              ),
                            ],
                          ),
                          child: Icon(page.icon, size: 80, color: AppColors.textDark),
                        ).animate(key: ValueKey(index)).scale(curve: Curves.elasticOut, duration: 800.ms),
                        
                        const Gap(60),
                        
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ).animate(key: ValueKey('title_$index')).fadeIn().slideY(begin: 0.3),
                        
                        const Gap(24),
                        
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ).animate(key: ValueKey('desc_$index')).fadeIn(delay: 200.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                      ),
                    ),
                  ),
                  
                  const Gap(40),
                  
                  // Action Button
                  NeoButton(
                    onPressed: _onNext,
                    text: _currentPage == _pages.length - 1 ? 'GET STARTED' : 'CONTINUE',
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
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

