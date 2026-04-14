import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOOLBOX',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.border,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.wrench,
                    color: AppColors.textDark,
                    size: 22,
                  ),
                ).animate().slideX(begin: 1, curve: Curves.easeOutBack),
              ],
            ),

            const Gap(32),

            // Quick Stats Banner
            NeoCard(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '🔄',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activeSubs.length} ACTIVE SUBS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white.withValues(alpha: 0.7),
                            letterSpacing: 1,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '${NumberFormat.compact().format(monthlyCost)} / mo',
                          style: const TextStyle(
                            fontSize: 24,
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
                    size: 22,
                  ),
                ],
              ),
            )
                .animate()
                .slideY(begin: 0.15, curve: Curves.easeOutBack)
                .fadeIn(),

            const Gap(32),

            // Section label
            const Text(
              'YOUR TOOLS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.textLight,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const Gap(16),

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
                const Gap(16),
                // Timeline Tool — preserved from old tab
                Expanded(
                  child: _ToolCard(
                    emoji: '📅',
                    title: 'TIMELINE',
                    subtitle: 'Payment events',
                    color: AppColors.cardBlue,
                    onTap: () => context.push('/timeline'),
                    delay: 400,
                  ),
                ),
              ],
            ),

            const Gap(16),

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
                const Gap(16),
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

            const Gap(32),

            // Upcoming Renewals Section
            _UpcomingRenewalsSection(),

            const Gap(100),
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
        const Text(
          'UPCOMING RENEWALS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ).animate().fadeIn(delay: 700.ms),
        const Gap(16),
        ...upcoming.asMap().entries.map((entry) {
          final index = entry.key;
          final sub = entry.value;
          final daysLeft =
              sub.nextRenewalDate.difference(DateTime.now()).inDays;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeoCard(
              backgroundColor: AppColors.white,
              padding: const EdgeInsets.all(16),
              isInteractive: true,
              onTap: () => context.push('/subscriptions'),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.cardYellow.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        sub.category.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          DateFormat('dd MMM').format(sub.nextRenewalDate),
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: daysLeft <= 2
                          ? AppColors.primary
                          : AppColors.cardYellow,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Text(
                      daysLeft <= 0 ? 'TODAY' : '${daysLeft}d',
                      style: TextStyle(
                        fontSize: 12,
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
      padding: const EdgeInsets.all(20),
      isInteractive: !isComingSoon,
      onTap: isComingSoon ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              if (badgeCount != null && badgeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              if (isComingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SOON',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isComingSoon
                  ? AppColors.textLight
                  : AppColors.textDark,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
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
