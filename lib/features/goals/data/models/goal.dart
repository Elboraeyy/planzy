import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

enum GoalPriority {
  low,
  medium,
  high
}

enum GoalReminderInterval {
  none,
  weekly,
  monthly
}

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String title,
    required double targetAmount,
    @Default(0.0) double savedAmount,
    required DateTime targetDate,
    @Default(GoalPriority.medium) GoalPriority priority,
    
    // UI Customization
    @Default('🎯') String iconEmoji,
    @Default('#FFD600') String themeColor, 

    // Vault logic
    String? linkedAccountId,
    @Default(GoalReminderInterval.none) GoalReminderInterval reminderInterval,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
