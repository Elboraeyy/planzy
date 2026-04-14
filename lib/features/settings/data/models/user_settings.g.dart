// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EGP',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      userName: json['userName'] as String? ?? '',
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      profileImagePath: json['profileImagePath'] as String?,
      userEmail: json['userEmail'] as String? ?? '',
      userBio: json['userBio'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'monthlyIncome': instance.monthlyIncome,
      'currency': instance.currency,
      'notificationsEnabled': instance.notificationsEnabled,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
      'userName': instance.userName,
      'isProfileComplete': instance.isProfileComplete,
      'profileImagePath': instance.profileImagePath,
      'userEmail': instance.userEmail,
      'userBio': instance.userBio,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
