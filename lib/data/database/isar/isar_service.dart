import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planzy/data/database/isar/models/commitment_isar.dart';
import 'package:planzy/data/database/isar/models/goal_isar.dart';
import 'package:planzy/data/database/isar/models/user_settings_isar.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [CommitmentIsarSchema, GoalIsarSchema, UserSettingsIsarSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Generic Save
  Future<void> saveCommitment(CommitmentIsar commitment) async {
    final isar = await db;
    await isar.writeTxn(() => isar.commitmentIsars.put(commitment));
  }

  Future<List<CommitmentIsar>> getAllCommitments() async {
    final isar = await db;
    return await isar.commitmentIsars.where().findAll();
  }

  Future<void> saveGoal(GoalIsar goal) async {
    final isar = await db;
    await isar.writeTxn(() => isar.goalIsars.put(goal));
  }

  Future<List<GoalIsar>> getAllGoals() async {
    final isar = await db;
    return await isar.goalIsars.where().findAll();
  }

  Future<void> deleteCommitment(String uniqueId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.commitmentIsars.filter().uniqueIdEqualTo(uniqueId).deleteAll();
    });
  }

  Future<void> deleteGoal(String uniqueId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.goalIsars.filter().uniqueIdEqualTo(uniqueId).deleteAll();
    });
  }

  Future<void> saveSettings(UserSettingsIsar settings) async {
    final isar = await db;
    await isar.writeTxn(() => isar.userSettingsIsars.put(settings));
  }

  Future<UserSettingsIsar> getSettings() async {
    final isar = await db;
    final settings = await isar.userSettingsIsars.get(1);
    return settings ?? UserSettingsIsar();
  }
}
