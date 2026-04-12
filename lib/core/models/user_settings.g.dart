// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      id: (json['id'] as num?)?.toInt() ?? 1,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'EGP',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'monthlyIncome': instance.monthlyIncome,
      'currency': instance.currency,
      'notificationsEnabled': instance.notificationsEnabled,
    };
