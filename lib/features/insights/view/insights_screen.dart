import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'dart:math';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        children: [
          const _SummaryCardsGrid(),
          Gap(24.h),
          Text(
            'Financial Breakdown',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.textDark,
            ),
          ),
          Gap(12.h),
          const _BreakdownChart(),
          Gap(24.h),
          Text(
            'Your Cash Flow',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: AppColors.textDark,
            ),
          ),
          Gap(12.h),
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

    return goalsAsync.when(
      data: (list) {
        final totalSaved = list.fold<double>(0, (sum, i) => sum + i.savedAmount);
        final totalTarget = list.fold<double>(0, (sum, i) => sum + i.targetAmount);
        final remaining = max(0.0, totalTarget - totalSaved);

        return Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
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
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(LucideIcons.piggyBank, color: AppColors.success, size: 20.r),
                    ),
                    Gap(12.h),
                    Text(
                      'Total Saved',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(2.h),
                    FittedBox(
                      child: Text(
                        '${NumberFormat.compact().format(totalSaved)} $currency',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
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
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(LucideIcons.target, color: AppColors.zinc600, size: 20.r),
                    ),
                    Gap(12.h),
                    Text(
                      'Goals Remaining',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(2.h),
                    FittedBox(
                      child: Text(
                        '${NumberFormat.compact().format(remaining)} $currency',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn();
      },
      loading: () => const SizedBox(),
      error: (e, _) => const SizedBox(),
    );
  }
}

class _BreakdownChart extends ConsumerWidget {
  const _BreakdownChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: goalsAsync.when(
        data: (goals) {
          final totalSaved = goals.fold<double>(0, (sum, i) => sum + i.savedAmount);
          final remainingInGoals = goals.fold<double>(0, (sum, i) => sum + (max(0, i.targetAmount - i.savedAmount)));

          if (totalSaved == 0 && remainingInGoals == 0) {
            return SizedBox(
              height: 160.h,
              child: Center(
                child: Text(
                  "Not enough data",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 200.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3.r,
                    centerSpaceRadius: 55.r,
                    sections: [
                      if (totalSaved > 0)
                        PieChartSectionData(
                          color: AppColors.primary,
                          value: totalSaved,
                          title: '',
                          radius: 28.r,
                        ),
                      if (remainingInGoals > 0)
                        PieChartSectionData(
                          color: AppColors.zinc200,
                          value: remainingInGoals,
                          title: '',
                          radius: 22.r,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LegendItem(color: AppColors.primary, label: 'Saved'),
                    Gap(4.h),
                    const _LegendItem(color: AppColors.zinc300, label: 'Goals Left'),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => SizedBox(height: 160.h, child: const Center(child: CircularProgressIndicator())),
        error: (error, stack) => SizedBox(height: 160.h),
      ),
    );
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
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Gap(6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _CashFlowBarChart extends ConsumerWidget {
  const _CashFlowBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SizedBox(
        height: 200.h,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26.h,
                  getTitlesWidget: (value, meta) {
                    const titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          titles[value.toInt()],
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                        ),
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
                color: AppColors.border,
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
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: x == 5 ? AppColors.primary : AppColors.zinc300,
          width: 18.w,
          borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
        ),
      ],
    );
  }
}
