import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // Header
            Row(
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
                    const Text(
                      'Planner ✌️',
                      style: TextStyle(
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
            ),
            const Gap(40),

            // Summary Card
            commitmentsAsync.when(
              data: (commitments) {
                final totalMonthly = commitments.fold<double>(0, (sum, item) => sum + item.amount);
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
                            'Total Commitments',
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
                            style: const TextStyle(color: AppColors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
                          ),
                          const Gap(8),
                          const Text(
                            'EGP',
                            style: TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const Gap(24),
                      settingsAsync.when(
                        data: (settings) {
                          final income = settings.monthlyIncome ?? 0;
                          final remaining = income - totalMonthly;
                          return Row(
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
                                      Text('${NumberFormat.compact().format(remaining)} EGP', style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.w900)),
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
                                      Text('${NumberFormat.compact().format(income)} EGP', style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack).fadeIn();
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err'),
            ),
            const Gap(40),

            // Upcoming Commitments
            const Text(
              'YOUR PAYMENTS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1),
            ).animate().fadeIn(delay: 200.ms),
            const Gap(20),
            commitmentsAsync.when(
              data: (commitments) {
                if (commitments.isEmpty) {
                  return const NeoCard(child: Center(child: Text('NO DATA YET', style: TextStyle(fontWeight: FontWeight.w900))));
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
                        onLongPress: () => _confirmDeletion(context, 'PAYMENT', item.title, () {
                          ref.read(commitmentsProvider.notifier).removeCommitment(item.id);
                        }),
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
                              Text(
                                NumberFormat.decimalPattern().format(item.amount),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
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
            const Gap(24),

            // Goals Progress
            const Text(
              'SAVINGS GOALS',
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1),
            ).animate().fadeIn(delay: 400.ms),
            const Gap(20),
             goalsAsync.when(
              data: (goals) {
                if (goals.isEmpty) {
                  return const NeoCard(child: Center(child: Text('NO GOALS YET', style: TextStyle(fontWeight: FontWeight.w900))));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: goals.length,
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final progress = goal.targetAmount > 0 ? (goal.savedAmount / goal.targetAmount) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onLongPress: () => _confirmDeletion(context, 'GOAL', goal.title, () {
                          ref.read(goalsProvider.notifier).removeGoal(goal.id);
                        }),
                        child: NeoCard(
                          backgroundColor: AppColors.cardBlue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(goal.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
                              Text('${NumberFormat.decimalPattern().format(goal.savedAmount)} / ${NumberFormat.decimalPattern().format(goal.targetAmount)} EGP', style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold)),
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
                                    onPressed: () => _addProgressDialog(context, ref, goal.id, goal.title),
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
            const Gap(80),
          ],
        ),
      ),
    );
  }

  void _addProgressDialog(BuildContext context, WidgetRef ref, String id, String title) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border, width: 3)),
        title: Text('ADD FUNDS TO $title', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Amount', suffixText: 'EGP'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              ref.read(goalsProvider.notifier).updateGoalProgress(id, val);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border, width: 2)),
            ),
            child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(BuildContext context, String type, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border, width: 3)),
        title: Text('DELETE $type?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text('Are you sure you want to remove "$title"?', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border, width: 2)),
            ),
            child: const Text('YES, DELETE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
