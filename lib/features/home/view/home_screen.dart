import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';

import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:planzy/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:intl/intl.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
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

enum DateRangeFilter {
  today('TODAY', '☀️'),
  thisMonth('THIS MONTH', '📅'),
  lastMonth('LAST MONTH', '⏪'),
  thisWeek('THIS WEEK', '📆'),
  lastWeek('LAST WEEK', '⏮️'),
  thisYear('THIS YEAR', '🗓️'),
  allTime('ALL TIME', '♾️'),
  custom('CUSTOM', '🎯');

  final String label;
  final String emoji;
  const DateRangeFilter(this.label, this.emoji);
}

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

  // Date range filter
  DateRangeFilter _activeFilter = DateRangeFilter.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

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
      final index = days.indexWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );
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

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedMonth = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
      _activeFilter = DateRangeFilter.thisMonth;
    });
    _pageController.animateToPage(
      _totalMonths - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutBack,
    );
    _scrollToDay(_selectedDay, _daysInMonth(_selectedMonth));
  }

  /// Get date range from the active filter relative to a reference month
  (DateTime, DateTime) _getFilterDateRange(DateTime referenceMonth) {
    final now = DateTime.now();
    final isCurrentMonth = referenceMonth.year == now.year && referenceMonth.month == now.month;

    switch (_activeFilter) {
      case DateRangeFilter.today:
        if (!isCurrentMonth) {
          // If not in current month, "today" doesn't make sense, default to full month or first day
          final start = DateTime(referenceMonth.year, referenceMonth.month, 1);
          final end = DateTime(referenceMonth.year, referenceMonth.month + 1, 0, 23, 59, 59);
          return (start, end);
        }
        final start = DateTime(now.year, now.month, now.day);
        return (start, now);
      case DateRangeFilter.thisWeek:
        if (!isCurrentMonth) {
          final start = DateTime(referenceMonth.year, referenceMonth.month, 1);
          final end = DateTime(referenceMonth.year, referenceMonth.month + 1, 0, 23, 59, 59);
          return (start, end);
        }
        final daysSinceSaturday = now.weekday % 7; // Sat=0, Sun=1, ... Fri=6
        final start = DateTime(
          now.year,
          now.month,
          now.day - daysSinceSaturday,
        );
        return (start, now);
      case DateRangeFilter.thisMonth:
        final start = DateTime(referenceMonth.year, referenceMonth.month, 1);
        final end = isCurrentMonth ? now : DateTime(referenceMonth.year, referenceMonth.month + 1, 0, 23, 59, 59);
        return (start, end);
      case DateRangeFilter.lastMonth:
        // Relative to now
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59);
        return (start, end);
      case DateRangeFilter.lastWeek:
        // Relative to now
        final daysSinceSaturday = now.weekday % 7; // Sat=0, Sun=1, ... Fri=6
        final start = DateTime(
          now.year,
          now.month,
          now.day - daysSinceSaturday - 7,
        );
        final end = DateTime(
          start.year,
          start.month,
          start.day + 6,
          23,
          59,
          59,
        );
        return (start, end);
      case DateRangeFilter.thisYear:
        final start = DateTime(now.year, 1, 1);
        return (start, now);
      case DateRangeFilter.allTime:
        final start = DateTime(2000, 1, 1);
        return (start, now);
      case DateRangeFilter.custom:
        return (
          _customStart ?? DateTime(now.year, now.month, 1),
          _customEnd ?? now,
        );
    }
  }

  DateTime _normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  void _applyFilterSelection(DateRangeFilter filter) {
    final previousFilter = _activeFilter;
    final previousCustomStart = _customStart;
    final previousCustomEnd = _customEnd;

    setState(() => _activeFilter = filter);

    final (rangeStart, rangeEnd) = _getFilterDateRange(_selectedMonth);
    final startDay = _normalizeDate(rangeStart);
    final endDay = _normalizeDate(rangeEnd);
    final today = _normalizeDate(DateTime.now());

    final transactions = ref.read(transactionsProvider).valueOrNull ?? [];
    final matchingDays =
        transactions
            .where(
              (t) => !t.date.isBefore(rangeStart) && !t.date.isAfter(rangeEnd),
            )
            .map((t) => _normalizeDate(t.date))
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    final bool todayInsideRange =
        !today.isBefore(startDay) && !today.isAfter(endDay);
    final DateTime targetDay = todayInsideRange
        ? today
        : (matchingDays.isNotEmpty ? matchingDays.first : startDay);

    setState(() {
      _selectedDay = targetDay;
      _selectedMonth = DateTime(targetDay.year, targetDay.month);
    });

    final now = DateTime.now();
    final diff =
        (now.year - targetDay.year) * 12 + now.month - targetDay.month;
    final targetIndex = (_totalMonths - 1) - diff;
    if (targetIndex >= 0 && targetIndex < _totalMonths) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }

    final daysList = <DateTime>[];
    var cursor = startDay;
    while (!cursor.isAfter(endDay)) {
      daysList.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }

    if (daysList.isNotEmpty) {
      _scrollToDay(targetDay, daysList);
    } else {
      setState(() {
        _activeFilter = previousFilter;
        _customStart = previousCustomStart;
        _customEnd = previousCustomEnd;
      });
    }
  }

  void _onFilterSelected(DateRangeFilter filter) {
    if (filter == DateRangeFilter.custom) {
      _showCustomRangePicker();
      return;
    }
    _applyFilterSelection(filter);
    Navigator.of(context).pop();
  }

  Future<void> _showCustomRangePicker() async {
    Navigator.of(context).pop(); // close the filter sheet first
    final now = DateTime.now();
    final startPicked = await NeoDatePicker.show(
      context: context,
      initialDate: _customStart ?? DateTime(now.year, now.month, 1),
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );
    if (startPicked == null || !mounted) return;

    final endPicked = await NeoDatePicker.show(
      context: context,
      initialDate: _customEnd ?? now,
      firstDate: startPicked,
      lastDate: now,
    );
    if (endPicked == null || !mounted) return;

    setState(() {
      _customStart = startPicked;
      _customEnd = endPicked;
    });
    _applyFilterSelection(DateRangeFilter.custom);
  }

  String _activeFilterDisplayText() {
    if (_activeFilter != DateRangeFilter.custom) {
      return _activeFilter.label;
    }

    final start = _customStart;
    final end = _customEnd;
    if (start == null || end == null) {
      return _activeFilter.label;
    }

    final sameYear = start.year == end.year;
    final startFormat = sameYear ? 'd MMM' : 'd MMM yy';
    const endFormat = 'd MMM yy';
    return '${DateFormat(startFormat).format(start)} - ${DateFormat(endFormat).format(end)}';
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        final mediaQuery = MediaQuery.of(ctx);
        final navBarClearance = mediaQuery.padding.bottom + 144.h;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 20.r),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: AppColors.border, width: 3.r),
                  boxShadow: [
                    BoxShadow(color: AppColors.border, offset: Offset(6.w, 6.h)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.filter,
                          size: 18.r,
                          color: AppColors.cardYellow,
                        ),
                        Gap(8.w),
                        Text(
                          'SHOW DATA FOR',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Gap(20.h),
                    // Grid of filter options
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: DateRangeFilter.values.map((filter) {
                        final isActive = _activeFilter == filter;
                        final isCustom = filter == DateRangeFilter.custom;
                        return GestureDetector(
                          onTap: () => _onFilterSelected(filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(
                              horizontal: isCustom ? 20.w : 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.secondary
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: AppColors.border,
                                width: isActive ? 3.r : 2.r,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.border,
                                  offset: Offset(
                                    isActive ? 4.w : 2.w,
                                    isActive ? 4.h : 2.h,
                                  ),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filter.emoji,
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                Gap(8.w),
                                Text(
                                  filter.label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (isActive) ...[
                                  Gap(6.w),
                                  Icon(
                                    LucideIcons.check,
                                    size: 15.r,
                                    color: AppColors.textDark,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Gap(8.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (_, _) => '',
    );

    final allTransactions = transactionsAsync.valueOrNull ?? [];

    // Filter transactions based on active date range filter
    // Filter transactions based on active date range filter relative to selected month
    final (filterStart, filterEnd) = _getFilterDateRange(_selectedMonth);
    final filteredTransactions = allTransactions.where((t) =>
      !t.date.isBefore(filterStart) && !t.date.isAfter(filterEnd)
    ).toList();

    // Stats for the active filter range
    double filteredIncome = 0;
    double filteredExpense = 0;
    for (final t in filteredTransactions) {
      if (t.type == TransactionType.income) {
        filteredIncome += t.amount;
      } else {
        filteredExpense += t.amount;
      }
    }


    // Day transactions (filtered by selected day)
    final dayTransactions = filteredTransactions.where((t) =>
      t.date.year == _selectedDay.year &&
      t.date.month == _selectedDay.month &&
      t.date.day == _selectedDay.day
    ).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Build days list based on filter range
    final bool isDefaultFilter = _activeFilter == DateRangeFilter.thisMonth;
    final List<DateTime> days;
    if (isDefaultFilter) {
      days = _daysInMonth(_selectedMonth);
    } else {
      // Generate all days within the filter range
      final daysList = <DateTime>[];
      var cursor = DateTime(filterStart.year, filterStart.month, filterStart.day);
      final endDay = DateTime(filterEnd.year, filterEnd.month, filterEnd.day);
      while (!cursor.isAfter(endDay)) {
        daysList.add(cursor);
        cursor = cursor.add(const Duration(days: 1));
      }
      days = daysList;
    }

    final now = DateTime.now();
    final isTodaySelected = _selectedDay.year == now.year &&
        _selectedDay.month == now.month &&
        _selectedDay.day == now.day;

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
          height: 320.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _totalMonths,
            onPageChanged: (index) {
              final newMonth = _monthFromPageIndex(index);
              final now = DateTime.now();
              final isMovingToOtherMonth = newMonth.year != now.year || newMonth.month != now.month;

              setState(() {
                _selectedMonth = newMonth;
                if (isMovingToOtherMonth) {
                  _activeFilter = DateRangeFilter.thisMonth;
                }
                
                // Preserve the currently selected day number, clamped to the new month's length
                final maxDaysInNewMonth = DateUtils.getDaysInMonth(newMonth.year, newMonth.month);
                final targetDay = _selectedDay.day.clamp(1, maxDaysInNewMonth);
                
                if (newMonth.year == now.year && newMonth.month == now.month && targetDay > now.day) {
                  _selectedDay = DateTime(now.year, now.month, now.day);
                } else {
                  _selectedDay = DateTime(newMonth.year, newMonth.month, targetDay);
                }
              });
              _scrollToDay(_selectedDay, _daysInMonth(_monthFromPageIndex(index)));
            },
            itemBuilder: (context, index) {
              final cardMonth = _monthFromPageIndex(index);
              final isCurrentMonthCard = cardMonth.year == now.year && cardMonth.month == now.month;
              final isSelectedCard = cardMonth.year == _selectedMonth.year && cardMonth.month == _selectedMonth.month;
              
              double cardIncome;
              double cardExpense;

              if (isSelectedCard) {
                // Use the filtered stats calculated in build() for the active card
                cardIncome = filteredIncome;
                cardExpense = filteredExpense;
              } else {
                // Calculate raw month stats (Full Month) for background cards
                final cardMonthStart = DateTime(cardMonth.year, cardMonth.month, 1);
                final cardMonthEnd = DateTime(cardMonth.year, cardMonth.month + 1, 0, 23, 59, 59);
                
                cardIncome = 0;
                cardExpense = 0;
                for (final t in allTransactions) {
                  if (!t.date.isBefore(cardMonthStart) && !t.date.isAfter(cardMonthEnd)) {
                    if (t.type == TransactionType.income) {
                      cardIncome += t.amount;
                    } else {
                      cardExpense += t.amount;
                    }
                  }
                }
              }

              return _buildMonthCard(
                month: cardMonth,
                balance: cardIncome - cardExpense,
                income: cardIncome,
                expense: cardExpense,
                currency: currency,
                index: index,
                showTodayButton: !isTodaySelected,
                onTodayPressed: _goToToday,
                activeFilter: _activeFilter,
                showFilterButton: isCurrentMonthCard,
                onFilterTap: _showFilterSheet,
              );
            },
          ),
        ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack).fadeIn(),

        if (_activeFilter != DateRangeFilter.today) ...[
          Gap(20.h),

          // ═══════════════════════════════════════════════
          // DAY SCROLLER
          // ═══════════════════════════════════════════════
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              controller: _dayScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day.year == _selectedDay.year &&
                    day.month == _selectedDay.month &&
                    day.day == _selectedDay.day;
                final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
                final dayName = DateFormat('E').format(day).toUpperCase().substring(0, 2);
                
                // Check if this day has transactions
                final hasTx = filteredTransactions.any((t) =>
                  t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day
                );

                // Show month label for first day or when month changes
                final showMonthLabel = !isDefaultFilter && 
                    (index == 0 || day.month != days[index - 1].month);

                return Row(
                  children: [
                    if (showMonthLabel)
                      Padding(
                        padding: EdgeInsets.only(right: 6.w, bottom: 6.h, top: 2.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.cardYellow,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: AppColors.border, width: 2.r),
                          ),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              DateFormat('MMM').format(day).toUpperCase(),
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(right: 10.w, bottom: 6.h, top: 2.h),
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
                    ),
                  ],
                );
              },
            ),
          ).animate().fadeIn(delay: 200.ms),

          Gap(24.h),
        ],

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
    required int index,
    required bool showTodayButton,
    required VoidCallback onTodayPressed,
    required DateRangeFilter activeFilter,
    required bool showFilterButton,
    required VoidCallback onFilterTap,
  }) {
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;

    return Container(
      margin: EdgeInsets.only(left: 2.w, right: 8.w, top: 2.h, bottom: 8.h),
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
          const Spacer(),
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
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.cardYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2.r),
                      boxShadow: [
                        BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h)),
                      ],
                    ),
                    child: Icon(LucideIcons.chevronLeft, size: 18.r, color: AppColors.textDark),
                  ),
                )
              else
                SizedBox(width: 24.w),
                
              // Filter + Today buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filter button
                  if (showFilterButton)
                    GestureDetector(
                      onTap: onFilterTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border, width: 2.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.border,
                              offset: Offset(2.w, 2.h),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(activeFilter.emoji, style: TextStyle(fontSize: 11.sp)),
                            Gap(5.w),
                            Text(
                              _activeFilterDisplayText(),
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(3.w),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 11.r,
                              color: AppColors.textDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  // TODAY button (only when not on today)
                  if (showTodayButton) ...[
                    Gap(8.w),
                    GestureDetector(
                      onTap: onTodayPressed,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                        decoration: BoxDecoration(
                          color: AppColors.cardYellow,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.border, width: 2.r),
                          boxShadow: [
                            BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.rotateCcw, size: 11.r, color: AppColors.textDark),
                            Gap(4.w),
                            Text(
                              'TODAY',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (index < _FinancialDashboardState._totalMonths - 1)
                GestureDetector(
                  onTap: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: AppColors.cardYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2.r),
                      boxShadow: [
                        BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h)),
                      ],
                    ),
                    child: Icon(LucideIcons.chevronRight, size: 18.r, color: AppColors.textDark),
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
                      backgroundColor: Color(
                        int.parse(goal.themeColor.replaceAll('#', '0xFF')),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(goal.iconEmoji, style: TextStyle(fontSize: 24.sp)),
                              Gap(12.w),
                              Expanded(
                                child: Text(
                                  goal.title.toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          Text(
                            '${NumberFormat.decimalPattern().format(goal.savedAmount)} / ${NumberFormat.decimalPattern().format(goal.targetAmount)} $currency',
                            style: TextStyle(color: AppColors.textDark, fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
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
                                  border: Border(right: BorderSide(color: AppColors.border, width: 2.r)),
                                ),
                              ),
                            ).animate().scaleX(begin: 0, duration: 600.ms, curve: Curves.easeOutBack),
                          ),
                          Gap(16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showManageFundsSheet(context, ref, goal, currency),
                                icon: Icon(LucideIcons.wallet, size: 16.r, color: AppColors.textDark),
                                label: Text('MANAGE FUNDS', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 12.sp)),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    side: BorderSide(color: AppColors.border, width: 2.r),
                                  ),
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

  void _showManageFundsSheet(BuildContext context, WidgetRef ref, Goal goal, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManageGoalFundsSheet(goal: goal, currency: currency),
    );
  }
}

