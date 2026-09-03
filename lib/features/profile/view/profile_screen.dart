import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';

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
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
                // Top bar with settings icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border, width: 1.r),
                        ),
                        child: Icon(LucideIcons.settings, color: AppColors.textDark, size: 18.r),
                      ),
                    ),
                  ],
                ),
                Gap(20.h),

                // Profile Card — Obsidian Bento Section
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: AppColors.zinc950,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.zinc800, width: 1.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 76.r,
                              height: 76.r,
                              decoration: BoxDecoration(
                                color: AppColors.zinc800,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2.r,
                                ),
                                image: (profileImagePath != null &&
                                        File(profileImagePath).existsSync())
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(profileImagePath),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (profileImagePath == null ||
                                      !File(profileImagePath).existsSync())
                                  ? Center(
                                      child: Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : 'P',
                                        style: TextStyle(
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            Gap(14.h),

                            // Name
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),

                            if (userBio.isNotEmpty) ...[
                              Gap(4.h),
                              Text(
                                userBio,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.zinc400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            if (userEmail.isNotEmpty) ...[
                              Gap(10.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.zinc800,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.zinc300,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Edit button - top right corner
                      Positioned(
                        top: 14.h,
                        right: 14.w,
                        child: GestureDetector(
                          onTap: () => context.push('/edit-profile'),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.zinc800,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.zinc700,
                                width: 1.r,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.pencil,
                              color: Colors.white,
                              size: 14.r,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(20.h),

                // MY VAULT - Quick Action
                _QuickActionTile(
                  icon: LucideIcons.wallet,
                  title: 'Accounts & Cards',
                  subtitle: 'Manage all your accounts & cards',
                  onTap: () => context.push('/accounts'),
                ),

                Gap(24.h),

                // Stats Section
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.textDark,
                  ),
                ),
                Gap(12.h),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Saved',
                        value: '${NumberFormat.compact().format(totalSaved)} $currency',
                        icon: LucideIcons.piggyBank,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: _StatCard(
                        label: 'Active Goals',
                        value: '$goalsCount',
                        icon: LucideIcons.target,
                      ),
                    ),
                  ],
                ),

                Gap(24.h),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.textDark,
                  ),
                ),
                Gap(12.h),

                _QuickActionTile(
                  icon: LucideIcons.receipt,
                  title: 'Transaction History',
                  subtitle: 'View all your transactions',
                  onTap: () => context.push('/transaction-history'),
                ),

                Gap(24.h),

                // ABOUT section
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.textDark,
                  ),
                ),
                Gap(12.h),

                _QuickActionTile(
                  icon: LucideIcons.sparkles,
                  title: 'Planzy',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
                Gap(10.h),
                _QuickActionTile(
                  icon: LucideIcons.helpCircle,
                  title: 'Help & Support',
                  subtitle: 'Get help or contact us',
                  onTap: () {},
                ),
                Gap(10.h),
                _QuickActionTile(
                  icon: LucideIcons.shield,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {},
                ),

                Gap(80.h),
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

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.zinc100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.textDark, size: 16.r),
          ),
          Gap(12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
          Gap(2.h),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.textDark, size: 18.r),
            ),
            Gap(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      letterSpacing: -0.2,
                      color: AppColors.textDark,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: AppColors.zinc400, size: 16.r),
          ],
        ),
      ),
    );
  }
}
