import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';

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
        title: Text('INSIGHTS / STATS', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        children: [
          const _SummaryCardsGrid(),
          Gap(40.h),
          Text('FINANCIAL BREAKDOWN', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Gap(16.h),
          const _BreakdownChart(),
          Gap(40.h),
          Text('YOUR CASH FLOW', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Gap(16.h),
          const _CashFlowBarChart(),
          Gap(80.h),
        ],
      ),
    );
  }
}

class _SummaryCardsGrid extends ConsumerWidget {
  const _SummaryCardsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (error, stack) => '',
    );

    return Row(
      children: [
        const Expanded(child: SizedBox()),
        Gap(16.w),
        Expanded(
          child: goalsAsync.when(
            data: (list) {
              final totalSaved = list.fold<double>(0, (sum, i) => sum + i.savedAmount);
              return NeoCard(
                backgroundColor: AppColors.cardBlue,
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(color: AppColors.white, border: Border.all(color: AppColors.border, width: 2.r), borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(LucideIcons.piggyBank, color: AppColors.textDark, size: 24.r),
                    ),
                    Gap(16.h),
                    Text('TOTAL SAVED', style: TextStyle(color: AppColors.textDark, fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Gap(4.h),
                    FittedBox(
                      child: Text('${NumberFormat.compact().format(totalSaved)} $currency', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, letterSpacing: -1)),
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
    final goalsAsync = ref.watch(goalsProvider);

    return NeoCard(
      backgroundColor: AppColors.white,
      padding: EdgeInsets.all(24.r),
      child: goalsAsync.when(
          data: (goals) {
            final totalSaved = goals.fold<double>(0, (sum, i) => sum + i.savedAmount);
            final remainingInGoals = goals.fold<double>(0, (sum, i) => sum + (max(0, i.targetAmount - i.savedAmount)));

            if (totalSaved == 0 && remainingInGoals == 0) {
              return SizedBox(
                height: 200.h, 
                child: Center(child: Text("NOT ENOUGH DATA", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)))
              );
            }

            return SizedBox(
              height: 240.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4.r,
                      centerSpaceRadius: 60.r,
                      sections: [

                        if (totalSaved > 0)
                          PieChartSectionData(color: AppColors.secondary, value: totalSaved, title: '', radius: 35.r),
                        if (remainingInGoals > 0)
                          PieChartSectionData(color: AppColors.cardYellow, value: remainingInGoals, title: '', radius: 25.r),
                      ],
                    ),
                  ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      _LegendItem(color: AppColors.secondary, label: 'SAVED'),
                      Gap(4.h),
                      _LegendItem(color: AppColors.cardYellow, label: 'GOALS LEFT'),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            );
          },
          loading: () => SizedBox(height: 200.h, child: const Center(child: CircularProgressIndicator())),
          error: (error, stack) => SizedBox(height: 200.h),
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
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, border: Border.all(color: AppColors.border, width: 2.r), shape: BoxShape.circle),
        ),
        Gap(6.w),
        Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900)),
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
      padding: EdgeInsets.only(top: 32.h, bottom: 16.h, left: 16.w, right: 24.w),
      child: SizedBox(
        height: 220.h,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30.h,
                  getTitlesWidget: (value, meta) {
                    const titles = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(titles[value.toInt()], style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w900, fontSize: 10.sp)),
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
                    strokeWidth: 1.r,
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
          width: 16.w,
          borderSide: BorderSide(color: AppColors.textDark, width: 2.r),
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        ),
      ],
    );
  }
}
