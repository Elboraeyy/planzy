import 'package:planzy/data/database/isar/isar_service.dart';
import 'package:planzy/data/database/isar/models/commitment_isar.dart' as isar;
import 'package:planzy/features/commitments/data/models/commitment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/providers/isar_provider.dart';

class CommitmentRepository {
  final IsarService _isarService;

  CommitmentRepository(this._isarService);

  Future<List<Commitment>> getAll() async {
    final list = await _isarService.getAllCommitments();
    return list.map((e) => _mapToDomain(e)).toList();
  }

  Future<void> add(Commitment commitment) async {
    final isarCommitment = _mapToIsar(commitment);
    await _isarService.saveCommitment(isarCommitment);
  }

  Future<void> remove(String id) async {
    await _isarService.deleteCommitment(id);
  }

  Commitment _mapToDomain(isar.CommitmentIsar e) {
    return Commitment(
      id: e.uniqueId,
      title: e.title,
      amount: e.amount,
      repeatType: RepeatType.values[e.repeatType.index],
      startDate: e.startDate,
      endDate: e.endDate,
      category: e.category,
      reminderEnabled: e.reminderEnabled,
    );
  }

  isar.CommitmentIsar _mapToIsar(Commitment e) {
    return isar.CommitmentIsar()
      ..uniqueId = e.id
      ..title = e.title
      ..amount = e.amount
      ..repeatType = isar.RepeatType.values[e.repeatType.index]
      ..startDate = e.startDate
      ..endDate = e.endDate
      ..category = e.category
      ..reminderEnabled = e.reminderEnabled;
  }
}

final commitmentRepositoryProvider = Provider((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return CommitmentRepository(isarService);
});
