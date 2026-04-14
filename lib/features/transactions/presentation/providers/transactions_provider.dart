import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';
import 'package:planzy/features/transactions/data/repository/transaction_repository.dart';

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    if (repo == null) return [];
    return repo.getAll();
  }

  /// Add a new transaction
  Future<void> add(Transaction transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.add(transaction);
    // Refresh the list by re-running build()
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }

  /// Delete a transaction
  Future<void> remove(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.remove(id);
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }
}

/// Main provider for all transactions
final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(() {
  return TransactionsNotifier();
});

/// Provider for expenses only
final expensesProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  return transactions.where((t) => t.type == TransactionType.expense).toList();
});

/// Provider for income only
final incomeProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  return transactions.where((t) => t.type == TransactionType.income).toList();
});

/// Provider for today's transactions
final todayTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return transactions.where((t) {
    final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
    return transactionDate == today;
  }).toList();
});

/// Provider for current month stats
final monthlyStatsProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  double totalExpenses = 0;
  double totalIncome = 0;

  for (final t in transactions) {
    if (t.date.isAfter(monthStart) || t.date.isAtSameMomentAs(monthStart)) {
      if (t.type == TransactionType.expense) {
        totalExpenses += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }
  }

  return {
    'expenses': totalExpenses,
    'income': totalIncome,
    'balance': totalIncome - totalExpenses,
  };
});

/// Provider for transactions grouped by date
final transactionsGroupedByDateProvider = Provider<Map<DateTime, List<Transaction>>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final grouped = <DateTime, List<Transaction>>{};

  for (final t in transactions) {
    final dateKey = DateTime(t.date.year, t.date.month, t.date.day);
    grouped.putIfAbsent(dateKey, () => []);
    grouped[dateKey]!.add(t);
  }

  // Sort each day's transactions by date descending
  for (final date in grouped.keys) {
    grouped[date]!.sort((a, b) => b.date.compareTo(a.date));
  }

  return grouped;
});

/// Provider for expenses by category (current month)
final expensesByCategoryProvider = Provider<Map<ExpenseCategory, double>>((ref) {
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);

  final expensesByCategory = <ExpenseCategory, double>{};

  for (final t in transactions) {
    if (t.type == TransactionType.expense &&
        t.expenseCategory != null &&
        (t.date.isAfter(monthStart) || t.date.isAtSameMomentAs(monthStart))) {
      expensesByCategory[t.expenseCategory!] =
          (expensesByCategory[t.expenseCategory!] ?? 0) + t.amount;
    }
  }

  return expensesByCategory;
});
