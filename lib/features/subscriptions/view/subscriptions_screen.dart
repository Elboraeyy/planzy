import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/neo_dialog.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:planzy/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:planzy/features/subscriptions/view/add_subscription_sheet.dart';
import 'package:planzy/features/subscriptions/services/subscription_notification_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsProvider);
    final monthlyCost = ref.watch(totalMonthlySubCostProvider);
    final activeSubs = ref.watch(activeSubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('SUBSCRIPTIONS', style: TextStyle(fontSize: 18.sp)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 24.r),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () => _showAddSheet(context, ref),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 3.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(3.w, 3.h),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.plus,
                  color: AppColors.textDark,
                  size: 20.r,
                ),
              ),
            ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
      body: subsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _EmptyState(
              onAddTap: () => _showAddSheet(context, ref),
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            children: [
              // Summary banner
              _SummaryBanner(
                activeCount: activeSubs.length,
                totalCount: subscriptions.length,
                monthlyCost: monthlyCost,
              ),
              Gap(24.h),

              // Section label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ALL SUBSCRIPTIONS',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    '${subscriptions.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
              Gap(16.h),

              // Subscription cards
              ...subscriptions.asMap().entries.map((entry) {
                final index = entry.key;
                final sub = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _SubscriptionCard(
                    subscription: sub,
                    index: index,
                    onTap: () => _showAddSheet(context, ref, existing: sub),
                    onToggle: () async {
                      await ref
                          .read(subscriptionsProvider.notifier)
                          .toggleActive(sub.id, !sub.isActive);
                      if (sub.isActive) {
                        await SubscriptionNotificationService.cancelReminder(
                            sub.id);
                      } else {
                        await SubscriptionNotificationService
                            .scheduleRenewalReminder(
                          sub.copyWith(isActive: true),
                        );
                      }
                    },
                    onDelete: () {
                      NeoDialog.show(
                        context: context,
                        title: 'DELETE SUBSCRIPTION?',
                        message:
                            'Remove "${sub.name}" from your subscriptions? This cannot be undone.',
                        confirmText: 'YES, DELETE',
                        cancelText: 'NO, KEEP IT',
                        isDestructive: true,
                        onConfirm: () async {
                          await ref
                              .read(subscriptionsProvider.notifier)
                              .remove(sub.id);
                          await SubscriptionNotificationService.cancelReminder(
                              sub.id);
                        },
                      );
                    },
                  ),
                );
              }),

              Gap(100.h),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(32.r),
            child: NeoCard(
              backgroundColor: AppColors.white,
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text('😕', style: TextStyle(fontSize: 48.sp)),
                  Gap(16.h),
                   Text(
                    'OOPS!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20.sp,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'Failed to load subscriptions.\n$err',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref,
      {Subscription? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubscriptionSheet(existing: existing),
    );
  }
}

// ─── Summary Banner ──────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final int activeCount;
  final int totalCount;
  final double monthlyCost;

  const _SummaryBanner({
    required this.activeCount,
    required this.totalCount,
    required this.monthlyCost,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.all(24.r),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 64.r,
            height: 64.r,
            child: Stack(
              children: [
                SizedBox(
                  width: 64.r,
                  height: 64.r,
                  child: CircularProgressIndicator(
                    value: totalCount > 0 ? activeCount / totalCount : 0,
                    strokeWidth: 6.r,
                    backgroundColor: AppColors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Text(
                    '$activeCount',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY TOTAL',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
                Gap(6.h),
                FittedBox(
                  child: Text(
                    NumberFormat.compact().format(monthlyCost),
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Gap(4.h),
                Text(
                  '$activeCount active · ${totalCount - activeCount} paused',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.15, curve: Curves.easeOutBack)
        .fadeIn();
  }
}

// ─── Subscription Card ──────────────────────────────────────
class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubscriptionCard({
    required this.subscription,
    required this.index,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        subscription.nextRenewalDate.difference(DateTime.now()).inDays;
    final isActive = subscription.isActive;

    return Dismissible(
      key: Key(subscription.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 3.r),
        ),
        child: Icon(
          LucideIcons.trash2,
          color: AppColors.white,
          size: 24.r,
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // Dialog handles deletion
      },
      child: NeoCard(
        backgroundColor: isActive ? AppColors.white : AppColors.background,
        padding: EdgeInsets.zero,
        isInteractive: true,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: _getCategoryColor(subscription.category)
                      .withValues(alpha: isActive ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isActive
                        ? AppColors.border
                        : AppColors.textLight.withValues(alpha: 0.3),
                    width: 2.r,
                  ),
                ),
                child: Center(
                  child: Text(
                    subscription.iconEmoji ?? subscription.category.emoji,
                    style: TextStyle(
                      fontSize: 22.sp,
                      color: isActive ? null : AppColors.textLight,
                    ),
                  ),
                ),
              ),
              Gap(14.w),

              // Name + details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subscription.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.sp,
                              letterSpacing: -0.5,
                              color: isActive
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                              decoration: isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Active indicator dot
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.secondary
                                : AppColors.textLight.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Gap(4.h),
                    Row(
                      children: [
                        // Category tag
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(subscription.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            subscription.category.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Gap(8.w),
                        // Renewal info
                        if (isActive)
                          Text(
                            daysLeft <= 0
                                ? 'Renews today!'
                                : daysLeft == 1
                                    ? 'Renews tomorrow'
                                    : 'in $daysLeft days',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: daysLeft <= 3
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          )
                        else
                          Text(
                            'PAUSED',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                              letterSpacing: 1,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              Gap(12.w),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.compact().format(subscription.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                      letterSpacing: -0.5,
                      color: isActive
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                  Text(
                    '${subscription.currency} ${subscription.cycle.shortLabel}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideX(
          begin: 0.15,
          curve: Curves.easeOutBack,
          delay: Duration(milliseconds: 350 + (index * 80)),
        )
        .fadeIn();
  }

  Color _getCategoryColor(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.entertainment:
        return AppColors.primary;
      case SubscriptionCategory.health:
        return AppColors.secondary;
      case SubscriptionCategory.education:
        return AppColors.cardBlue;
      case SubscriptionCategory.music:
        return const Color(0xFFE040FB);
      case SubscriptionCategory.cloud:
        return AppColors.cardBlue;
      case SubscriptionCategory.gaming:
        return AppColors.secondary;
      case SubscriptionCategory.food:
        return AppColors.cardYellow;
      case SubscriptionCategory.shopping:
        return AppColors.cardYellow;
      case SubscriptionCategory.transport:
        return AppColors.tertiary;
      case SubscriptionCategory.other:
        return AppColors.textLight;
    }
  }
}

// ─── Empty State ──────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fun visual
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                color: AppColors.cardYellow.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 3.r),
              ),
              child: Center(
                child: Text(
                  '🔄',
                  style: TextStyle(fontSize: 48.sp),
                ),
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 2.seconds,
                ),
            Gap(32.h),
            Text(
              'NO SUBS YET',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Gap(12.h),
            Text(
              "Track your subscriptions and never\nbe surprised by a renewal again!",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(32.h),
            GestureDetector(
              onTap: onAddTap,
              child: NeoCard(
                backgroundColor: AppColors.secondary,
                padding:
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, color: AppColors.textDark, size: 24.r),
                    Gap(8.w),
                    Text(
                      'ADD FIRST SUB',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .slideY(begin: 0.3, curve: Curves.easeOutBack, delay: 300.ms)
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}
