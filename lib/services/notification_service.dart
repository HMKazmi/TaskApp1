import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:task_manager/models/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permission on iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // This will be used to navigate to the task detail screen
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await _notificationsPlugin.cancel(taskId.hashCode);
  }
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderTime == null) return;
    
    // Cancel any existing notification for this task
    
    await cancelTaskReminder(task.id);
    
    final now = DateTime.now();
    if (task.reminderTime!.isBefore(now)) return;
    
    // Create notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notification channel for task reminders',
      importance: Importance.high,
      priority: fln.Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Schedule the notification
  //   await _notificationsPlugin.zonedSchedule(
  //     task.id.hashCode,
  //     'Task Reminder: ${task.title}',
  //     task.description,
  //     tz.TZDateTime.from(task.reminderTime!, tz.local),
  //     notificationDetails,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     uiLocalNotificationDateInterpretation:
  //         uiLocalNotificationDateInterpretation.absoluteTime,
  //     payload: task.id,
  //   );
  // }
  await _notificationsPlugin.zonedSchedule(
  task.id.hashCode,
  'Task Reminder: ${task.title}',
  task.description,
  tz.TZDateTime.from(task.reminderTime!, tz.local),
  notificationDetails,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  payload: task.id,
);



}
}