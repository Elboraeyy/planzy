import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/neo_dialog.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';
import 'package:planzy/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  TransactionType? _filterType;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (error, stack) => '',
    );

    final transactionsAsync = ref.watch(transactionsProvider);
    final monthlyStats = ref.watch(monthlyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('TRANSACTIONS', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.filter, color: AppColors.textDark, size: 24.r),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Monthly Summary Card
          Container(
            margin: EdgeInsets.all(24.r),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border, width: 3.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.border,
                  offset: Offset(6.w, 6.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.textLight,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: monthlyStats['balance']! >= 0
                            ? AppColors.secondary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.border, width: 2.r),
                      ),
                      child: Text(
                        monthlyStats['balance']! >= 0 ? 'SURPLUS' : 'DEFICIT',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(16.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'INCOME',
                        amount: monthlyStats['income']!,
                        currency: currency,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    Container(
                      width: 3.w,
                      height: 50.h,
                      color: AppColors.border.withValues(alpha: 0.1),
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    Expanded(
                      child: _SummaryItem(
                        label: 'EXPENSES',
                        amount: monthlyStats['expenses']!,
                        currency: currency,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),

          // Filter Chips
          Container(
            height: 52.h,
            margin: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 16.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                Gap(12.w),
                _FilterChip(
                  label: 'Expenses',
                  isSelected: _filterType == TransactionType.expense,
                  onTap: () => setState(() => _filterType = TransactionType.expense),
                  color: AppColors.primary,
                ),
                Gap(12.w),
                _FilterChip(
                  label: 'Income',
                  isSelected: _filterType == TransactionType.income,
                  onTap: () => setState(() => _filterType = TransactionType.income),
                  color: AppColors.secondary,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                // Filter by type
                final filteredTransactions = _filterType != null
                    ? transactions.where((t) => t.type == _filterType).toList()
                    : transactions;

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            color: AppColors.cardYellow,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.border, width: 3.r),
                            boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h))],
                          ),
                          child: Icon(
                            LucideIcons.receipt,
                            size: 48.r,
                            color: AppColors.textDark,
                          ),
                        ),
                        Gap(24.h),
                        Text(
                          'NO TRANSACTIONS YET',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: AppColors.textLight,
                          ),
                        ),
                        Gap(8.h),
                        TextButton(
                          onPressed: () => context.push('/add-transaction'),
                          child: Text('Add your first transaction', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final groupedTransactions = _groupByDate(filteredTransactions);

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: groupedTransactions.length,
                  itemBuilder: (context, index) {
                    final entry = groupedTransactions.entries.elementAt(index);
                    final date = entry.key;
                    final dayTransactions = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBlue,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: AppColors.border, width: 2.r),
                                ),
                                child: Text(
                                  _getDateLabel(date),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Gap(12.w),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(date),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                              // Daily total
                              Text(
                                _calculateDailyTotal(dayTransactions, currency),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (50 * index).ms),

                        // Transactions for this day
                        ...dayTransactions.map((transaction) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _TransactionCard(
                                transaction: transaction,
                                currency: currency,
                                onDelete: () => _deleteTransaction(transaction),
                              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1),
                            )),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        child: Icon(LucideIcons.plus, size: 28.r),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        side: BorderSide(color: AppColors.border, width: 3.r),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FILTER BY DATE',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            Gap(16.h),
            // Add date range picker here if needed
            Text('Coming soon...', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textLight)),
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> transactions) {
    final grouped = <DateTime, List<Transaction>>{};

    for (final t in transactions) {
      final dateKey = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(t);
    }

    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'TODAY';
    if (date == yesterday) return 'YESTERDAY';
    return DateFormat('EEEE').format(date).toUpperCase();
  }

  String _calculateDailyTotal(List<Transaction> transactions, String currency) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final net = income - expenses;
    return '${net >= 0 ? '+' : ''}${NumberFormat.compact().format(net)} $currency';
  }

  void _deleteTransaction(Transaction transaction) {
    NeoDialog.show(
      context: context,
      title: 'DELETE TRANSACTION?',
      message: 'Are you sure you want to delete this ${transaction.type.name}?',
      confirmText: 'YES, DELETE',
      cancelText: 'NO, KEEP IT',
      isDestructive: true,
      onConfirm: () {
        ref.read(transactionsProvider.notifier).remove(transaction.id);
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.textLight,
          ),
        ),
        Gap(4.h),
        FittedBox(
          child: Text(
            '${NumberFormat.decimalPattern().format(amount)} $currency',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.secondary) : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.border,
            width: isSelected ? 3.r : 2.r,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(3.w, 3.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: isSelected ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.currency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;

    return GestureDetector(
      onLongPress: onDelete,
      child: NeoCard(
        backgroundColor: isExpense ? AppColors.white : AppColors.cardYellow,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isExpense ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border, width: 2.r),
              ),
              child: Text(
                isExpense
                    ? (transaction.expenseCategory?.icon ?? '📦')
                    : (transaction.incomeSource?.icon ?? '💵'),
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
            Gap(12.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpense
                        ? (transaction.expenseCategory?.displayName ?? 'Expense')
                        : (transaction.incomeSource?.displayName ?? 'Income'),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                  Gap(2.h),
                  if (transaction.notes != null)
                    Text(
                      transaction.notes!,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormat.jm().format(transaction.date),
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${NumberFormat.decimalPattern().format(transaction.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17.sp,
                    color: isExpense ? AppColors.primary : const Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  currency,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
