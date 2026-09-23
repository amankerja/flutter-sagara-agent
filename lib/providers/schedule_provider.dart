import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../data/models/schedule_model.dart';
import '../data/repositories/sagara_repository.dart';

class ScheduleProvider with ChangeNotifier {
  final SagaraRepository repository;

  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _triggeringScheduleId;
  final Set<String> _notifiedCronKeys = {};

  ScheduleProvider({required this.repository}) {
    fetchSchedules();
  }

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get triggeringScheduleId => _triggeringScheduleId;

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedules = await repository.getSchedules();
      checkAndNotifyApproachingCrons();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void checkAndNotifyApproachingCrons() {
    final now = DateTime.now();
    for (final s in _schedules) {
      if (!s.isActive) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(s.startAt).toLocal();
      } catch (_) {}
      if (dt == null) continue;

      final diff = dt.difference(now);
      // Trigger notification if scheduled within the next 60 minutes
      if (diff.inSeconds > 0 && diff.inMinutes <= 60) {
        final key = '${s.id}_${dt.day}_${dt.hour}_${dt.minute}';
        if (!_notifiedCronKeys.contains(key)) {
          _notifiedCronKeys.add(key);
          String timeText = '00:00';
          if (s.startAt.length >= 16 && s.startAt.contains('T')) {
            timeText = s.startAt.substring(11, 16);
          } else {
            timeText = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          }
          NotificationService.instance.triggerCronReminder(
            cronId: s.id,
            title: s.title,
            timeText: timeText,
            agentName: s.agentName.isNotEmpty ? s.agentName : s.agentId,
            minutesRemaining: diff.inMinutes,
          );
        }
      }
    }
  }

  Future<void> sendTestCronNotification() async {
    final now = DateTime.now();
    final testTime = now.add(const Duration(minutes: 5));
    final timeText = '${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}';
    await NotificationService.instance.triggerCronReminder(
      cronId: 'cron-test-notification',
      title: 'fb-page-comment-engagement',
      timeText: timeText,
      agentName: 'Marketing',
      minutesRemaining: 5,
    );
  }

  Future<bool> triggerNow(String scheduleId) async {
    _triggeringScheduleId = scheduleId;
    notifyListeners();

    try {
      final success = await repository.triggerScheduleNow(scheduleId);
      if (success) {
        final index = _schedules.indexWhere((s) => s.id == scheduleId);
        if (index != -1) {
          _schedules[index] = _schedules[index].copyWith(status: 'RUNNING');
        }
      }
      return success;
    } finally {
      _triggeringScheduleId = null;
      notifyListeners();
    }
  }

  Future<bool> triggerScheduleNow(String scheduleId) => triggerNow(scheduleId);
  Future<bool> triggerSchedule(String scheduleId) => triggerNow(scheduleId);
}
