import 'package:planzy/data/database/isar/isar_service.dart';
import 'package:planzy/data/database/isar/models/goal_isar.dart' as isar;
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/isar_provider.dart';

class GoalRepository {
  final IsarService _isarService;

  GoalRepository(this._isarService);

  Future<List<Goal>> getAll() async {
    final list = await _isarService.getAllGoals();
    return list.map((e) => _mapToDomain(e)).toList();
  }

  Future<void> add(Goal goal) async {
    final isarGoal = _mapToIsar(goal);
    await _isarService.saveGoal(isarGoal);
  }

  Future<void> remove(String id) async {
    await _isarService.deleteGoal(id);
  }

  Goal _mapToDomain(isar.GoalIsar e) {
    return Goal(
      id: e.uniqueId,
      title: e.title,
      targetAmount: e.targetAmount,
      savedAmount: e.savedAmount,
      targetDate: e.targetDate,
      priority: GoalPriority.values[e.priority.index],
    );
  }

  isar.GoalIsar _mapToIsar(Goal e) {
    return isar.GoalIsar()
      ..uniqueId = e.id
      ..title = e.title
      ..targetAmount = e.targetAmount
      ..savedAmount = e.savedAmount
      ..targetDate = e.targetDate
      ..priority = isar.GoalPriority.values[e.priority.index];
  }
}

final goalRepositoryProvider = Provider((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return GoalRepository(isarService);
});
