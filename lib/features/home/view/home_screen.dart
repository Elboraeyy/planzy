import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
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
import 'package:planzy/core/widgets/neo_date_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          children: [
            const _HomeHeaderWidget(),
            Gap(32.h),
            const _FinancialDashboard(),
            Gap(32.h),
            const _CommitmentsListWidget(),
            Gap(24.h),
            const _GoalsProgressWidget(),
            Gap(80.h),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────────

class _HomeHeaderWidget extends ConsumerWidget {
  const _HomeHeaderWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final userName = settingsAsync.when(
      data: (settings) =>
          settings.userName.isNotEmpty ? settings.userName : 'Planner',
      loading: () => 'Planner',
      error: (_, _) => 'Planner',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$userName ✌️',
              style: TextStyle(
                fontSize: 32.sp,
                color: AppColors.textDark,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ).animate().shimmer(duration: 2.seconds, color: AppColors.secondary),
          ],
        ),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.cardYellow,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border, width: 3.r),
            boxShadow: [
              BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h)),
            ]
          ),
          child: Icon(LucideIcons.bell, color: AppColors.textDark, size: 24.r),
        ).animate().slideX(begin: 1, curve: Curves.easeOutBack).rotate(begin: 0.1),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Financial Dashboard — Swipeable month card + day scroller + feed
// ──────────────────────────────────────────────────────────────

class _FinancialDashboard extends ConsumerStatefulWidget {
  const _FinancialDashboard();

  @override
  ConsumerState<_FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends ConsumerState<_FinancialDashboard> {
  late PageController _pageController;
  late ScrollController _dayScrollController;
  late DateTime _selectedMonth;
  late DateTime _selectedDay;
  bool _hasInitScrolled = false;

  // We allow swiping from 3 years ago to current month
  static const int _totalMonths = 36;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _pageController = PageController(initialPage: _totalMonths - 1);
    _dayScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayScrollController.dispose();
    super.dispose();
  }

  DateTime _monthFromPageIndex(int index) {
    final now = DateTime.now();
    final currentMonthIndex = _totalMonths - 1;
    final diff = currentMonthIndex - index;
    return DateTime(now.year, now.month - diff);
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final daysCount = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(daysCount, (i) => DateTime(month.year, month.month, i + 1));
  }

