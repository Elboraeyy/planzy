import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

enum SubscriptionCycle {
  daily,
  weekly,
  monthly,
  seasonal,
  yearly,
}

extension SubscriptionCycleExtension on SubscriptionCycle {
  String get displayName {
    switch (this) {
      case SubscriptionCycle.daily:
        return 'Daily';
      case SubscriptionCycle.weekly:
        return 'Weekly';
      case SubscriptionCycle.monthly:
        return 'Monthly';
      case SubscriptionCycle.seasonal:
        return 'Seasonal';
      case SubscriptionCycle.yearly:
        return 'Yearly';
    }
  }

  String get shortLabel {
    switch (this) {
      case SubscriptionCycle.daily:
        return '/ day';
      case SubscriptionCycle.weekly:
        return '/ week';
      case SubscriptionCycle.monthly:
        return '/ mo';
      case SubscriptionCycle.seasonal:
        return '/ season';
      case SubscriptionCycle.yearly:
        return '/ yr';
    }
  }

  String get emoji {
    switch (this) {
      case SubscriptionCycle.daily:
        return '📅';
      case SubscriptionCycle.weekly:
        return '📆';
      case SubscriptionCycle.monthly:
        return '🗓️';
      case SubscriptionCycle.seasonal:
        return '🍂';
      case SubscriptionCycle.yearly:
        return '🎆';
    }
  }
}

enum SubscriptionCategory {
  entertainment,
  health,
  education,
  music,
  cloud,
  gaming,
  food,
  shopping,
  transport,
  other,
}

extension SubscriptionCategoryExtension on SubscriptionCategory {
  String get displayName {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return 'Entertainment';
      case SubscriptionCategory.health:
        return 'Health';
      case SubscriptionCategory.education:
        return 'Education';
      case SubscriptionCategory.music:
        return 'Music';
      case SubscriptionCategory.cloud:
        return 'Cloud';
      case SubscriptionCategory.gaming:
        return 'Gaming';
      case SubscriptionCategory.food:
        return 'Food';
      case SubscriptionCategory.shopping:
        return 'Shopping';
      case SubscriptionCategory.transport:
        return 'Transport';
      case SubscriptionCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return '🎬';
      case SubscriptionCategory.health:
        return '💪';
      case SubscriptionCategory.education:
        return '📚';
      case SubscriptionCategory.music:
        return '🎵';
      case SubscriptionCategory.cloud:
        return '☁️';
      case SubscriptionCategory.gaming:
        return '🎮';
      case SubscriptionCategory.food:
        return '🍕';
      case SubscriptionCategory.shopping:
        return '🛍️';
      case SubscriptionCategory.transport:
        return '🚗';
      case SubscriptionCategory.other:
        return '🗂️';
    }
  }
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String name,
    required double amount,
    required String currency,
    required SubscriptionCycle cycle,
    required SubscriptionCategory category,
    required DateTime nextRenewalDate,
    @Default(true) bool isActive,

    // Reminder
    @Default(3) int reminderDaysBefore,

    // Auto-deduct
    @Default(false) bool autoDeduct,
    String? linkedAccountId,

    // Notes
    String? notes,

    // Visual
    String? iconEmoji,
    String? colorHex,

    required DateTime createdAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}
