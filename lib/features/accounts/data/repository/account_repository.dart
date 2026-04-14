import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';

class AccountRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  AccountRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _accountsRef =>
      _firestore.collection('users').doc(_userId).collection('accounts');

  /// Add or update an account
  Future<void> add(FinancialAccount account) async {
    await _accountsRef
        .doc(account.id)
        .set(account.toJson())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Operation timed out. Please check your internet connection.',
          ),
        );
  }

  /// Get all accounts
  Future<List<FinancialAccount>> getAll() async {
    final snapshot = await _accountsRef
        .orderBy('createdAt', descending: false)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load accounts. Please check your internet connection.',
          ),
        );
    return snapshot.docs.map((doc) => FinancialAccount.fromJson(doc.data())).toList();
  }

  /// Get a single account by ID
  Future<FinancialAccount?> getById(String id) async {
    final doc = await _accountsRef
        .doc(id)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load account. Please check your internet connection.',
          ),
        );
    if (!doc.exists) return null;
    return FinancialAccount.fromJson(doc.data()!);
  }

  /// Update account balance
  Future<void> updateBalance(String accountId, double newBalance) async {
    await _accountsRef
        .doc(accountId)
        .update({'balance': newBalance})
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to update balance. Please check your internet connection.',
          ),
        );
  }

  /// Delete an account
  Future<void> remove(String id) async {
    await _accountsRef
        .doc(id)
        .delete()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to delete account. Please check your internet connection.',
          ),
        );
  }

  /// Transfer funds between two accounts
  Future<void> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0,
  }) async {
    final batch = _firestore.batch();

    final fromDoc = _accountsRef.doc(fromAccountId);
    final toDoc = _accountsRef.doc(toAccountId);

    final fromSnap = await fromDoc.get().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception(
        'Operation timed out. Please check your internet connection.',
      ),
    );
    final toSnap = await toDoc.get().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception(
        'Operation timed out. Please check your internet connection.',
      ),
    );

    if (!fromSnap.exists || !toSnap.exists) {
      throw Exception('One or both accounts not found');
    }

    final fromBalance = (fromSnap.data()!['balance'] as num).toDouble();
    final toBalance = (toSnap.data()!['balance'] as num).toDouble();

    if (fromBalance < amount + fee) {
      throw Exception('Insufficient balance for transfer');
    }

    batch.update(fromDoc, {'balance': fromBalance - amount - fee});
    batch.update(toDoc, {'balance': toBalance + amount});

    await batch.commit().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception(
        'Transfer failed. Please check your internet connection.',
      ),
    );
  }

  /// Set an account as default (unset all others first)
  Future<void> setDefault(String accountId) async {
    final allAccounts = await getAll();
    final batch = _firestore.batch();

    for (final account in allAccounts) {
      batch.update(
        _accountsRef.doc(account.id),
        {'isDefault': account.id == accountId},
      );
    }

    await batch.commit().timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception(
        'Failed to set default account. Please check your internet connection.',
      ),
    );
  }
}

/// Provider for AccountRepository
final accountRepositoryProvider = Provider<AccountRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return AccountRepository(FirebaseFirestore.instance, user.uid);
});
