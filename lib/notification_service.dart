import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'audio_service.dart';

// ==========================================================
// BACKGROUND NOTIFICATION ACTION (LOCK SCREEN / BACKSTAGE)
// ==========================================================

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('BACKGROUND NOTIFICATION ACTION TRIGGERED');
  debugPrint('Action ID: ${notificationResponse.actionId}');

  if (notificationResponse.actionId == NotificationService.stopAzanActionId ||
      notificationResponse.actionId == null) {
    // 1. Local isolate stop
    AudioService.stopAzan();

    // 2. Send signal to Main Isolate where AudioPlayer is playing
    try {
      final SendPort? sendPort =
      IsolateNameServer.lookupPortByName('azan_control_port');
      sendPort?.send('stop_azan');
    } catch (e) {
      debugPrint('Error sending stop to main isolate: $e');
    }

    // 3. Cancel notification banner
    if (notificationResponse.id != null) {
      NotificationService.cancelNotification(notificationResponse.id!);
    } else {
      NotificationService.cancelAllNotifications();
    }
  }
}

// ==========================================================
// NOTIFICATION SERVICE
// ==========================================================

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String channelId = 'prayer_azan_channel_v13';
  static const String channelName = 'Prayer Azan High Priority Alerts V13';
  static const String channelDescription =
      'High priority alarm notifications for all prayer times.';
  static const String stopAzanActionId = 'stop_azan';

  static Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Karachi'));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }

      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Register Isolate listener in main thread
      AudioService.initIsolateListener();

      await requestAutoPermissions();
      await _createNotificationChannel();

      debugPrint('NOTIFICATION SERVICE READY');
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  static Future<void> requestAutoPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      debugPrint('Auto Permission error: $e');
    }
  }

  static Future<void> _createNotificationChannel() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan'),
      enableVibration: true,
      showBadge: true,
    );

    try {
      await androidImplementation.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('Notification channel creation error: $e');
    }
  }

  static NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan'),
      category: AndroidNotificationCategory.alarm,
      enableVibration: true,
      channelShowBadge: true,
      autoCancel: false,
      ongoing: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          stopAzanActionId,
          'STOP AZAN',
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'azan.mp3',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  static Future<void> playAzan() async {
    await AudioService.playAzan();
  }

  static Future<void> stopAzan({int? notificationId}) async {
    await AudioService.stopAzan();
    if (notificationId != null) {
      await cancelNotification(notificationId);
    } else {
      await cancelAllNotifications();
    }
  }

  static bool get isAzanPlaying => AudioService.isPlaying;

  static Future<void> testAzanNotification() async {
    try {
      await stopAzan();
      await _notificationsPlugin.show(
        id: 9999,
        title: '🕌 Test Azan',
        body: 'Prayer time test is active. Tap STOP AZAN to stop.',
        notificationDetails: _notificationDetails(),
        payload: 'test_azan',
      );

      await playAzan();
    } catch (e) {
      debugPrint('TEST AZAN ERROR: $e');
    }
  }

  static Future<void> showPrayerNow({
    required int id,
    required String prayerName,
    required String city,
  }) async {
    try {
      await stopAzan();
      await _notificationsPlugin.show(
        id: id,
        title: '🕌 $prayerName Prayer',
        body: 'It is time for $prayerName prayer in $city.',
        notificationDetails: _notificationDetails(),
        payload: 'prayer_$id',
      );

      await playAzan();
    } catch (e) {
      debugPrint('Show prayer error: $e');
    }
  }

  static Future<void> schedulePrayer({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    required String city,
  }) async {
    try {
      final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      if (!scheduledDate.isAfter(now)) return;

      // Fixed: Removed unsupported parameters to match local notification package version
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: '🕌 $prayerName Prayer',
        body: 'It is time for $prayerName prayer in $city.',
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'prayer_$id',
      );

      debugPrint('Scheduled $prayerName for $scheduledDate with ID $id');
    } catch (e) {
      debugPrint('Schedule prayer error: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (g) {
      debugPrint('Cancel notification error: $g');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notification error: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (response.actionId == stopAzanActionId || response.actionId == null) {
      if (response.id != null) {
        stopAzan(notificationId: response.id);
      } else {
        stopAzan();
      }
    }
  }
}