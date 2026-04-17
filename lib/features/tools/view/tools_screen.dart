import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:planzy/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubs = ref.watch(activeSubscriptionsProvider);
    final monthlyCost = ref.watch(totalMonthlySubCostProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOOLBOX',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 3.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border,
                        offset: Offset(4.w, 4.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.wrench,
                    color: AppColors.textDark,
                    size: 22.r,
                  ),
                ).animate().slideX(begin: 1, curve: Curves.easeOutBack),
              ],
            ),

            Gap(32.h),

            // Quick Stats Banner
            NeoCard(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      '🔄',
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activeSubs.length} ACTIVE SUBS',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white.withValues(alpha: 0.7),
                            letterSpacing: 1,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '${NumberFormat.compact().format(monthlyCost)} / mo',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.arrowRight,
                    color: AppColors.white.withValues(alpha: 0.5),
                    size: 22.r,
                  ),
                ],
              ),
            )
                .animate()
                .slideY(begin: 0.15, curve: Curves.easeOutBack)
                .fadeIn(),

            Gap(32.h),

            // Section label
            Text(
              'YOUR TOOLS',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.textLight,
              ),
            ).animate().fadeIn(delay: 200.ms),

            Gap(16.h),

            // Tools Grid
            Row(
              children: [
                // Subscriptions Tool — primary, featured
                Expanded(
                  child: _ToolCard(
                    emoji: '🔄',
                    title: 'SUBS',
                    subtitle: 'Track & manage',
                    color: AppColors.cardYellow,
                    badgeCount: activeSubs.length,
                    onTap: () => context.push('/subscriptions'),
                    delay: 300,
                  ),
                ),
                Gap(16.w),
                const Expanded(child: SizedBox()),
              ],
            ),

            Gap(16.h),

            // Second row — coming soon tools
            Row(
              children: [
                Expanded(
                  child: _ToolCard(
                    emoji: '📊',
                    title: 'BUDGET',
                    subtitle: 'Coming soon',
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    isComingSoon: true,
                    onTap: () {},
                    delay: 500,
                  ),
                ),
                Gap(16.w),
                Expanded(
                  child: _ToolCard(
                    emoji: '🧾',
                    title: 'BILLS',
                    subtitle: 'Coming soon',
                    color: AppColors.white,
                    isComingSoon: true,
                    onTap: () {},
                    delay: 600,
                  ),
                ),
              ],
            ),

            Gap(32.h),

            // Upcoming Renewals Section
            _UpcomingRenewalsSection(),

            Gap(100.h),
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
          'UPCOMING RENEWALS',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ).animate().fadeIn(delay: 700.ms),
        Gap(16.h),
        ...upcoming.asMap().entries.map((entry) {
          final index = entry.key;
          final sub = entry.value;
          final daysLeft =
              sub.nextRenewalDate.difference(DateTime.now()).inDays;

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: NeoCard(
              backgroundColor: AppColors.white,
              padding: EdgeInsets.all(16.r),
              isInteractive: true,
              onTap: () => context.push('/subscriptions'),
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.cardYellow.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                      border:
                          Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Center(
                      child: Text(
                        sub.category.emoji,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.sp,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          DateFormat('dd MMM').format(sub.nextRenewalDate),
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: daysLeft <= 2
                          ? AppColors.primary
                          : AppColors.cardYellow,
                      borderRadius: BorderRadius.circular(8.r),
                      border:
                          Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Text(
                      daysLeft <= 0 ? 'TODAY' : '${daysLeft}d',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: daysLeft <= 2
                            ? AppColors.white
                            : AppColors.textDark,
                      ),
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
                delay: Duration(milliseconds: 800 + (index * 100)),
              )
              .fadeIn();
        }),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;
  final int? badgeCount;
  final bool isComingSoon;

  const _ToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.delay,
    this.badgeCount,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: color,
      padding: EdgeInsets.all(20.r),
      isInteractive: !isComingSoon,
      onTap: isComingSoon ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 2.r),
                ),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 22.sp),
                ),
              ),
              if (badgeCount != null && badgeCount! > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border, width: 2.r),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              if (isComingSoon)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'SOON',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          Gap(16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isComingSoon
                  ? AppColors.textLight
                  : AppColors.textDark,
            ),
          ),
          Gap(4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: isComingSoon
                  ? AppColors.textLight.withValues(alpha: 0.5)
                  : AppColors.textLight,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 0.2,
          curve: Curves.easeOutBack,
          delay: Duration(milliseconds: delay),
        )
        .fadeIn();
  }
}
