import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';

import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    final goalsAsync = ref.watch(goalsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: settingsAsync.when(
          data: (settings) {
            final userName = settings.userName.isNotEmpty
                ? settings.userName
                : 'Planner';
            final userEmail = currentUser?.email ?? settings.userEmail;
            final userBio = settings.userBio;
            final currency = settings.currency;
            final profileImagePath = settings.profileImagePath;

            // Stats

            final totalSaved = goalsAsync.when(
              data: (list) => list.fold<double>(0, (sum, i) => sum + i.savedAmount),
              loading: () => 0.0,
              error: (_, _) => 0.0,
            );
            final goalsCount = goalsAsync.when(
              data: (list) => list.length,
              loading: () => 0,
              error: (_, _) => 0,
            );

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              children: [
                // Top bar with settings icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROFILE',
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, letterSpacing: -1),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.cardYellow,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border, width: 3.r),
                          boxShadow: [
                            BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h)),
                          ],
                        ),
                        child: Icon(LucideIcons.settings, color: AppColors.textDark, size: 22.r),
                      ),
                    ).animate().slideX(begin: 1, curve: Curves.easeOutBack),
                  ],
                ),
                Gap(32.h),

                // Profile Card — big hero section
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NeoCard(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.all(28.r),
                            child: Column(
                              children: [
                                // Avatar
                                Container(
                                  width: 100.r,
                                  height: 100.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 4.r,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.border,
                                        offset: Offset(4.w, 4.h),
                                      ),
                                    ],
                                    image:
                                        (profileImagePath != null &&
                                            File(profileImagePath).existsSync())
                                        ? DecorationImage(
                                            image: FileImage(
                                              File(profileImagePath),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      (profileImagePath == null ||
                                          !File(profileImagePath).existsSync())
                                      ? Center(
                                          child: Text(
                                            userName.isNotEmpty
                                                ? userName[0].toUpperCase()
                                                : 'P',
                                            style: TextStyle(
                                              fontSize: 40.sp,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        )
                                      : null,
                                ).animate().scale(curve: Curves.easeOutBack),
                                Gap(20.h),

                                // Name
                                Text(
                                  userName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn(delay: 100.ms),

                                if (userBio.isNotEmpty) ...[
                                  Gap(8.h),
                                  Text(
                                    userBio,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(delay: 150.ms),
                                ],

                                if (userEmail.isNotEmpty) ...[
                                  Gap(8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      userEmail,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 200.ms),
                                ],
                              ],
                            ),
                          )
                          .animate()
                          .slideY(begin: 0.15, curve: Curves.easeOutBack)
                          .fadeIn(),

                      // Edit button - top left corner
                      Positioned(
                        top: 12.h,
                        left: 12.w,
                        child:
                            GestureDetector(
                                  onTap: () => context.push('/edit-profile'),
                                  child: Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 3.r,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.border,
                                          offset: Offset(3.w, 3.h),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      LucideIcons.pencil,
                                      color: AppColors.textDark,
                                      size: 18.r,
                                    ),
                                  ),
                                )
                                .animate()
                                .slideX(
                                  begin: -1,
                                  curve: Curves.easeOutBack,
                                  delay: const Duration(milliseconds: 150),
                                )
                                .fadeIn(),
                      ),
                    ],
                  ),
                ),

                Gap(32.h),

                // MY VAULT - Quick Action
                _QuickActionTile(
                      icon: LucideIcons.wallet,
                      title: 'MY VAULT',
                      subtitle: 'Manage all your accounts & cards',
                      color: AppColors.cardYellow,
                      onTap: () => context.push('/accounts'),
                      delay: 300,
                    )
                    .animate()
                    .slideY(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 300),
                    )
                    .fadeIn(),

                Gap(32.h),

                // Stats Grid
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Gap(16.w),
                    Expanded(
                      child: _StatCard(
                        label: 'SAVED',
                        value: '${NumberFormat.compact().format(totalSaved)} $currency',
                        icon: LucideIcons.piggyBank,
                        color: AppColors.cardBlue,
                        delay: 100,
                      ),
                    ),
                  ],
                ),
                Gap(16.h),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'GOALS',
                        value: '$goalsCount',
                        icon: LucideIcons.target,
                        color: AppColors.secondary,
                        delay: 200,
                      ),
                    ),
                    Gap(16.w),
                    Expanded(
                      child: _StatCard(
                        label: 'CURRENCY',
                        value: currency,
                        icon: LucideIcons.coins,
                        color: AppColors.white,
                        delay: 300,
                      ),
                    ),
                  ],
                ),

                Gap(40.h),

                // Quick Actions
                Text(
                  'QUICK ACTIONS',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                ).animate().fadeIn(delay: 400.ms),
                Gap(16.h),

                _QuickActionTile(
                  icon: LucideIcons.receipt,
                  title: 'TRANSACTION HISTORY',
                  subtitle: 'View all your transactions',
                  color: AppColors.cardBlue,
                  onTap: () => context.push('/transaction-history'),
                  delay: 500,
                ),

                Gap(32.h),

                // ABOUT section
                Text(
                  'ABOUT',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 700.ms),
                Gap(16.h),

                NeoCard(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      isInteractive: true,
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2.r,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                color: AppColors.textDark,
                                size: 20.r,
                              ),
                            ),
                            Gap(16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PLANZY',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.sp,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Gap(2.h),
                                  Text(
                                    'VERSION 1.0.0',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 750),
                    )
                    .fadeIn(),

                Gap(12.h),

                NeoCard(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      isInteractive: true,
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.cardYellow,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2.r,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.helpCircle,
                                color: AppColors.textDark,
                                size: 20.r,
                              ),
                            ),
                            Gap(16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HELP & SUPPORT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.sp,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Gap(2.h),
                                  Text(
                                    'Get help or contact us',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.textLight,
                              size: 20.r,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 800),
                    )
                    .fadeIn(),

                Gap(12.h),

                NeoCard(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      isInteractive: true,
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.cardBlue,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2.r,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.shield,
                                color: AppColors.textDark,
                                size: 20.r,
                              ),
                            ),
                            Gap(16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRIVACY POLICY',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.sp,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Gap(2.h),
                                  Text(
                                    'Read our privacy policy',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.textLight,
                              size: 20.r,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 850),
                    )
                    .fadeIn(),

                Gap(100.h),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: color,
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border, width: 2.r),
            ),
            child: Icon(icon, color: AppColors.textDark, size: 18.r),
          ),
          Gap(12.h),
          Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 1)),
          Gap(4.h),
          FittedBox(
            child: Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, letterSpacing: -1)),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack, delay: Duration(milliseconds: delay)).fadeIn();
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: AppColors.white,
      padding: EdgeInsets.zero,
      isInteractive: true,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border, width: 2.r),
              ),
              child: Icon(icon, color: AppColors.textDark, size: 20.r),
            ),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: -0.5)),
                  Gap(2.h),
                  Text(subtitle, style: TextStyle(color: AppColors.textLight, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: AppColors.textLight, size: 20.r),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.15, curve: Curves.easeOutBack, delay: Duration(milliseconds: delay)).fadeIn();
  }
}
