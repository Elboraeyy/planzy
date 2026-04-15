import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/commitments/data/models/commitment.dart';
import 'package:planzy/features/commitments/data/repository/commitment_repository.dart';

class CommitmentsNotifier extends AsyncNotifier<List<Commitment>> {
  @override
  Future<List<Commitment>> build() async {
    final repo = ref.watch(commitmentRepositoryProvider);
    if (repo == null) return [];
    return repo.getAll();
  }

  Future<void> addCommitment(Commitment commitment) async {
    final repo = ref.read(commitmentRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.add(commitment);
      return repo.getAll();
    });
  }

  Future<void> removeCommitment(String id) async {
    final repo = ref.read(commitmentRepositoryProvider);
    if (repo == null) throw Exception('Repository not available');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.remove(id);
      return repo.getAll();
    });
  }
}

final commitmentsProvider = AsyncNotifierProvider<CommitmentsNotifier, List<Commitment>>(() {
  return CommitmentsNotifier();
});
