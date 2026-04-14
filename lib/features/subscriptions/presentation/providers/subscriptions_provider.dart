import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:planzy/features/subscriptions/data/repository/subscription_repository.dart';

class SubscriptionsNotifier extends AsyncNotifier<List<Subscription>> {
  @override
  Future<List<Subscription>> build() async {
    final repo = ref.watch(subscriptionRepositoryProvider);
    if (repo == null) return [];
    return repo.getAll();
  }

  /// Add a new subscription
  Future<void> add(Subscription subscription) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.add(subscription);
    ref.invalidateSelf();
  }

  /// Remove a subscription
  Future<void> remove(String id) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.remove(id);
    ref.invalidateSelf();
  }

  /// Update a subscription
  Future<void> updateSubscription(Subscription subscription) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.update(subscription);
    ref.invalidateSelf();
  }

  /// Toggle active/paused
  Future<void> toggleActive(String id, bool isActive) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    await repo.toggleActive(id, isActive);
    ref.invalidateSelf();
  }
}

/// Main provider for all subscriptions
final subscriptionsProvider =
    AsyncNotifierProvider<SubscriptionsNotifier, List<Subscription>>(() {
  return SubscriptionsNotifier();
});

/// Provider for active subscriptions only
final activeSubscriptionsProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(subscriptionsProvider).valueOrNull ?? [];
  return subs.where((s) => s.isActive).toList();
});

/// Provider for total monthly cost (normalized)
final totalMonthlySubCostProvider = Provider<double>((ref) {
  final subs = ref.watch(activeSubscriptionsProvider);
  double total = 0;
  for (final sub in subs) {
    switch (sub.cycle) {
      case SubscriptionCycle.daily:
        total += sub.amount * 30;
        break;
      case SubscriptionCycle.weekly:
        total += sub.amount * 4.33;
        break;
      case SubscriptionCycle.monthly:
        total += sub.amount;
        break;
      case SubscriptionCycle.seasonal:
        total += sub.amount / 3;
        break;
      case SubscriptionCycle.yearly:
        total += sub.amount / 12;
        break;
    }
  }
  return total;
});

/// Provider for upcoming renewals (next 7 days)
final upcomingRenewalsProvider = Provider<List<Subscription>>((ref) {
  final subs = ref.watch(activeSubscriptionsProvider);
  final now = DateTime.now();
  final weekFromNow = now.add(const Duration(days: 7));

  return subs
      .where((s) =>
          s.nextRenewalDate.isAfter(now) &&
          s.nextRenewalDate.isBefore(weekFromNow))
      .toList()
    ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
});
