import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/commitments/data/models/commitment.dart';
import 'package:planzy/features/commitments/data/repository/commitment_repository.dart';

class CommitmentsNotifier extends AsyncNotifier<List<Commitment>> {
  @override
  Future<List<Commitment>> build() async {
    return ref.read(commitmentRepositoryProvider).getAll();
  }

  Future<void> addCommitment(Commitment commitment) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(commitmentRepositoryProvider).add(commitment);
      return ref.read(commitmentRepositoryProvider).getAll();
    });
  }

  Future<void> removeCommitment(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(commitmentRepositoryProvider).remove(id);
      return ref.read(commitmentRepositoryProvider).getAll();
    });
  }
}

final commitmentsProvider = AsyncNotifierProvider<CommitmentsNotifier, List<Commitment>>(() {
  return CommitmentsNotifier();
});
