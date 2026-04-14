import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/commitments/data/models/commitment.dart';

class CommitmentRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  CommitmentRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _commitmentsRef =>
      _firestore.collection('users').doc(_userId).collection('commitments');

  /// Get all commitments
  Future<List<Commitment>> getAll() async {
    final snapshot = await _commitmentsRef
        .orderBy('startDate', descending: true)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load commitments. Please check your internet connection.',
          ),
        );
    return snapshot.docs.map((doc) => Commitment.fromJson(doc.data())).toList();
  }

  /// Add a commitment
  Future<void> add(Commitment commitment) async {
    await _commitmentsRef
        .doc(commitment.id)
        .set(commitment.toJson())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to add commitment. Please check your internet connection.',
          ),
        );
  }

  /// Remove a commitment
  Future<void> remove(String id) async {
    await _commitmentsRef
        .doc(id)
        .delete()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to delete commitment. Please check your internet connection.',
          ),
        );
  }
}

/// Provider for CommitmentRepository
final commitmentRepositoryProvider = Provider<CommitmentRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return CommitmentRepository(FirebaseFirestore.instance, user.uid);
});
