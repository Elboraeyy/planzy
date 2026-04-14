import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.freezed.dart';
part 'user_settings.g.dart';

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    required String id,
    required String userId,
    @Default(0.0) double monthlyIncome,
    @Default('EGP') String currency,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool hasCompletedOnboarding,
    @Default('') String userName,
    @Default(false) bool isProfileComplete,
    String? profileImagePath,
    @Default('') String userEmail,
    @Default('') String userBio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  /// Factory for creating new user settings
  factory UserSettings.createNew({
    required String userId,
    String? email,
  }) {
    return UserSettings(
      id: 'settings_$userId',
      userId: userId,
      monthlyIncome: 0.0,
      currency: 'EGP',
      notificationsEnabled: true,
      hasCompletedOnboarding: false,
      userName: '',
      isProfileComplete: false,
      profileImagePath: null,
      userEmail: email ?? '',
      userBio: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
