// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commitment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommitmentImpl _$$CommitmentImplFromJson(Map<String, dynamic> json) =>
    _$CommitmentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      repeatType: $enumDecode(_$RepeatTypeEnumMap, json['repeatType']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      category: json['category'] as String,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$CommitmentImplToJson(_$CommitmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'repeatType': _$RepeatTypeEnumMap[instance.repeatType]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'category': instance.category,
      'reminderEnabled': instance.reminderEnabled,
    };

const _$RepeatTypeEnumMap = {
  RepeatType.weekly: 'weekly',
  RepeatType.monthly: 'monthly',
  RepeatType.yearly: 'yearly',
  RepeatType.custom: 'custom',
};
