import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
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
        title: Text(
          'Transactions',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.filter, color: AppColors.textDark, size: 20.r),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Monthly Summary Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border, width: 1.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: monthlyStats['balance']! >= 0
                            ? AppColors.successLight
                            : AppColors.destructiveLight,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        monthlyStats['balance']! >= 0 ? 'Surplus' : 'Deficit',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: monthlyStats['balance']! >= 0
                              ? AppColors.success
                              : AppColors.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(14.h),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'Income',
                        amount: monthlyStats['income']!,
                        currency: currency,
                        color: AppColors.success,
                      ),
                    ),
                    Container(
                      width: 1.w,
                      height: 40.h,
                      color: AppColors.border,
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    Expanded(
                      child: _SummaryItem(
                        label: 'Expenses',
                        amount: monthlyStats['expenses']!,
                        currency: currency,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.05),

          // Filter Chips
          Container(
            height: 38.h,
            margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                Gap(8.w),
                _FilterChip(
                  label: 'Expenses',
                  isSelected: _filterType == TransactionType.expense,
                  onTap: () => setState(() => _filterType = TransactionType.expense),
                ),
                Gap(8.w),
                _FilterChip(
                  label: 'Income',
                  isSelected: _filterType == TransactionType.income,
                  onTap: () => setState(() => _filterType = TransactionType.income),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

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
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: AppColors.zinc100,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.border, width: 1.r),
                          ),
                          child: Icon(
                            LucideIcons.receipt,
                            size: 36.r,
                            color: AppColors.zinc400,
                          ),
                        ),
                        Gap(16.h),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: AppColors.textDark,
                          ),
                        ),
                        Gap(4.h),
                        TextButton(
                          onPressed: () => context.push('/add-transaction'),
                          child: Text(
                            'Add your first transaction',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final groupedTransactions = _groupByDate(filteredTransactions);

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getDateLabel(date)} • ${DateFormat('MMM d').format(date)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              // Daily total
                              Text(
                                _calculateDailyTotal(dayTransactions, currency),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Transactions for this day
                        ...dayTransactions.map((transaction) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _TransactionCard(
                                transaction: transaction,
                                currency: currency,
                                onDelete: () => _deleteTransaction(transaction),
                              ),
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: Icon(LucideIcons.plus, size: 22.r),
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
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        Gap(4.h),
        FittedBox(
          child: Text(
            '${NumberFormat.decimalPattern().format(amount)} $currency',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.3,
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

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.zinc100,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: -0.2,
            color: isSelected ? Colors.white : AppColors.textDark,
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.destructiveLight
                    : AppColors.successLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  isExpense
                      ? (transaction.expenseCategory?.icon ?? '📦')
                      : (transaction.incomeSource?.icon ?? '💵'),
                  style: TextStyle(fontSize: 18.sp),
                ),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Gap(2.h),
                  if (transaction.notes != null && transaction.notes!.isNotEmpty)
                    Text(
                      transaction.notes!,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormat('hh:mm a').format(transaction.date),
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: isExpense
                        ? AppColors.textDark
                        : AppColors.success,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  currency,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
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
