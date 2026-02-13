import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'local_notification_service.dart';

/// Top-level background message handler for FCM.
/// Must be registered in main() before runApp():
/// ```dart
/// FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
/// ```
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('🔔 [FCM] 📩 Background message: ${message.notification?.title}');
  }
}

class FirebaseNotificationService {
  // FCM topic constants
  static const String topicAllUsers = 'all_users';
  static const String topicCampaigns = 'campaigns';
  static const String topicEvents = 'events';
  static const String topicNews = 'news';
  static const String topicReEngagement = 're_engagement';
  static const String topicSportPrefix = 'sport_';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _pendingTokenRetrieval = false;

  String _currentLocale = 'en';
  String get currentLocale => _currentLocale;

  FirebaseNotificationService({
    required LocalNotificationService localNotificationService,
  }) : _localNotificationService = localNotificationService;

  void setLocale(String languageCode) {
    _currentLocale = languageCode;
    if (kDebugMode) {
      print('🔔 [FCM] Locale set to: $languageCode');
    }
  }

  final _notificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationTap =>
      _notificationTapController.stream;

  // ════════════════════════════════════════════════════════════════
  // Initialization
  // ════════════════════════════════════════════════════════════════

  Future<void> initializeAsync() async {
    if (kDebugMode) {
      print('🔔 [FCM] Initializing (${Platform.operatingSystem})...');
    }

    final permissionGranted = await requestPermissionAsync();
    if (kDebugMode) {
      print('🔔 [FCM] Permission: ${permissionGranted ? "granted" : "denied"}');
    }

    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await _getTokenAsync();
    _setupTokenRefreshListener();
    _setupMessageHandlers();

    if (kDebugMode) {
      print('🔔 [FCM] Initialization complete');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Permission handling
  // ════════════════════════════════════════════════════════════════

  /// Request notification permission (shows native OS dialog)
  Future<bool> requestPermissionAsync() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (kDebugMode) {
        print('🔔 [FCM] Android permission: $status');
      }
      return status.isGranted;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('🔔 [FCM] iOS permission: ${settings.authorizationStatus}');
    }
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Check current permission status without prompting user
  Future<bool> isPermissionGrantedAsync() async {
    if (Platform.isAndroid) {
      return (await Permission.notification.status).isGranted;
    }

    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Called when app resumes - retrieves token if permission was granted while away
  Future<void> refreshTokenIfNeededAsync() async {
    final isAuthorized = await isPermissionGrantedAsync();

    if (isAuthorized && (_fcmToken == null || _pendingTokenRetrieval)) {
      _pendingTokenRetrieval = false;
      await _getTokenAsync();
      if (kDebugMode) {
        print('🔔 [FCM] Token refreshed on resume: ${_fcmToken != null ? "success" : "failed"}');
      }
    }
  }

  /// Open device notification settings
  Future<bool> openNotificationSettingsAsync() async {
    return openAppSettings();
  }

  // ════════════════════════════════════════════════════════════════
  // Token management
  // ════════════════════════════════════════════════════════════════

  Future<void> _getTokenAsync() async {
    if (Platform.isIOS) {
      String? apnsToken = await _messaging.getAPNSToken();

      if (apnsToken == null) {
        for (int i = 0; i < 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
        }
      }

      if (apnsToken == null) {
        if (kDebugMode) {
          print('🔔 [FCM] APNS token not available (simulator or config issue)');
        }
        _pendingTokenRetrieval = true;
        return;
      }
    }

    _fcmToken = await _messaging.getToken();
    if (kDebugMode) {
      print('🔔 [FCM] Token: ${_fcmToken != null ? "received" : "null"}');
    }
  }

  void _setupTokenRefreshListener() {
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        print('🔔 [FCM] Token refreshed');
      }
    });
  }

  Future<void> deleteTokenAsync() async {
    await _messaging.deleteToken();
    _fcmToken = null;
  }

  // ════════════════════════════════════════════════════════════════
  // Message handling
  // ════════════════════════════════════════════════════════════════

  void _setupMessageHandlers() {
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print('🔔 [FCM] Foreground: ${message.notification?.title}');
      }
      _handleForegroundMessageAsync(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _notificationTapController.add(message.data);
      }
    });

    _messageOpenedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        print('🔔 [FCM] Notification tapped: ${message.notification?.title}');
      }
      _notificationTapController.add(message.data);
    });
  }

  Future<void> _handleForegroundMessageAsync(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = _getLocalizedContent(
      data: data,
      localizedKey: 'titleKm',
      defaultKey: 'title',
      notificationValue: notification?.title,
    );

    final body = _getLocalizedContent(
      data: data,
      localizedKey: 'bodyKm',
      defaultKey: 'body',
      notificationValue: notification?.body,
    );

    if (title == null && body == null) return;

    await _localNotificationService.showAsync(
      id: notification?.hashCode ?? message.messageId.hashCode,
      title: title ?? '',
      body: body ?? '',
      androidIcon: notification?.android?.smallIcon,
      data: data,
    );

    if (kDebugMode) {
      print('🔔 [FCM] Displayed: $title');
    }
  }

  String? _getLocalizedContent({
    required Map<String, dynamic> data,
    required String localizedKey,
    required String defaultKey,
    String? notificationValue,
  }) {
    if (_currentLocale == 'km') {
      final localizedValue = data[localizedKey] as String?;
      if (localizedValue != null && localizedValue.isNotEmpty) {
        return localizedValue;
      }
    }

    final defaultValue = data[defaultKey] as String?;
    if (defaultValue != null && defaultValue.isNotEmpty) {
      return defaultValue;
    }

    return notificationValue;
  }

  // ════════════════════════════════════════════════════════════════
  // Topic subscriptions
  // ════════════════════════════════════════════════════════════════

  Future<void> subscribeToTopicAsync(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopicAsync(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> subscribeToSportAsync(String sportId) async {
    await subscribeToTopicAsync('$topicSportPrefix$sportId');
    if (kDebugMode) {
      print('Subscribed to FCM topic: $topicSportPrefix$sportId');
    }
  }

  Future<void> unsubscribeFromSportAsync(String sportId) async {
    await unsubscribeFromTopicAsync('$topicSportPrefix$sportId');
    if (kDebugMode) {
      print('Unsubscribed from FCM topic: $topicSportPrefix$sportId');
    }
  }

  Future<void> subscribeToSportsAsync(List<String> sportIds) async {
    for (final id in sportIds) {
      await subscribeToSportAsync(id);
    }
  }

  Future<void> unsubscribeFromSportsAsync(List<String> sportIds) async {
    for (final id in sportIds) {
      await unsubscribeFromSportAsync(id);
    }
  }

  Future<void> syncInterestsToTopicsAsync(List<String> interests) async {
    await subscribeToSportsAsync(interests);
    if (kDebugMode) {
      print('Synced ${interests.length} interests to FCM topics');
    }
  }

  Future<void> subscribeToCampaignsAsync() async {
    await subscribeToTopicAsync(topicCampaigns);
    if (kDebugMode) {
      print('Subscribed to FCM topic: $topicCampaigns');
    }
  }

  Future<void> unsubscribeFromCampaignsAsync() async {
    await unsubscribeFromTopicAsync(topicCampaigns);
    if (kDebugMode) {
      print('Unsubscribed from FCM topic: $topicCampaigns');
    }
  }

  Future<void> subscribeToEventsAsync() async {
    await subscribeToTopicAsync(topicEvents);
    if (kDebugMode) {
      print('Subscribed to FCM topic: $topicEvents');
    }
  }

  Future<void> unsubscribeFromEventsAsync() async {
    await unsubscribeFromTopicAsync(topicEvents);
    if (kDebugMode) {
      print('Unsubscribed from FCM topic: $topicEvents');
    }
  }

  Future<void> subscribeToNewsAsync() async {
    await subscribeToTopicAsync(topicNews);
    if (kDebugMode) {
      print('Subscribed to FCM topic: $topicNews');
    }
  }

  Future<void> unsubscribeFromNewsAsync() async {
    await unsubscribeFromTopicAsync(topicNews);
    if (kDebugMode) {
      print('Unsubscribed from FCM topic: $topicNews');
    }
  }

  Future<void> subscribeToReEngagementAsync() async {
    await subscribeToTopicAsync(topicReEngagement);
    if (kDebugMode) {
      print('Subscribed to FCM topic: $topicReEngagement');
    }
  }

  Future<void> subscribeToBaseTopicsAsync() async {
    await subscribeToTopicAsync(topicAllUsers);
    await subscribeToReEngagementAsync();
    if (kDebugMode) {
      print('Subscribed to base FCM topics: $topicAllUsers, $topicReEngagement');
    }
  }

  Future<void> unsubscribeFromBaseTopicsAsync() async {
    await unsubscribeFromTopicAsync(topicAllUsers);
    await unsubscribeFromTopicAsync(topicReEngagement);
    if (kDebugMode) {
      print('Unsubscribed from base FCM topics: $topicAllUsers, $topicReEngagement');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Cleanup
  // ════════════════════════════════════════════════════════════════

  void dispose() {
    _foregroundSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _notificationTapController.close();
  }
}