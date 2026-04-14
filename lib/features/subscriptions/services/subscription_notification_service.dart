import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class SubscriptionNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification plugin
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

  /// Request notification permissions (Android 13+)
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule a reminder for a subscription renewal
  static Future<void> scheduleRenewalReminder(Subscription sub) async {
    await initialize();

    // Cancel any existing notification for this subscription
    await cancelReminder(sub.id);

    if (!sub.isActive || sub.reminderDaysBefore <= 0) return;

    final reminderDate = sub.nextRenewalDate.subtract(
      Duration(days: sub.reminderDaysBefore),
    );

    // Don't schedule if the reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) return;

    final tzReminderDate = tz.TZDateTime.from(reminderDate, tz.local);

    final notificationId = sub.id.hashCode.abs() % 2147483647;

    await _plugin.zonedSchedule(
      id: notificationId,
      title: '🔄 ${sub.name} Renewal Coming!',
      body:
          '${sub.name} renews in ${sub.reminderDaysBefore} days — ${sub.amount} ${sub.currency}',
      scheduledDate: tzReminderDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription: 'Reminders for upcoming subscription renewals',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            '${sub.name} renews in ${sub.reminderDaysBefore} days.\nAmount: ${sub.amount} ${sub.currency}\nCycle: ${sub.cycle.displayName}',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancel a scheduled reminder
  static Future<void> cancelReminder(String subscriptionId) async {
    await initialize();
    final notificationId = subscriptionId.hashCode.abs() % 2147483647;
    await _plugin.cancel(id: notificationId);
  }

  /// Reschedule all active subscription reminders
  static Future<void> rescheduleAll(List<Subscription> subscriptions) async {
    await initialize();
    await _plugin.cancelAll();

    for (final sub in subscriptions) {
      if (sub.isActive) {
        await scheduleRenewalReminder(sub);
      }
    }
  }
}

/// Provider for the notification service
final subscriptionNotificationServiceProvider = Provider((ref) {
  return SubscriptionNotificationService();
});
