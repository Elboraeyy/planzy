import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/goals/data/models/goal.dart';

class GoalRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  GoalRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _firestore.collection('users').doc(_userId).collection('goals');

  /// Get all goals
  Future<List<Goal>> getAll() async {
    final snapshot = await _goalsRef
        .orderBy('targetDate', descending: false)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load goals. Please check your internet connection.',
          ),
        );
    return snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList();
  }

  /// Add a goal
  Future<void> add(Goal goal) async {
    await _goalsRef
        .doc(goal.id)
        .set(goal.toJson())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to add goal. Please check your internet connection.',
          ),
        );
  }

  /// Remove a goal
  Future<void> remove(String id) async {
    await _goalsRef
        .doc(id)
        .delete()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to delete goal. Please check your internet connection.',
          ),
        );
  }

  /// Update saved amount
  Future<void> updateSavedAmount(String id, double amount) async {
    await _goalsRef
        .doc(id)
        .update({'savedAmount': amount})
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to update goal. Please check your internet connection.',
          ),
        );
  }
}

/// Provider for GoalRepository
final goalRepositoryProvider = Provider<GoalRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return GoalRepository(FirebaseFirestore.instance, user.uid);
});
