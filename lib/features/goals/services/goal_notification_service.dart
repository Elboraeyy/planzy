import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class GoalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  static Future<void> scheduleGoalReminder(Goal goal) async {
    await initialize();
    await cancelReminder(goal.id);

    if (goal.reminderInterval == GoalReminderInterval.none) return;

    final notificationId = goal.id.hashCode.abs() % 2147483647;
    
    // Pick next scheduled time at 10:00 AM
    var nextDate = DateTime.now();
    nextDate = DateTime(nextDate.year, nextDate.month, nextDate.day, 10, 0);

    DateTimeComponents? matchTime;

    if (goal.reminderInterval == GoalReminderInterval.weekly) {
      nextDate = nextDate.add(const Duration(days: 7));
      matchTime = DateTimeComponents.dayOfWeekAndTime;
    } else if (goal.reminderInterval == GoalReminderInterval.monthly) {
      nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day, 10, 0);
      matchTime = DateTimeComponents.dayOfMonthAndTime;
    }

    final tzReminderDate = tz.TZDateTime.from(nextDate, tz.local);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: '${goal.iconEmoji} Time to fund: ${goal.title}!',
      body: 'Keep the momentum going! Tap to add some money to your goal today.',
      scheduledDate: tzReminderDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminders',
          'Goal Reminders',
          channelDescription: 'Reminders to add money to your goals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: matchTime,
    );
  }

  static Future<void> cancelReminder(String goalId) async {
    await initialize();
    final notificationId = goalId.hashCode.abs() % 2147483647;
    await _plugin.cancel(id: notificationId);
  }
}

final goalNotificationServiceProvider = Provider((ref) {
  return GoalNotificationService();
});
