// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate'] as String),
      priority: $enumDecodeNullable(_$GoalPriorityEnumMap, json['priority']) ??
          GoalPriority.medium,
      iconEmoji: json['iconEmoji'] as String? ?? '🎯',
      themeColor: json['themeColor'] as String? ?? '#FFD600',
      linkedAccountId: json['linkedAccountId'] as String?,
      reminderInterval: $enumDecodeNullable(
              _$GoalReminderIntervalEnumMap, json['reminderInterval']) ??
          GoalReminderInterval.none,
    );

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'targetAmount': instance.targetAmount,
      'savedAmount': instance.savedAmount,
      'targetDate': instance.targetDate.toIso8601String(),
      'priority': _$GoalPriorityEnumMap[instance.priority]!,
      'iconEmoji': instance.iconEmoji,
      'themeColor': instance.themeColor,
      'linkedAccountId': instance.linkedAccountId,
      'reminderInterval':
          _$GoalReminderIntervalEnumMap[instance.reminderInterval]!,
    };

const _$GoalPriorityEnumMap = {
  GoalPriority.low: 'low',
  GoalPriority.medium: 'medium',
  GoalPriority.high: 'high',
};

const _$GoalReminderIntervalEnumMap = {
  GoalReminderInterval.none: 'none',
  GoalReminderInterval.weekly: 'weekly',
  GoalReminderInterval.monthly: 'monthly',
};
