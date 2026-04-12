import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('INSIGHTS')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Row(
            children: [
              Expanded(
                child: commitmentsAsync.when(
                  data: (list) {
                    final total = list.fold<double>(0, (sum, i) => sum + i.amount);
                    return NeoCard(
                      backgroundColor: AppColors.cardYellow,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: AppColors.border, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.banknote, color: AppColors.textDark),
                          ),
                          const Gap(16),
                          const Text('COMMITMENTS', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const Gap(4),
                          Text(NumberFormat.compact().format(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
                        ],
                      ),
                    ).animate().slideX(begin: -0.2, curve: Curves.easeOutBack);
                  },
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                ),
              ),
              const Gap(16),
              Expanded(
                child: goalsAsync.when(
                  data: (list) {
                    final totalTarget = list.fold<double>(0, (sum, i) => sum + i.targetAmount);
                    return NeoCard(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(color: AppColors.border, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.target, color: AppColors.textDark),
                          ),
                          const Gap(16),
                          const Text('TOTAL GOALS', style: TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const Gap(4),
                          Text(NumberFormat.compact().format(totalTarget), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
                        ],
                      ),
                    ).animate().slideX(begin: 0.2, curve: Curves.easeOutBack);
                  },
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                ),
              ),
            ],
          ),
          const Gap(40),
          const Text('SPENDING RHYTHM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)).animate().fadeIn(delay: 200.ms),
          const Gap(16),
          NeoCard(
            backgroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              height: 250,
              child: commitmentsAsync.when(
                data: (commitments) {
                   if (commitments.isEmpty) return const Center(child: Text('NO DATA', style: TextStyle(fontWeight: FontWeight.w900)));
                   
                   // Custom animated Neo-Bar Chart
                   return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNeoBar('JAN', 0.4, AppColors.primary, 0),
                        _buildNeoBar('FEB', 0.6, AppColors.cardBlue, 1),
                        _buildNeoBar('MAR', 0.9, AppColors.cardYellow, 2),
                        _buildNeoBar('APR', 0.3, AppColors.secondary, 3),
                        _buildNeoBar('MAY', 0.7, AppColors.primary, 4),
                      ],
                   );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const SizedBox(),
              ),
            ),
          ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack, delay: 200.ms)
        ],
      ),
    );
  }

  Widget _buildNeoBar(String label, double heightFactor, Color color, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ).animate()
               .scaleY(begin: 0, alignment: Alignment.bottomCenter, duration: 600.ms, curve: Curves.easeOutBack, delay: (index * 100).ms),
            ),
          ),
        ),
        const Gap(12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
      ],
    );
  }
}
