import 'package:isar/isar.dart';

part 'goal_isar.g.dart';

@collection
class GoalIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uniqueId; // correspond to Freezed string id
  
  late String title;
  
  late double targetAmount;
  
  double savedAmount = 0.0;
  
  late DateTime targetDate;
  
  @enumerated
  GoalPriority priority = GoalPriority.medium;

  GoalIsar();
}

enum GoalPriority { low, medium, high }
