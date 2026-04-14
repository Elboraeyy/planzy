import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/settings/data/models/user_settings.dart';
import 'package:planzy/features/settings/data/repository/settings_repository.dart';

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    if (repo == null) {
      return UserSettings(id: 'temp', userId: '');
    }
    return repo.getSettings();
  }

  Future<void> updateIncome(double income) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(monthlyIncome: income);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> updateCurrency(String currency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(currency: currency);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(notificationsEnabled: enabled);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(hasCompletedOnboarding: true);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> completeProfile({
    required String name,
    required String currency,
    required double monthlyIncome,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(
        userName: name,
        currency: currency,
        monthlyIncome: monthlyIncome,
        isProfileComplete: true,
      );
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> updateProfileImage(String path) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(profileImagePath: path);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> updateName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(userName: name);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> updateBio(String bio) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(userBio: bio);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> updateEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final updated = current.copyWith(userEmail: email);
      await repo.saveSettings(updated);
      return updated;
    });
  }

  Future<void> clearAllData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(settingsRepositoryProvider);
      if (repo == null) throw Exception('Repository not available');
      final current = state.valueOrNull ?? await repo.getSettings();
      final fresh = current.copyWith(
        monthlyIncome: 0.0,
        hasCompletedOnboarding: false,
        isProfileComplete: false,
        userName: '',
        userBio: '',
        profileImagePath: null,
      );
      await repo.saveSettings(fresh);
      return fresh;
    });
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserSettings>(
  () {
  return SettingsNotifier();
});
