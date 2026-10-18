import 'dart:isolate';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

import 'audio_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('BACKGROUND NOTIFICATION ACTION TRIGGERED');
  debugPrint('Action ID: ${notificationResponse.actionId}');

  if (notificationResponse.actionId == NotificationService.stopAzanActionId ||
      notificationResponse.actionId == null) {

    try {
      final SendPort? sendPort = IsolateNameServer.lookupPortByName('azan_control_port');
      sendPort?.send('stop_azan');
    } catch (e) {
      debugPrint('Error sending stop to main isolate: $e');
    }

    try {
      if (notificationResponse.id != null) {
        NotificationService.cancelNotification(notificationResponse.id!);
      } else {
        NotificationService.cancelAllNotifications();
      }
    } catch (e) {
      debugPrint('Error cancelling notification in background: $e');
    }
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Naya channel ID v16 taake Android purani silent setting bhool jaye
  static const String channelId = 'prayer_azan_channel_v16';
  static const String channelName = 'Prayer Azan High Priority Alerts V16';
  static const String channelDescription =
      'High priority notifications that respect device sound profile.';
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

      AudioService.initIsolateListener();

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
      // Yahan se battery optimization ka code mukammal delete kar diya gaya hai
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

  static Future<bool> isPrayerMuted(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final bool globalAlerts = prefs.getBool('prayer_notifications') ?? true;
    if (!globalAlerts) return true;
    return prefs.getBool('mute_$prayerName') ?? false;
  }

  static Future<bool> isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibration_enabled') ?? true;
  }

  static Future<void> playAzan(String prayerName) async {
    final bool muted = await isPrayerMuted(prayerName);
    if (muted) {
      debugPrint('$prayerName is muted. Skipping Azan audio.');
      return;
    }

    try {
      RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;

      if (ringerStatus == RingerModeStatus.silent) {
        debugPrint('Phone is on SILENT. No Audio, No Vibration.');
        return;
      } else if (ringerStatus == RingerModeStatus.vibrate) {
        debugPrint('Phone is on VIBRATE. OS will vibrate, No Azan Audio.');
        return;
      }
    } catch (e) {
      debugPrint('Could not check sound mode (Assuming Normal): $e');
    }

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

  static Future<void> showPrayerNow({
    required int id,
    required String prayerName,
    required String city,
  }) async {
    try {
      final bool muted = await isPrayerMuted(prayerName);
      if (muted) {
        debugPrint('$prayerName is muted. Suppressing notification.');
        return;
      }

      await stopAzan();

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('azan'),
        category: AndroidNotificationCategory.alarm, // Yahan 'reminder' ki jagah 'alarm' kar diya hai
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 2000]),
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

      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'azan.mp3',
      );

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id: id,
        title: '🕌 $prayerName Prayer',
        body: 'It is time for $prayerName prayer in $city.',
        notificationDetails: details,
        payload: 'prayer_$id',
      );

      await playAzan(prayerName);
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

      final bool muted = await isPrayerMuted(prayerName);
      if (muted) {
        debugPrint('$prayerName is muted. Skipping scheduling.');
        await cancelNotification(id);
        return;
      }

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('azan'),
        category: AndroidNotificationCategory.alarm, // Yahan bhi 'alarm' kar diya hai
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 2000]),
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

      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'azan.mp3',
      );

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: '🕌 $prayerName Prayer',
        body: 'It is time for $prayerName prayer in $city.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
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