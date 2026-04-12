import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

enum GoalPriority {
  low,
  medium,
  high
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
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
