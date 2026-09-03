import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:planzy/features/subscriptions/presentation/providers/subscriptions_provider.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubs = ref.watch(activeSubscriptionsProvider);
    final monthlyCost = ref.watch(totalMonthlySubCostProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toolbox',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border, width: 1.r),
                  ),
                  child: Icon(
                    LucideIcons.wrench,
                    color: AppColors.textDark,
                    size: 18.r,
                  ),
                ),
              ],
            ),

            Gap(20.h),

            // Quick Stats Banner (Obsidian Bento Card)
            GestureDetector(
              onTap: () => context.push('/subscriptions'),
              child: Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: AppColors.zinc950,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.zinc800, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.zinc800,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '🔄',
                        style: TextStyle(fontSize: 22.sp),
                      ),
                    ),
                    Gap(14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${activeSubs.length} ACTIVE SUBSCRIPTIONS',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: AppColors.zinc400,
                            ),
                          ),
                          Gap(3.h),
                          Text(
                            '${NumberFormat.compact().format(monthlyCost)} / mo',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.arrowRight,
                      color: AppColors.zinc500,
                      size: 18.r,
                    ),
                  ],
                ),
              ),
            ),

            Gap(24.h),

            // Section label
            Text(
              'Your Tools',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.textDark,
              ),
            ),

            Gap(12.h),

            // Tools Grid
            Row(
              children: [
                // Subscriptions Tool — primary, featured
                Expanded(
                  child: _ToolCard(
                    emoji: '🔄',
                    title: 'Subscriptions',
                    subtitle: 'Track & manage',
                    badgeCount: activeSubs.length,
                    onTap: () => context.push('/subscriptions'),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: _ToolCard(
                    emoji: '📊',
                    title: 'Budgeting',
                    subtitle: 'Coming soon',
                    isComingSoon: true,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            Gap(12.h),

            // Second row
            Row(
              children: [
                Expanded(
                  child: _ToolCard(
                    emoji: '🧾',
                    title: 'Bills & Invoices',
                    subtitle: 'Coming soon',
                    isComingSoon: true,
                    onTap: () {},
                  ),
                ),
                Gap(12.w),
                const Expanded(child: SizedBox()),
              ],
            ),

            Gap(28.h),

            // Upcoming Renewals Section
            _UpcomingRenewalsSection(),

            Gap(80.h),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRenewalsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingRenewalsProvider);

    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Renewals',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textDark,
          ),
        ),
        Gap(12.h),
        ...upcoming.asMap().entries.map((entry) {
          final sub = entry.value;
          final daysLeft =
              sub.nextRenewalDate.difference(DateTime.now()).inDays;

          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: GestureDetector(
              onTap: () => context.push('/subscriptions'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          sub.category.emoji,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Gap(2.h),
                          Text(
                            DateFormat('MMM d').format(sub.nextRenewalDate),
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: daysLeft <= 2
                            ? AppColors.destructiveLight
                            : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        daysLeft <= 0 ? 'Today' : '${daysLeft}d',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: daysLeft <= 2
                              ? AppColors.destructive
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool isComingSoon;

  const _ToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeCount,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isComingSoon ? AppColors.zinc50 : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: isComingSoon
              ? null
              : [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (isComingSoon)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.zinc200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
              ],
            ),
            Gap(14.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: isComingSoon
                    ? AppColors.zinc400
                    : AppColors.textDark,
              ),
            ),
            Gap(2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
