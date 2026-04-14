import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  SubscriptionRepository(this._firestore, this._userId);

  CollectionReference<Map<String, dynamic>> get _subsRef =>
      _firestore.collection('users').doc(_userId).collection('subscriptions');

  /// Add or update a subscription
  Future<void> add(Subscription subscription) async {
    await _subsRef
        .doc(subscription.id)
        .set(subscription.toJson())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Operation timed out. Please check your internet connection.',
          ),
        );
  }

  /// Get all subscriptions
  Future<List<Subscription>> getAll() async {
    final snapshot = await _subsRef
        .orderBy('createdAt', descending: true)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load subscriptions. Please check your internet connection.',
          ),
        );
    return snapshot.docs
        .map((doc) => Subscription.fromJson(doc.data()))
        .toList();
  }

  /// Get a single subscription by ID
  Future<Subscription?> getById(String id) async {
    final doc = await _subsRef
        .doc(id)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load subscription. Please check your internet connection.',
          ),
        );
    if (!doc.exists) return null;
    return Subscription.fromJson(doc.data()!);
  }

  /// Remove a subscription
  Future<void> remove(String id) async {
    await _subsRef
        .doc(id)
        .delete()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to delete subscription. Please check your internet connection.',
          ),
        );
  }

  /// Toggle active/paused
  Future<void> toggleActive(String id, bool isActive) async {
    await _subsRef
        .doc(id)
        .update({'isActive': isActive})
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to update subscription. Please check your internet connection.',
          ),
        );
  }

  /// Update subscription
  Future<void> update(Subscription subscription) async {
    await _subsRef
        .doc(subscription.id)
        .set(subscription.toJson())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to update subscription. Please check your internet connection.',
          ),
        );
  }
}

/// Provider for SubscriptionRepository
final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return SubscriptionRepository(FirebaseFirestore.instance, user.uid);
});
