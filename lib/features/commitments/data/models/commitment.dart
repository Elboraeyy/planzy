import 'package:freezed_annotation/freezed_annotation.dart';

part 'commitment.freezed.dart';
part 'commitment.g.dart';

enum RepeatType {
  weekly,
  monthly,
  yearly,
  custom
}

@freezed
class Commitment with _$Commitment {
  const factory Commitment({
    required String id,
    required String title,
    required double amount,
    required RepeatType repeatType,
    required DateTime startDate,
    DateTime? endDate,
    required String category,
    @Default(true) bool reminderEnabled,
  }) = _Commitment;

  factory Commitment.fromJson(Map<String, dynamic> json) => _$CommitmentFromJson(json);
}
