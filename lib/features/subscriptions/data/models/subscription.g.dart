// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      cycle: $enumDecode(_$SubscriptionCycleEnumMap, json['cycle']),
      category: $enumDecode(_$SubscriptionCategoryEnumMap, json['category']),
      nextRenewalDate: DateTime.parse(json['nextRenewalDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 3,
      autoDeduct: json['autoDeduct'] as bool? ?? false,
      linkedAccountId: json['linkedAccountId'] as String?,
      notes: json['notes'] as String?,
      iconEmoji: json['iconEmoji'] as String?,
      colorHex: json['colorHex'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'amount': instance.amount,
      'currency': instance.currency,
      'cycle': _$SubscriptionCycleEnumMap[instance.cycle]!,
      'category': _$SubscriptionCategoryEnumMap[instance.category]!,
      'nextRenewalDate': instance.nextRenewalDate.toIso8601String(),
      'isActive': instance.isActive,
      'reminderDaysBefore': instance.reminderDaysBefore,
      'autoDeduct': instance.autoDeduct,
      'linkedAccountId': instance.linkedAccountId,
      'notes': instance.notes,
      'iconEmoji': instance.iconEmoji,
      'colorHex': instance.colorHex,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SubscriptionCycleEnumMap = {
  SubscriptionCycle.daily: 'daily',
  SubscriptionCycle.weekly: 'weekly',
  SubscriptionCycle.monthly: 'monthly',
  SubscriptionCycle.seasonal: 'seasonal',
  SubscriptionCycle.yearly: 'yearly',
};

const _$SubscriptionCategoryEnumMap = {
  SubscriptionCategory.entertainment: 'entertainment',
  SubscriptionCategory.health: 'health',
  SubscriptionCategory.education: 'education',
  SubscriptionCategory.music: 'music',
  SubscriptionCategory.cloud: 'cloud',
  SubscriptionCategory.gaming: 'gaming',
  SubscriptionCategory.food: 'food',
  SubscriptionCategory.shopping: 'shopping',
  SubscriptionCategory.transport: 'transport',
  SubscriptionCategory.other: 'other',
};
