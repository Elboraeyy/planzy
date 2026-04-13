import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  TransactionRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _firestore.collection('users').doc(_userId).collection('transactions');

  /// Add or update a transaction
  Future<void> add(Transaction transaction) async {
    await _transactionsRef.doc(transaction.id).set(transaction.toJson());
  }

  /// Get all transactions
  Future<List<Transaction>> getAll() async {
    final snapshot = await _transactionsRef.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Transaction.fromJson(doc.data())).toList();
  }

  /// Get transactions stream (real-time)
  Stream<List<Transaction>> watchAll() {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Transaction.fromJson(doc.data())).toList());
  }

  /// Get transactions by date range
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    final snapshot = await _transactionsRef
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => Transaction.fromJson(doc.data())).toList();
  }

  /// Get transactions by type
  Stream<List<Transaction>> watchByType(TransactionType type) {
    return _transactionsRef
        .where('type', isEqualTo: type.name)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Transaction.fromJson(doc.data())).toList());
  }

  /// Delete a transaction
  Future<void> remove(String id) async {
    await _transactionsRef.doc(id).delete();
  }

  /// Get monthly summary
  Future<Map<String, double>> getMonthlySummary(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final transactions = await getByDateRange(start, end);

    double totalExpenses = 0;
    double totalIncome = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        totalExpenses += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }

    return {
      'expenses': totalExpenses,
      'income': totalIncome,
      'balance': totalIncome - totalExpenses,
    };
  }
}

/// Provider for TransactionRepository
final transactionRepositoryProvider = Provider<TransactionRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return TransactionRepository(FirebaseFirestore.instance, user.uid);
});
