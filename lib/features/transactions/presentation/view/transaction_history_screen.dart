import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      error: (_, __) => '',
    );

    final transactionsAsync = ref.watch(transactionsProvider);
    final monthlyStats = ref.watch(monthlyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter, color: AppColors.textDark),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Monthly Summary Card
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.border,
                  offset: Offset(6, 6),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.textLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: monthlyStats['balance']! >= 0
                            ? AppColors.secondary
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Text(
                        monthlyStats['balance']! >= 0 ? 'SURPLUS' : 'DEFICIT',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        label: 'INCOME',
                        amount: monthlyStats['income']!,
                        currency: currency,
                        color: AppColors.secondary,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 50,
                      color: AppColors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            height: 50,
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                const Gap(12),
                _FilterChip(
                  label: 'Expenses',
                  isSelected: _filterType == TransactionType.expense,
                  onTap: () => setState(() => _filterType = TransactionType.expense),
                  color: AppColors.primary,
                ),
                const Gap(12),
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
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardYellow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 3),
                          ),
                          child: const Icon(
                            LucideIcons.receipt,
                            size: 48,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Gap(16),
                        const Text(
                          'NO TRANSACTIONS YET',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: AppColors.textLight,
                          ),
                        ),
                        const Gap(8),
                        TextButton(
                          onPressed: () => context.push('/add-transaction'),
                          child: const Text('Add your first transaction'),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final groupedTransactions = _groupByDate(filteredTransactions);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBlue,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border, width: 2),
                                ),
                                child: Text(
                                  _getDateLabel(date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, yyyy').format(date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ),
                              // Daily total
                              Text(
                                '${_calculateDailyTotal(dayTransactions, currency)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (50 * index).ms),

                        // Transactions for this day
                        ...dayTransactions.map((transaction) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
        child: const Icon(LucideIcons.plus, size: 28),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border, width: 3),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FILTER BY DATE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Gap(16),
            // Add date range picker here if needed
            const Text('Coming soon...'),
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
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.textLight,
          ),
        ),
        const Gap(4),
        FittedBox(
          child: Text(
            '${NumberFormat.decimalPattern().format(amount)} $currency',
            style: TextStyle(
              fontSize: 18,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.secondary) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(3, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpense ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Text(
                isExpense
                    ? (transaction.expenseCategory?.icon ?? '📦')
                    : (transaction.incomeSource?.icon ?? '💵'),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const Gap(12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpense
                        ? (transaction.expenseCategory?.displayName ?? 'Expense')
                        : (transaction.incomeSource?.displayName ?? 'Income'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(2),
                  if (transaction.notes != null)
                    Text(
                      transaction.notes!,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    DateFormat.jm().format(transaction.date),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
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
                    fontSize: 18,
                    color: isExpense ? AppColors.primary : AppColors.textDark,
                  ),
                ),
                Text(
                  currency,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
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
