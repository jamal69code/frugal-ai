import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:universal_io/io.dart';

/// ⏰ Reminder System Service (Feature 9)
/// Handles daily expense entry reminders and bill payment notifications
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();

  factory ReminderService() {
    return _instance;
  }

  ReminderService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  static const String dailyReminderTask = 'dailyExpenseReminder';
  static const String billReminderTask = 'billPaymentReminder';

  /// Initialize the reminder service
  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android setup
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS setup
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // Initialize workmanager for background tasks
    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().initialize(callbackDispatcher);
    }
  }

  /// Schedule daily expense entry reminder
  /// [hourOfDay] - Hour (0-23) when reminder should be sent
  /// [minuteOfDay] - Minute (0-59) when reminder should be sent
  Future<void> scheduleDailyExpenseReminder({
    required int hourOfDay,
    required int minuteOfDay,
  }) async {
    await Workmanager().registerPeriodicTask(
      dailyReminderTask,
      dailyReminderTask,
      frequency: const Duration(days: 1),
      initialDelay: _calculateInitialDelay(hourOfDay, minuteOfDay),
      constraints: Constraints(
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        networkType: NetworkType.not_required,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );

    print('✅ Daily expense reminder scheduled for $hourOfDay:$minuteOfDay');
  }

  /// Schedule bill payment reminders
  /// [billName] - Name of the bill (e.g., "Electricity Bill")
  /// [dayOfMonth] - Day of month when reminder should be sent
  /// [hourOfDay] - Hour when reminder should be sent
  Future<void> scheduleBillReminder({
    required String billName,
    required int dayOfMonth,
    required int hourOfDay,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'bill_reminders',
          'Bill Reminders',
          channelDescription: 'Reminders for bill payments',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification (This is a simple implementation)
    // For production, integrate with a backend service or use more sophisticated scheduling
    await _notificationsPlugin.show(
      billName.hashCode,
      'Bill Payment Reminder',
      '$billName is due this month',
      notificationDetails,
    );

    print('📬 Bill reminder added for $billName');
  }

  /// Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'frugal_ai_notifications',
          'Frugal AI Notifications',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await Workmanager().cancelAll();
    await _notificationsPlugin.cancelAll();
    print('🛑 All reminders cancelled');
  }

  /// Cancel specific reminder
  Future<void> cancelReminder(String taskId) async {
    await Workmanager().cancelByTag(taskId);
    print('🛑 Reminder cancelled: $taskId');
  }

  /// Calculate initial delay for workmanager task
  Duration _calculateInitialDelay(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate.difference(now);
  }

  /// Send expense alert when near budget limit
  Future<void> sendBudgetAlert({
    required String category,
    required double spent,
    required double limit,
    required double percentage,
  }) async {
    String title = 'Budget Alert ⚠️';
    String body;

    if (percentage > 100) {
      body =
          '$category budget exceeded! Spent ₹$spent / ₹$limit (${percentage.toStringAsFixed(1)}%)';
    } else {
      body =
          '$category budget warning! Spent ₹$spent / ₹$limit (${percentage.toStringAsFixed(1)}%)';
    }

    await showNotification(title: title, body: body);
  }

  /// Send monthly spending prediction alert
  Future<void> sendSpendingPredictionAlert({
    required double predictedTotal,
    required double avgPerDay,
  }) async {
    await showNotification(
      title: '📊 Monthly Spending Forecast',
      body:
          'Your predicted spending: ₹${predictedTotal.toStringAsFixed(2)} (Avg: ₹${avgPerDay.toStringAsFixed(2)}/day)',
    );
  }
}

/// Callback dispatcher for background tasks
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print('🔔 Background task executed: $taskName');

    if (taskName == 'dailyExpenseReminder') {
      await ReminderService().showNotification(
        title: '💰 Expense Reminder',
        body: 'Have you logged your expenses today?',
      );
    }

    return Future.value(true);
  });
}
