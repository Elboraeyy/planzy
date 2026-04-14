import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('SUBSCRIPTIONS'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _showAddSheet(context, ref),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: AppColors.textDark,
                  size: 20,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Summary banner
              _SummaryBanner(
                activeCount: activeSubs.length,
                totalCount: subscriptions.length,
                monthlyCost: monthlyCost,
              ),
              const Gap(24),

              // Section label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALL SUBSCRIPTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.textLight,
                    ),
                  ),
                  Text(
                    '${subscriptions.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
              const Gap(16),

              // Subscription cards
              ...subscriptions.asMap().entries.map((entry) {
                final index = entry.key;
                final sub = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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

              const Gap(100),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: NeoCard(
              backgroundColor: AppColors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('😕', style: TextStyle(fontSize: 48)),
                  const Gap(16),
                  const Text(
                    'OOPS!',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Failed to load subscriptions.\n$err',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 13,
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
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: totalCount > 0 ? activeCount / totalCount : 0,
                    strokeWidth: 6,
                    backgroundColor: AppColors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY TOTAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
                const Gap(6),
                FittedBox(
                  child: Text(
                    NumberFormat.compact().format(monthlyCost),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const Gap(4),
                Text(
                  '$activeCount active · ${totalCount - activeCount} paused',
                  style: TextStyle(
                    fontSize: 12,
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
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 3),
        ),
        child: const Icon(
          LucideIcons.trash2,
          color: AppColors.white,
          size: 24,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(subscription.category)
                      .withValues(alpha: isActive ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AppColors.border
                        : AppColors.textLight.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    subscription.iconEmoji ?? subscription.category.emoji,
                    style: TextStyle(
                      fontSize: 22,
                      color: isActive ? null : AppColors.textLight,
                    ),
                  ),
                ),
              ),
              const Gap(14),

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
                              fontSize: 15,
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
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.secondary
                                : AppColors.textLight.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(subscription.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            subscription.category.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isActive
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Gap(8),
                        // Renewal info
                        if (isActive)
                          Text(
                            daysLeft <= 0
                                ? 'Renews today!'
                                : daysLeft == 1
                                    ? 'Renews tomorrow'
                                    : 'in $daysLeft days',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: daysLeft <= 3
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          )
                        else
                          const Text(
                            'PAUSED',
                            style: TextStyle(
                              fontSize: 11,
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

              const Gap(12),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.compact().format(subscription.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                      color: isActive
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                  Text(
                    '${subscription.currency} ${subscription.cycle.shortLabel}',
                    style: TextStyle(
                      fontSize: 10,
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fun visual
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cardYellow.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 3),
              ),
              child: const Center(
                child: Text(
                  '🔄',
                  style: TextStyle(fontSize: 48),
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
            const Gap(32),
            const Text(
              'NO SUBS YET',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const Gap(12),
            const Text(
              "Track your subscriptions and never\nbe surprised by a renewal again!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            GestureDetector(
              onTap: onAddTap,
              child: NeoCard(
                backgroundColor: AppColors.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, color: AppColors.textDark),
                    Gap(8),
                    Text(
                      'ADD FIRST SUB',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
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
