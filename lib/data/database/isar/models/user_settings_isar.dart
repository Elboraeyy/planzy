import 'package:isar/isar.dart';

part 'user_settings_isar.g.dart';

@collection
class UserSettingsIsar {
  Id id = 1; // singleton
  
  double? monthlyIncome;
  
  String currency = 'EGP';
  
  bool notificationsEnabled = true;
  
  bool hasCompletedOnboarding = false;

  String? userName;
  
  bool isProfileComplete = false;

  UserSettingsIsar();
}
