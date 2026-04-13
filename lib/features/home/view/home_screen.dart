import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:planzy/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:planzy/core/widgets/neo_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: const [
            _HomeHeaderWidget(),
            Gap(40),
            _HomeSummaryCard(),
            Gap(40),
            _TransactionsSummaryCard(),
            Gap(40),
            _CommitmentsListWidget(),
            Gap(24),
            _GoalsProgressWidget(),
            Gap(80),
          ],
        ),
      ),
    );
  }
}

class _HomeHeaderWidget extends ConsumerWidget {
  const _HomeHeaderWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final userName = settingsAsync.when(
      data: (settings) => (settings.userName?.isNotEmpty == true) ? settings.userName! : 'Planner',
      loading: () => 'Planner',
      error: (_, _) => 'Planner',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello,',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$userName ✌️',
              style: const TextStyle(
                fontSize: 32,
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ).animate().shimmer(duration: 2.seconds, color: AppColors.secondary),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardYellow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 3),
            boxShadow: const [
              BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
            ]
          ),
          child: const Icon(LucideIcons.bell, color: AppColors.textDark),
        ).animate().slideX(begin: 1, curve: Curves.easeOutBack).rotate(begin: 0.1),
      ],
    );
  }
}

class _TransactionsSummaryCard extends ConsumerWidget {
  const _TransactionsSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final monthlyStats = ref.watch(monthlyStatsProvider);
    final todayTransactions = ref.watch(todayTransactionsProvider);

