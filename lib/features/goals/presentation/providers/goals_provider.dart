import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:planzy/features/goals/data/repository/goal_repository.dart';

class GoalsNotifier extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    return ref.read(goalRepositoryProvider).getAll();
  }

  Future<void> addGoal(Goal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(goalRepositoryProvider).add(goal);
      return ref.read(goalRepositoryProvider).getAll();
    });
  }

  Future<void> removeGoal(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(goalRepositoryProvider).remove(id);
      return ref.read(goalRepositoryProvider).getAll();
    });
  }

  Future<void> updateGoalProgress(String id, double addedAmount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(goalRepositoryProvider);
      final all = await repo.getAll();
      final goal = all.firstWhere((e) => e.id == id);
      final updatedGoal = goal.copyWith(savedAmount: goal.savedAmount + addedAmount);
      await repo.add(updatedGoal); // .add handles put (update)
      return repo.getAll();
    });
  }
}

final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<Goal>>(() {
  return GoalsNotifier();
});
