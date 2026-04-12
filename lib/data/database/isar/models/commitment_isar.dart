import 'package:isar/isar.dart';

part 'commitment_isar.g.dart';

@collection
class CommitmentIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uniqueId; // corresponds to string id in Freezed model

  late String title;
  
  late double amount;
  
  @enumerated
  late RepeatType repeatType;
  
  late DateTime startDate;
  
  DateTime? endDate;
  
  late String category;
  
  bool reminderEnabled = true;

  CommitmentIsar();
}

enum RepeatType { weekly, monthly, yearly, custom }
