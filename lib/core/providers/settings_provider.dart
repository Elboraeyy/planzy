import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/isar_provider.dart';
import 'package:planzy/data/database/isar/models/user_settings_isar.dart';

class SettingsNotifier extends AsyncNotifier<UserSettingsIsar> {
  @override
  Future<UserSettingsIsar> build() async {
    return ref.read(isarServiceProvider).getSettings();
  }

  Future<void> updateIncome(double income) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await ref.read(isarServiceProvider).getSettings();
      current.monthlyIncome = income;
      await ref.read(isarServiceProvider).saveSettings(current);
      return current;
    });
  }

  Future<void> updateCurrency(String currency) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await ref.read(isarServiceProvider).getSettings();
      current.currency = currency;
      await ref.read(isarServiceProvider).saveSettings(current);
      return current;
    });
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await ref.read(isarServiceProvider).getSettings();
      current.notificationsEnabled = enabled;
      await ref.read(isarServiceProvider).saveSettings(current);
      return current;
    });
  }

  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await ref.read(isarServiceProvider).getSettings();
      current.hasCompletedOnboarding = true;
      await ref.read(isarServiceProvider).saveSettings(current);
      return current;
    });
  }

  Future<void> completeProfile({
    required String name,
    required String currency,
    required double monthlyIncome,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await ref.read(isarServiceProvider).getSettings();
      current.userName = name;
      current.currency = currency;
      current.monthlyIncome = monthlyIncome;
      current.isProfileComplete = true;
      await ref.read(isarServiceProvider).saveSettings(current);
      return current;
    });
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, UserSettingsIsar>(() {
  return SettingsNotifier();
});
