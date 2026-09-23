import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _channelId = 'sagara_critical_channel';
  static const String _channelName = 'Sagara Critical Approval Alerts';
  static const String _channelDesc = 'Alerts for high-risk autonomous agent actions requiring human approval';

  static const String _cronChannelId = 'sagara_cron_channel';
  static const String _cronChannelName = 'Sagara Cron Job Reminders';
  static const String _cronChannelDesc = 'Pemberitahuan otomatis saat jadwal cronjob mendekati waktu eksekusi';

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Can handle deep link to approvals or schedule screen
        },
      );

      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        const androidChannel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

        const cronChannel = AndroidNotificationChannel(
          _cronChannelId,
          _cronChannelName,
          description: _cronChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidImplementation.createNotificationChannel(androidChannel);
        await androidImplementation.createNotificationChannel(cronChannel);
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (_) {
      // Fallback if running on desktop or test environment
    }
  }

  Future<void> triggerCronReminder({
    required String cronId,
    required String title,
    required String timeText,
    required String agentName,
    int minutesRemaining = 0,
  }) async {
    // 1. Play tactile feedback
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}

    // 2. Post Android notification
    try {
      final androidDetails = AndroidNotificationDetails(
        _cronChannelId,
        _cronChannelName,
        channelDescription: _cronChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Sagara Cron: $title',
        styleInformation: BigTextStyleInformation(
          'Jadwal tugas "$title" oleh agen $agentName akan dieksekusi pada $timeText WIB (dalam $minutesRemaining menit).',
          contentTitle: '⏰ Cron Mendekati Jadwal: $title',
          summaryText: 'Pemberitahuan Cron Otomatis',
        ),
      );

      final notificationDetails = NotificationDetails(android: androidDetails);
      final id = cronId.hashCode.abs() % 100000;
      await _notificationsPlugin.show(
        id: id,
        title: '⏰ Cron Job Mendekati: $title',
        body: '$title ($agentName) dijadwalkan pukul $timeText WIB (dalam $minutesRemaining m)',
        notificationDetails: notificationDetails,
      );
    } catch (_) {}
  }

  Future<void> triggerHighRiskAlert({
    required String title,
    required String body,
    required String risk,
    String? payload,
  }) async {
    // 1. Play immediate system audible alarm sound and heavy tactile haptic pattern
    try {
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (_) {}

    // 2. Post high-priority Android notification with sound and vibration
    try {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Sagara High Risk Alert: $title',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: '[$risk RISK] $title',
          summaryText: 'Persetujuan Diperlukan',
        ),
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      await _notificationsPlugin.show(
        id: id,
        title: '[$risk RISK] $title',
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (_) {}
  }
}
