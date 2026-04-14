import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INSIGHTS / STATS'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: const [
          _SummaryCardsGrid(),
          Gap(40),
          Text('FINANCIAL BREAKDOWN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Gap(16),
          _BreakdownChart(),
          Gap(40),
          Text('YOUR CASH FLOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Gap(16),
          _CashFlowBarChart(),
          Gap(80),
        ],
      ),
    );
  }
}

class _SummaryCardsGrid extends ConsumerWidget {
  const _SummaryCardsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (error, stack) => '',
    );

    return Row(
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
                      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 2), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(LucideIcons.flame, color: AppColors.textDark),
                    ),
                    const Gap(16),
                    const Text('MONTHLY BURN', style: TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Gap(4),
                    FittedBox(
                      child: Text('${NumberFormat.compact().format(total)} $currency', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
                    ),
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
              final totalSaved = list.fold<double>(0, (sum, i) => sum + i.savedAmount);
              return NeoCard(
                backgroundColor: AppColors.cardBlue,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 2), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(LucideIcons.piggyBank, color: AppColors.textDark),
                    ),
                    const Gap(16),
                    const Text('TOTAL SAVED', style: TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Gap(4),
                    FittedBox(
                      child: Text('${NumberFormat.compact().format(totalSaved)} $currency', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
                    ),
                  ],
                ),
              ).animate().slideX(begin: 0.2, curve: Curves.easeOutBack, delay: 100.ms);
            },
            loading: () => const SizedBox(),
            error: (e, _) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}

class _BreakdownChart extends ConsumerWidget {
  const _BreakdownChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final goalsAsync = ref.watch(goalsProvider);

    return NeoCard(
      backgroundColor: AppColors.white,
      padding: const EdgeInsets.all(24),
      child: commitmentsAsync.when(
        data: (commitments) => goalsAsync.when(
          data: (goals) {
            final totalCommitments = commitments.fold<double>(0, (sum, i) => sum + i.amount);
            final totalSaved = goals.fold<double>(0, (sum, i) => sum + i.savedAmount);
            final remainingInGoals = goals.fold<double>(0, (sum, i) => sum + (max(0, i.targetAmount - i.savedAmount)));

            if (totalCommitments == 0 && totalSaved == 0 && remainingInGoals == 0) {
              return const SizedBox(
                height: 200, 
                child: Center(child: Text("NOT ENOUGH DATA", style: TextStyle(fontWeight: FontWeight.w900)))
              );
            }

            return SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: [
                        if (totalCommitments > 0)
                          PieChartSectionData(color: AppColors.primary, value: totalCommitments, title: '', radius: 30),
                        if (totalSaved > 0)
                          PieChartSectionData(color: AppColors.secondary, value: totalSaved, title: '', radius: 35),
                        if (remainingInGoals > 0)
                          PieChartSectionData(color: AppColors.cardYellow, value: remainingInGoals, title: '', radius: 25),
                      ],
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendItem(color: AppColors.primary, label: 'PAYMENTS'),
                      const Gap(4),
                      _LegendItem(color: AppColors.secondary, label: 'SAVED'),
                      const Gap(4),
                      _LegendItem(color: AppColors.cardYellow, label: 'GOALS LEFT'),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (error, stack) => const SizedBox(height: 200),
        ),
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (error, stack) => const SizedBox(height: 200),
      ),
    ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack, delay: 200.ms);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, border: Border.all(color: AppColors.border, width: 2), shape: BoxShape.circle),
        ),
        const Gap(6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _CashFlowBarChart extends ConsumerWidget {
  const _CashFlowBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeoCard(
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.only(top: 32, bottom: 16, left: 16, right: 24),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    const titles = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(titles[value.toInt()], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: AppColors.white.withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
            ),
            barGroups: [
              _makeGroupData(0, 45),
              _makeGroupData(1, 30),
              _makeGroupData(2, 60),
              _makeGroupData(3, 80),
              _makeGroupData(4, 50),
              _makeGroupData(5, 90),
            ],
          ),
        ).animate().slideY(begin: 0.5, curve: Curves.easeOutBack, delay: 300.ms),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.cardYellow,
          width: 16,
          borderSide: const BorderSide(color: AppColors.textDark, width: 2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
