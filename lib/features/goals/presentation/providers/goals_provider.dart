import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:planzy/features/goals/data/repository/goal_repository.dart';

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    final repo = ref.watch(goalRepositoryProvider);
    if (repo == null) return [];
    return repo.getAll();
  }

  Future<void> addGoal(Goal goal) async {
    final repo = ref.read(goalRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.add(goal);
      return repo.getAll();
    });
  }

  Future<void> removeGoal(String id) async {
    final repo = ref.read(goalRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.remove(id);
      return repo.getAll();
    });
  }

  Future<void> updateGoalProgress(String id, double addedAmount) async {
    final repo = ref.read(goalRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final all = await repo.getAll();
      final goal = all.firstWhere((e) => e.id == id);
      await repo.updateSavedAmount(id, goal.savedAmount + addedAmount);
      return repo.getAll();
    });
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(() {
  return GoalsNotifier();
});
