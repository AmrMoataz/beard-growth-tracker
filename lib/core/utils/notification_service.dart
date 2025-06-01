import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling local notifications in the application
/// Provides functionality for scheduling daily reminders and showing immediate notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel and notification IDs
  static const String _morningChannelId = 'morning_reminder_channel';
  static const String _eveningChannelId = 'evening_reminder_channel';
  static const int _morningNotificationId = 1;
  static const int _eveningNotificationId = 2;

  NotificationService();

  /// Initialize the notification service
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Initialize Android settings with our custom beard icon
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings for various platforms
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Request permissions
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission for Android 13+ (API level 33)
      await androidPlugin?.requestNotificationsPermission();

      // Check and request exact alarm permission for Android 12+ (API level 31+)
      final bool? hasExactAlarmPermission =
          await androidPlugin?.canScheduleExactNotifications();
      if (hasExactAlarmPermission == false) {
        // On Android 12+, we need to request the user to grant exact alarm permission
        // This opens system settings where the user can grant the permission
        await androidPlugin?.requestExactAlarmsPermission();
        debugPrint(
            'Requested exact alarms permission. User needs to grant it manually.');
      }
    }

    // Create notification channels for Android
    await _createNotificationChannels();

    debugPrint('Notification service initialized');
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      // Morning reminder channel
      const AndroidNotificationChannel morningChannel =
          AndroidNotificationChannel(
        _morningChannelId,
        'Morning Reminders',
        description: 'Channel for morning progress tracking reminders',
        importance: Importance.high,
      );

      // Evening reminder channel
      const AndroidNotificationChannel eveningChannel =
          AndroidNotificationChannel(
        _eveningChannelId,
        'Evening Reminders',
        description: 'Channel for evening progress tracking reminders',
        importance: Importance.high,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(morningChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(eveningChannel);
    }
  }

  /// Schedule daily reminders at specified hours
  Future<void> scheduleDailyReminders(int morningHour, int eveningHour) async {
    // Cancel any existing notifications first
    await cancelAllNotifications();

    // Schedule morning reminder
    await _scheduleDaily(
      id: _morningNotificationId,
      hour: morningHour,
      minute: 0,
      title: 'Morning Progress Check',
      body: 'Time to check in and update your progress!',
      channelId: _morningChannelId,
    );

    // Schedule evening reminder
    await _scheduleDaily(
      id: _eveningNotificationId,
      hour: eveningHour,
      minute: 0,
      title: 'Evening Progress Update',
      body: "Don't forget to update your progress for today!",
      channelId: _eveningChannelId,
    );

    debugPrint(
        'Daily reminders scheduled for $morningHour:00 and $eveningHour:00');
  }

  /// Schedule a daily notification at a specific time
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelId,
  }) async {
    // Get current date and time
    final now = tz.TZDateTime.now(tz.local);
    // Create the scheduled time for today
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelId == _morningChannelId
          ? 'Morning Reminders'
          : 'Evening Reminders',
      channelDescription: 'Channel for progress tracking reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    final DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      // First try with exact timing (requires permission on Android 12+)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Scheduled exact notification for $hour:$minute');
    } catch (e) {
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint(
            'Exact alarms not permitted, falling back to inexact scheduling');
        // Fall back to inexact scheduling if exact timing is not permitted
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint('Scheduled inexact notification for $hour:$minute');
      } else {
        // Re-throw other errors
        debugPrint('Error scheduling notification: $e');
        rethrow;
      }
    }
  }

  /// Send an immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _morningChannelId, // Using morning channel for immediate notifications
      'Immediate Notification',
      channelDescription: 'Channel for immediate notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Use a unique ID for immediate notifications
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// For iOS notifications received while app is in foreground (iOS < 10)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('Received notification: $title');
    // Handle iOS notification when app is in foreground
  }

  /// Notification response handler
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification response received: ${response.payload}');
    // Handle notification response (e.g., navigate to a specific screen)
  }
}