    return settingsAsync.when(
      data: (settings) {
        final currency = settings.currency;

        return transactionsAsync.when(
          data: (_) {
            return GestureDetector(
              onTap: () => context.push('/transaction-history'),
              child: NeoCard(
                backgroundColor: AppColors.cardYellow,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'THIS MONTH',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: monthlyStats['balance']! >= 0
                                ? AppColors.secondary
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          child: Text(
                            monthlyStats['balance']! >= 0 ? 'SAVING' : 'OVERSPENT',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: _TransactionStat(
                            label: 'SPENT',
                            amount: monthlyStats['expenses']!,
                            currency: currency,
                            icon: '💸',
                            color: AppColors.primary,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _TransactionStat(
                            label: 'EARNED',
                            amount: monthlyStats['income']!,
                            currency: currency,
                            icon: '💰',
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    if (todayTransactions.isNotEmpty) ...[
                      const Gap(16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Text('📅', style: TextStyle(fontSize: 20)),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                'Today: ${todayTransactions.length} transaction${todayTransactions.length > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${todayTransactions.where((t) => t.type == TransactionType.expense).fold<double>(0, (sum, t) => sum + t.amount).toStringAsFixed(0)} $currency',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'VIEW ALL →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: AppColors.textDark.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack).fadeIn(),
            );
          },
          loading: () => const NeoCard(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _TransactionStat extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final String icon;
  final Color color;

  const _TransactionStat({
    required this.label,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const Gap(6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const Gap(6),
          FittedBox(
            child: Text(
              '${NumberFormat.compact().format(amount)} $currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSummaryCard extends ConsumerWidget {
  const _HomeSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return commitmentsAsync.when(
      data: (commitments) {
        final totalMonthly = commitments.fold<double>(0, (sum, item) => sum + item.amount);
        
        return settingsAsync.when(
          data: (settings) {
            final currency = settings.currency;
            final income = settings.monthlyIncome ?? 0;
            final remaining = income - totalMonthly;
            
            return NeoCard(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL COMMITMENTS',
                        style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Text(
                          DateFormat('MMM').format(DateTime.now()).toUpperCase(),
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900),
                        ),
                      )
                    ],
                  ),
                  const Gap(12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        NumberFormat.decimalPattern().format(totalMonthly),
                        style: const TextStyle(color: AppColors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -2),
                      ),
                      const Gap(8),
                      Text(
                        currency,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('REMAINING', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const Gap(4),
                              FittedBox(
                                child: Text('${NumberFormat.compact().format(remaining)} $currency', style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.textDark.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('INCOME', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const Gap(4),
                              FittedBox(
                                child: Text('${NumberFormat.compact().format(income)} $currency', style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack).fadeIn();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}

class _CommitmentsListWidget extends ConsumerWidget {
  const _CommitmentsListWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (_, _) => '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR PAYMENTS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1),
        ).animate().fadeIn(delay: 200.ms),
        const Gap(20),
        commitmentsAsync.when(
          data: (commitments) {
            if (commitments.isEmpty) {
              return NeoCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('NO DATA YET', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight)),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commitments.length,
              itemBuilder: (context, index) {
                final item = commitments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onLongPress: () => NeoDialog.show(
                      context: context,
                      title: 'DELETE PAYMENT?',
                      message: 'Are you sure you want to remove "${item.title}"?',
                      confirmText: 'YES, DELETE',
                      cancelText: 'NO, KEEP IT',
                      isDestructive: true,
                      onConfirm: () {
                        ref.read(commitmentsProvider.notifier).removeCommitment(item.id);
                      },
                    ),
                    child: NeoCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border, width: 2),
                            ),
                            child: const Icon(LucideIcons.zap, color: AppColors.textDark),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                                const Gap(4),
                                Text(item.repeatType.name.toUpperCase(), style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.decimalPattern().format(item.amount),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                              ),
                              Text(currency, style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                   .slideX(begin: 0.2, delay: (100 * index).ms, curve: Curves.easeOutBack)
                   .fadeIn(),
                );
              },
            );
          },
          loading: () => const SizedBox(),
          error: (err, _) => const SizedBox(),
        ),
      ],
    );
  }
}

class _GoalsProgressWidget extends ConsumerWidget {
  const _GoalsProgressWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (_, _) => '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SAVINGS GOALS',
           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1),
        ).animate().fadeIn(delay: 400.ms),
        const Gap(20),
        goalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return NeoCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('NO GOALS YET', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight)),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onLongPress: () => NeoDialog.show(
                      context: context,
                      title: 'DELETE GOAL?',
                      message: 'Are you sure you want to remove "${goal.title}"?',
                      confirmText: 'YES, DELETE',
                      cancelText: 'NO, KEEP IT',
                      isDestructive: true,
                      onConfirm: () {
                        ref.read(goalsProvider.notifier).removeGoal(goal.id);
                      },
                    ),
                    child: NeoCard(
                      backgroundColor: AppColors.cardBlue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(goal.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18), overflow: TextOverflow.ellipsis),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.textDark,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%', 
                                  style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 14)
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          Text('${NumberFormat.decimalPattern().format(goal.savedAmount)} / ${NumberFormat.decimalPattern().format(goal.targetAmount)} $currency', style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold)),
                          const Gap(16),
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border, width: 2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(6),
                                  border: const Border(right: BorderSide(color: AppColors.border, width: 2))
                                ),
                              ),
                            ).animate().scaleX(begin: 0, duration: 600.ms, curve: Curves.easeOutBack),
                          ),
                          const Gap(16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showAddFundsDialog(context, ref, goal.id, goal.title, currency),
                                icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.textDark),
                                label: const Text('ADD FUNDS', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border, width: 2)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                   .slideY(begin: 0.2, delay: (200 + (100 * index)).ms, curve: Curves.elasticOut)
                   .fadeIn(),
                );
              },
            );
          },
          loading: () => const SizedBox(),
          error: (err, _) => const SizedBox(),
        ),
      ],
    );
  }

  void _showAddFundsDialog(BuildContext context, WidgetRef ref, String id, String title, String currency) {
    final controller = TextEditingController();
    
    NeoDialog.show(
      context: context,
      title: 'FUND GOAL',
      message: 'Add funds to $title',
      confirmText: 'ADD FUNDS',
      cancelText: 'CANCEL',
      customContent: Column(
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: currency,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border, width: 3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 3),
              ),
            ),
            autofocus: true,
          ),
        ],
      ),
      onConfirm: () {
        final val = double.tryParse(controller.text) ?? 0;
        ref.read(goalsProvider.notifier).updateGoalProgress(id, val);
      },
    );
  }
}
