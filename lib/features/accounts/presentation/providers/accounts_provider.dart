import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/data/repository/account_repository.dart';

class AccountsNotifier extends AsyncNotifier<List<FinancialAccount>> {
  @override
  Future<List<FinancialAccount>> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    if (repo == null) return [];
    return repo.getAll();
  }

  /// Add a new account
  Future<void> add(FinancialAccount account) async {
    final repo = ref.read(accountRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.add(account);
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }

  /// Update an existing account
  Future<void> updateAccount(FinancialAccount account) async {
    final repo = ref.read(accountRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.add(account);
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }

  /// Delete an account
  Future<void> remove(String id) async {
    final repo = ref.read(accountRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.remove(id);
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }

  /// Adjust balance after a transaction
  Future<void> adjustBalance(String accountId, double delta) async {
    final repo = ref.read(accountRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    final account = await repo.getById(accountId);
    if (account == null) throw Exception('Account not found');

    await repo.updateBalance(accountId, account.balance + delta);
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }

  /// Transfer funds between accounts
  Future<void> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.transfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      fee: fee,
    );
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }

  /// Set default account
  Future<void> setDefault(String accountId) async {
    final repo = ref.read(accountRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.setDefault(accountId);
    ref.invalidateSelf();
    // Removed await future to prevent hanging
  }
}

/// Main provider for all financial accounts
final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<FinancialAccount>>(() {
  return AccountsNotifier();
});

/// Provider for total balance across all accounts
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  return accounts.fold(0.0, (sum, account) => sum + account.balance);
});

/// Provider for the default account
final defaultAccountProvider = Provider<FinancialAccount?>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? [];
  try {
    return accounts.firstWhere((a) => a.isDefault);
  } catch (_) {
    return accounts.isNotEmpty ? accounts.first : null;
  }
});

/// Privacy mode state provider
final privacyModeProvider = StateProvider<bool>((ref) => false);
