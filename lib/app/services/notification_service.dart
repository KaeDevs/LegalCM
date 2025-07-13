// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final _notifications = FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     await _notifications
//     .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//     ?.requestExactAlarmsPermission();

//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: android);
//     await _notifications.initialize(settings);

//     tz.initializeTimeZones();
//   }

//   static Future<void> scheduleNotification({
//   required int id,
//   required String title,
//   required String body,
//   required DateTime scheduledDate,
// }) async {
//   if (scheduledDate.isBefore(DateTime.now())) {
//     print("Scheduled time is in the past. Notification not set.");
//     return;
//   }

//   await _notifications.zonedSchedule(
//     id,
//     title,
//     body,
//     tz.TZDateTime.from(scheduledDate, tz.local),
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'task_channel',
//         'Task Reminders',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     ),
//     androidScheduleMode: AndroidScheduleMode.exact,
//     matchDateTimeComponents: DateTimeComponents.dateAndTime,

//   );
// }

//   static Future<void> cancelNotification(int id) async {
//     await _notifications.cancel(id);
//   }
// }
