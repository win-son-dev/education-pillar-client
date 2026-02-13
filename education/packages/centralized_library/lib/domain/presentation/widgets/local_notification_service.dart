import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  static const String _scheduledChannelId = 'scheduled_channel';
  static const String _scheduledChannelName = 'Scheduled Notifications';
  static const String _scheduledChannelDescription =
      'Reminders and scheduled notifications.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationTap => _tapController.stream;

  Future<void> initializeAsync() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onTapped,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _scheduledChannelId,
          _scheduledChannelName,
          description: _scheduledChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }

    if (kDebugMode) {
      print('🔔 [Local] Initialized');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Show notifications
  // ════════════════════════════════════════════════════════════════

  /// Show an immediate notification (used by FCM foreground handler)
  Future<void> showAsync({
    required int id,
    required String title,
    required String body,
    String? androidIcon,
    Map<String, dynamic>? data,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: androidIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  /// Schedule a notification after a delay.
  /// Uses OS-level scheduling so it fires even if the app is killed.
  /// Calling again with the same [id] replaces the previous schedule.
  Future<void> scheduleAsync({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    Map<String, dynamic>? data,
  }) async {
    // Cancel existing notification with same ID first (reset the timer)
    await _plugin.cancel(id);

    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _scheduledChannelId,
          _scheduledChannelName,
          channelDescription: _scheduledChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: data != null ? jsonEncode(data) : null,
    );

    if (kDebugMode) {
      print('🔔 [Local] Scheduled "$title" (id=$id) at $scheduledTime');
    }
  }

  /// Cancel a specific notification by ID
  Future<void> cancelAsync(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllAsync() async {
    await _plugin.cancelAll();
  }

  // ════════════════════════════════════════════════════════════════
  // Tap handling
  // ════════════════════════════════════════════════════════════════

  void _onTapped(NotificationResponse response) {
    if (response.payload == null) return;

    final payload = response.payload!;
    if (payload.startsWith('{')) {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        _tapController.add(decoded);
        return;
      }
    }

    // Legacy pipe-delimited format
    final map = <String, dynamic>{};
    for (final pair in payload.split('|')) {
      final colonIndex = pair.indexOf(':');
      if (colonIndex > 0) {
        map[pair.substring(0, colonIndex)] = pair.substring(colonIndex + 1);
      }
    }
    _tapController.add(map);
  }

  void dispose() {
    _tapController.close();
  }
}
