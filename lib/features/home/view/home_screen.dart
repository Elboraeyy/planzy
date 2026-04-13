import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: const [
            _HomeHeaderWidget(),
            Gap(32),
            _FinancialDashboard(),
            Gap(32),
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

// ──────────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────────

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
      final target = (index * 68.0) - (MediaQuery.of(context).size.width / 2 - 58);
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
          height: 310,
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

        const Gap(20),

        // ═══════════════════════════════════════════════
        // DAY SCROLLER
        // ═══════════════════════════════════════════════
        SizedBox(
          height: 72,
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
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = day);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    width: 58,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.secondary.withValues(alpha: 0.3)
                              : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.border : AppColors.border.withValues(alpha: 0.15),
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected
                          ? const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? AppColors.white.withValues(alpha: 0.7) : AppColors.textLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                        if (hasTx && !isSelected) ...[
                          const Gap(2),
                          Container(
                            width: 6, height: 6,
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

        const Gap(24),

        // ═══════════════════════════════════════════════
        // DAY TRANSACTIONS FEED
        // ═══════════════════════════════════════════════
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, d MMM').format(_selectedDay).toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
            ),
            if (dayTransactions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  '${dayTransactions.length} item${dayTransactions.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 300.ms),
        const Gap(16),

        if (dayTransactions.isEmpty)
          NeoCard(
            backgroundColor: AppColors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('📭', style: TextStyle(fontSize: 32)),
                    const Gap(8),
                    Text(
                      'NO ACTIVITY ON ${DateFormat('MMMM d').format(_selectedDay).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, fontSize: 13),
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
                padding: const EdgeInsets.only(bottom: 12),
                child: NeoCard(
                  backgroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isExpense
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.1), width: 2),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.3),
                            ),
                            const Gap(2),
                            Text(
                              DateFormat('HH:mm').format(t.date),
                              style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            if (t.notes != null && t.notes!.isNotEmpty) ...[
                              const Gap(2),
                              Text(
                                t.notes!,
                                style: const TextStyle(color: AppColors.textLight, fontSize: 11),
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
                              fontSize: 18,
                              color: isExpense ? AppColors.primary : const Color(0xFF2E7D32),
                            ),
                          ),
                          Text(currency, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
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
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(6, 6)),
        ],
      ),
      padding: const EdgeInsets.all(24),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Text(
                      DateFormat('MMMM').format(month).toUpperCase(),
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: Text(
                      '${month.year}',
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (isCurrentMonth)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 2),

                    ),
                    child: Text(
                      DateFormat('E, d').format(now).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          
          const Gap(16),

          // Balance
          const Text(
            'BALANCE',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
          const Gap(4),
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
                    style: const TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2),
                  ),
                ),
              ),
              const Gap(8),
              Text(
                currency,
                style: const TextStyle(color: AppColors.cardYellow, fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),

          const Gap(16),

          // Income & Expense row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                          ),
                          const Gap(6),
                          const Text('INCOME', style: TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      const Gap(6),
                      FittedBox(
                        child: Text(
                          '+${NumberFormat.compact().format(income)} $currency',
                          style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                          const Gap(6),
                          const Text('EXPENSE', style: TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ],
                      ),
                      const Gap(6),
                      FittedBox(
                        child: Text(
                          '-${NumberFormat.compact().format(expense)} $currency',
                          style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Swipe hint & Buttons
          const Gap(8),
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.white),
                  ),
                )
              else
                const SizedBox(width: 24),
                
              Text(
                'SWIPE FOR MONTHS',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),

              if (index < _FinancialDashboardState._totalMonths - 1)
                GestureDetector(
                  onTap: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.white),
                  ),
                )
              else
                const SizedBox(width: 24),
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