class _ManageGoalFundsSheet extends ConsumerStatefulWidget {
  final Goal goal;
  final String currency;
  const _ManageGoalFundsSheet({required this.goal, required this.currency});

  @override
  ConsumerState<_ManageGoalFundsSheet> createState() => _ManageGoalFundsSheetState();
}

class _ManageGoalFundsSheetState extends ConsumerState<_ManageGoalFundsSheet> {
  final _amountController = TextEditingController();
  bool _isDeposit = true;
  String? _accountId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    if (!_isDeposit && amount > widget.goal.savedAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot withdraw more than what is saved!')),
      );
      return;
    }

    if (_accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account to sync with.')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user != null) {
      final isAddingToGoal = _isDeposit;
      final txn = Transaction(
        id: const Uuid().v4(),
        userId: user.uid,
        type: isAddingToGoal ? TransactionType.expense : TransactionType.income,
        amount: amount,
        date: DateTime.now(),
        accountId: _accountId,
        expenseCategory: isAddingToGoal ? ExpenseCategory.other : null,
        incomeSource: !isAddingToGoal ? IncomeSource.other : null,
        notes: isAddingToGoal
            ? 'Funded goal: ${widget.goal.title}'
            : 'Withdrawn from goal: ${widget.goal.title}',
        createdAt: DateTime.now(),
      );

      await ref.read(transactionsProvider.notifier).add(txn);
      await ref.read(accountsProvider.notifier).adjustBalance(
        _accountId!,
        isAddingToGoal ? -amount : amount,
      );
    }

    ref.read(goalsProvider.notifier).updateGoalProgress(
      widget.goal.id,
      _isDeposit ? amount : -amount,
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
    final mediaQuery = MediaQuery.of(context);
    final navBarClearance = mediaQuery.padding.bottom + 124.h;
    final maxSheetHeight = mediaQuery.size.height - mediaQuery.padding.top;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxSheetHeight.clamp(240.h, mediaQuery.size.height),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(color: AppColors.border, width: 4.r),
          ),
          padding: EdgeInsets.only(
            top: 24.h,
            left: 24.w,
            right: 24.w,
            bottom: mediaQuery.viewInsets.bottom + navBarClearance,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Gap(24.h),
                Text(
                  widget.goal.title.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, letterSpacing: -0.5),
                ),
                Gap(8.h),
                Text(
                  '${widget.goal.iconEmoji} Manage Goal Funds',
                  style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
                ),
                Gap(32.h),

                // Deposit / Withdraw tabs
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDeposit = true),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: _isDeposit ? AppColors.primary : AppColors.white,
                            border: Border.all(color: AppColors.border, width: _isDeposit ? 3.r : 2.r),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: _isDeposit
                                ? [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'DEPOSIT ➕',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _isDeposit ? AppColors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Gap(16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDeposit = false),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: !_isDeposit ? AppColors.cardYellow : AppColors.white,
                            border: Border.all(color: AppColors.border, width: !_isDeposit ? 3.r : 2.r),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: !_isDeposit
                                ? [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'WITHDRAW ➖',
                              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(32.h),

                // Amount input
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.w900, letterSpacing: -1),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: widget.currency,
                    suffixStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                Gap(24.h),

                // Account picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isDeposit ? 'WITHDRAW FROM:' : 'DEPOSIT BACK INTO:',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                  ),
                ),
                Gap(12.h),
                SizedBox(
                  height: 90.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final acc = accounts[index];
                      final isSelected = _accountId == acc.id;
                      return GestureDetector(
                        onTap: () => setState(() => _accountId = acc.id),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          width: 120.w,
                          margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.textDark : AppColors.white,
                            border: Border.all(color: AppColors.border, width: 2.r),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h))]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(acc.iconEmoji ?? '🏦', style: TextStyle(fontSize: 20.sp)),
                              Gap(4.h),
                              Text(
                                acc.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.sp,
                                  color: isSelected ? AppColors.white : AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Gap(32.h),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textDark,
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(color: AppColors.border, width: 3.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'CONFIRM TRANSFER',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