  void _scrollToDay(DateTime day, List<DateTime> days) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dayScrollController.hasClients) return;
      final index = days.indexWhere((d) => d.day == day.day);
      if (index < 0) return;
      final target = (index * 68.w) - (MediaQuery.of(context).size.width / 2 - 58.w);
      _dayScrollController.animateTo(
        target.clamp(0.0, _dayScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
      );
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await NeoDatePicker.show(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(now.year - 3, now.month),
      lastDate: now,
    );

    if (picked != null) {
      final diff = (now.year - picked.year) * 12 + now.month - picked.month;
      final targetIndex = (_totalMonths - 1) - diff;
      
      if (targetIndex >= 0 && targetIndex < _totalMonths) {
        setState(() {
          _selectedDay = picked;
          _selectedMonth = DateTime(picked.year, picked.month);
        });
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _scrollToDay(_selectedDay, _daysInMonth(_selectedMonth));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final commitmentsAsync = ref.watch(commitmentsProvider);

    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (_, _) => '',
    );

    final allTransactions = transactionsAsync.valueOrNull ?? [];

    // Month stats
    final monthTransactions = allTransactions.where((t) =>
      t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month
    ).toList();

    double monthIncome = 0;
    double monthExpense = 0;
    for (final t in monthTransactions) {
      if (t.type == TransactionType.income) {
        monthIncome += t.amount;
      } else {
        monthExpense += t.amount;
      }
    }
    final balance = monthIncome - monthExpense;

    // Day transactions
    final dayTransactions = allTransactions.where((t) =>
      t.date.year == _selectedDay.year &&
      t.date.month == _selectedDay.month &&
      t.date.day == _selectedDay.day
    ).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final days = _daysInMonth(_selectedMonth);
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    // Auto-scroll to current day on first build
    if (!_hasInitScrolled) {
      _hasInitScrolled = true;
      _scrollToDay(_selectedDay, days);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════
        // THE RED CARD — Swipeable month summary
        // ═══════════════════════════════════════════════
        SizedBox(
          height: 310.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalMonths,
            onPageChanged: (index) {
              final newMonth = _monthFromPageIndex(index);
              setState(() {
                _selectedMonth = newMonth;
                // Preserve the currently selected day number, clamped to the new month's length
                final maxDaysInNewMonth = DateUtils.getDaysInMonth(newMonth.year, newMonth.month);
                final targetDay = _selectedDay.day.clamp(1, maxDaysInNewMonth);
                
                final now = DateTime.now();
                if (newMonth.year == now.year && newMonth.month == now.month && targetDay > now.day) {
                  _selectedDay = DateTime(now.year, now.month, now.day);
                } else {
                  _selectedDay = DateTime(newMonth.year, newMonth.month, targetDay);
                }
              });
              _scrollToDay(_selectedDay, _daysInMonth(_monthFromPageIndex(index)));
            },
            itemBuilder: (context, index) {
              return _buildMonthCard(
                month: _monthFromPageIndex(index),
                balance: balance,
                income: monthIncome,
                expense: monthExpense,
                currency: currency,
                commitments: commitmentsAsync.valueOrNull ?? [],
                index: index,
              );
            },
          ),
        ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack).fadeIn(),

        Gap(20.h),

        // ═══════════════════════════════════════════════
        // DAY SCROLLER
        // ═══════════════════════════════════════════════
        SizedBox(
          height: 72.h,
          child: ListView.builder(
            controller: _dayScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = day.day == _selectedDay.day;
              final isToday = isCurrentMonth && day.day == now.day;
              final dayName = DateFormat('E').format(day).toUpperCase().substring(0, 2);
              
              // Check if this day has transactions
              final hasTx = allTransactions.any((t) =>
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day
              );

              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = day);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    width: 58.w,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.secondary.withValues(alpha: 0.3)
                              : AppColors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? AppColors.border : AppColors.border.withValues(alpha: 0.15),
                        width: isSelected ? 3.r : 2.r,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? AppColors.white.withValues(alpha: 0.7) : AppColors.textLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Gap(4.h),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                        if (hasTx && !isSelected) ...[
                          Gap(2.h),
                          Container(
                            width: 6.r, height: 6.r,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 200.ms),

        Gap(24.h),

        // ═══════════════════════════════════════════════
        // DAY TRANSACTIONS FEED
        // ═══════════════════════════════════════════════
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, d MMM').format(_selectedDay).toUpperCase(),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
            ),
            if (dayTransactions.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.border, width: 2.r),
                ),
                child: Text(
                  '${dayTransactions.length} item${dayTransactions.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 300.ms),
        Gap(16.h),

        if (dayTransactions.isEmpty)
          NeoCard(
            backgroundColor: AppColors.white,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  children: [
                    Text('📭', style: TextStyle(fontSize: 32.sp)),
                    Gap(8.h),
                    Text(
                      'NO ACTIVITY ON ${DateFormat('MMMM d').format(_selectedDay).toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, fontSize: 13.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayTransactions.length,
            itemBuilder: (context, index) {
              final t = dayTransactions[index];
              final isExpense = t.type == TransactionType.expense;
              final emoji = isExpense
                  ? (t.expenseCategory?.icon ?? '💸')
                  : (t.incomeSource?.icon ?? '💰');
              final categoryName = isExpense
                  ? (t.expenseCategory?.displayName ?? 'Expense')
                  : (t.incomeSource?.displayName ?? 'Income');

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: NeoCard(
                  backgroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      Container(
                        width: 44.r, height: 44.r,
                        decoration: BoxDecoration(
                          color: isExpense
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.1), width: 2.r),
                        ),
                        child: Center(child: Text(emoji, style: TextStyle(fontSize: 20.sp))),
                      ),
                      Gap(14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: -0.3),
                            ),
                            Gap(2.h),
                            Text(
                              DateFormat('HH:mm').format(t.date),
                              style: TextStyle(color: AppColors.textLight, fontSize: 11.sp, fontWeight: FontWeight.w600),
                            ),
                            if (t.notes != null && t.notes!.isNotEmpty) ...[
                              Gap(2.h),
                              Text(
                                t.notes!,
                                style: TextStyle(color: AppColors.textLight, fontSize: 11.sp),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isExpense ? '-' : '+'}${NumberFormat.compact().format(t.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18.sp,
                              color: isExpense ? AppColors.primary : const Color(0xFF2E7D32),
                            ),
                          ),
                          Text(currency, style: TextStyle(color: AppColors.textLight, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate()
                  .slideX(begin: 0.1, delay: (50 * index).ms, curve: Curves.easeOutBack)
                  .fadeIn();
            },
          ),
      ],
    );
  }

  Widget _buildMonthCard({
    required DateTime month,
    required double balance,
    required double income,
    required double expense,
    required String currency,
    required List<dynamic> commitments,
    required int index,
  }) {
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border, width: 3.r),
        boxShadow: [
          BoxShadow(color: AppColors.border, offset: Offset(6.w, 6.h)),
        ],
      ),
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Month + Day + Year
          GestureDetector(
            onTap: _pickDate,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Text(
                      DateFormat('MMMM').format(month).toUpperCase(),
                      style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 13.sp, letterSpacing: 0.5),
                    ),
                  ),
                  Gap(8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Text(
                      '${month.year}',
                      style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
              if (isCurrentMonth)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.cardYellow,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border, width: 2.r),

                    ),
                    child: Text(
                      DateFormat('E, d').format(now).toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
          ),
          
          Gap(16.h),

          // Balance
          Text(
            'BALANCE',
            style: TextStyle(color: Colors.white60, fontSize: 11.sp, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          Gap(4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormat.decimalPattern().format(balance),
                    style: TextStyle(color: AppColors.white, fontSize: 40.sp, fontWeight: FontWeight.w900, letterSpacing: -2),
                  ),
                ),
              ),
              Gap(8.w),
              Text(
                currency,
                style: TextStyle(color: AppColors.cardYellow, fontSize: 22.sp, fontWeight: FontWeight.w900),
              ),
            ],
          ),

          Gap(16.h),

          // Income & Expense row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 2.r),
                    boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.r, height: 8.r,
                            decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                          ),
                          Gap(6.w),
                          Text('INCOME', style: TextStyle(color: AppColors.textLight, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      Gap(6.h),
                      FittedBox(
                        child: Text(
                          '+${NumberFormat.compact().format(income)} $currency',
                          style: TextStyle(color: const Color(0xFF2E7D32), fontSize: 17.sp, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 2.r),
                    boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.r, height: 8.r,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                          Gap(6.w),
                          Text('EXPENSE', style: TextStyle(color: AppColors.textLight, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      Gap(6.h),
                      FittedBox(
                        child: Text(
                          '-${NumberFormat.compact().format(expense)} $currency',
                          style: TextStyle(color: AppColors.primary, fontSize: 17.sp, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Swipe hint & Buttons
          Gap(8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (index > 0)
                GestureDetector(
                  onTap: () {
                    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(LucideIcons.chevronLeft, size: 16.r, color: AppColors.white),
                  ),
                )
              else
                SizedBox(width: 24.w),
                
              Text(
                'SWIPE FOR MONTHS',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.5), fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),

              if (index < _FinancialDashboardState._totalMonths - 1)
                GestureDetector(
                  onTap: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(LucideIcons.chevronRight, size: 16.r, color: AppColors.white),
                  ),
                )
              else
                SizedBox(width: 24.w),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Commitments (Payments) List
// ──────────────────────────────────────────────────────────────

class _CommitmentsListWidget extends ConsumerWidget {
  const _CommitmentsListWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (settings) => settings.currency,
      loading: () => '',
      error: (_, _) => '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR PAYMENTS',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1),
        ).animate().fadeIn(delay: 200.ms),
        Gap(20.h),
        commitmentsAsync.when(
          data: (commitments) {
            if (commitments.isEmpty) {
              return NeoCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Text('NO DATA YET', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, fontSize: 13.sp)),
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
                  padding: EdgeInsets.only(bottom: 16.h),
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
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.border, width: 2.r),
                            ),
                            child: Icon(LucideIcons.zap, color: AppColors.textDark, size: 24.r),
                          ),
                          Gap(16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp, letterSpacing: -0.5)),
                                Gap(4.h),
                                Text(item.repeatType.name.toUpperCase(), style: TextStyle(color: AppColors.textLight, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                NumberFormat.decimalPattern().format(item.amount),
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20.sp),
                              ),
                              Text(currency, style: TextStyle(color: AppColors.textLight, fontSize: 12.sp, fontWeight: FontWeight.bold)),
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

// ──────────────────────────────────────────────────────────────
// Goals Progress
// ──────────────────────────────────────────────────────────────

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
        Text(
          'SAVINGS GOALS',
           style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1),
        ).animate().fadeIn(delay: 400.ms),
        Gap(20.h),
        goalsAsync.when(
          data: (goals) {
            if (goals.isEmpty) {
              return NeoCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Text('NO GOALS YET', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, fontSize: 13.sp)),
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
                  padding: EdgeInsets.only(bottom: 16.h),
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
                                child: Text(goal.title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp), overflow: TextOverflow.ellipsis),
                              ),
                              Gap(8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.textDark,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%', 
                                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 14.sp)
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          Text('${NumberFormat.decimalPattern().format(goal.savedAmount)} / ${NumberFormat.decimalPattern().format(goal.targetAmount)} $currency', style: TextStyle(color: AppColors.textDark, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                          Gap(16.h),
                          Container(
                            height: 16.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.border, width: 2.r),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border(right: BorderSide(color: AppColors.border, width: 2.r))
                                ),
                              ),
                            ).animate().scaleX(begin: 0, duration: 600.ms, curve: Curves.easeOutBack),
                          ),
                          Gap(16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showAddFundsDialog(context, ref, goal.id, goal.title, currency),
                                icon: Icon(LucideIcons.plus, size: 16.r, color: AppColors.textDark),
                                label: Text('ADD FUNDS', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 12.sp)),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide(color: AppColors.border, width: 2.r)),
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
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: currency,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.border, width: 3.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 3.r),
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
