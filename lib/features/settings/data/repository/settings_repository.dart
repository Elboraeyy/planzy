import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/settings/data/models/user_settings.dart';

class SettingsRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  SettingsRepository(this._firestore, this._userId);

  /// Reference to the user's settings document
  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _firestore.collection('users').doc(_userId).collection('settings').doc('user_settings');

  /// Get user settings
  Future<UserSettings> getSettings() async {
    final doc = await _settingsRef
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to load settings. Please check your internet connection.',
          ),
        );

    if (!doc.exists) {
      // Create default settings if they don't exist
      final defaultSettings = UserSettings.createNew(userId: _userId);
      await _settingsRef.set(defaultSettings.toJson());
      return defaultSettings;
    }

    return UserSettings.fromJson(doc.data()!);
  }

  /// Save/update user settings
  Future<void> saveSettings(UserSettings settings) async {
    final updatedSettings = settings.copyWith(
      updatedAt: DateTime.now(),
    );
    await _settingsRef
        .set(updatedSettings.toJson())
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to save settings. Please check your internet connection.',
          ),
        );
  }

  /// Update a specific field
  Future<void> updateField(String field, dynamic value) async {
    await _settingsRef
        .update({field: value, 'updatedAt': FieldValue.serverTimestamp()})
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception(
            'Failed to update settings. Please check your internet connection.',
          ),
        );
  }
}

/// Provider for SettingsRepository
final settingsRepositoryProvider =
    Provider<SettingsRepository?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return SettingsRepository(FirebaseFirestore.instance, user.uid);
});
