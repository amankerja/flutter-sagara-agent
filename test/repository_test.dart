import 'package:flutter_test/flutter_test.dart';
import 'package:sagara_mobile/data/repositories/sagara_repository.dart';

void main() {
  group('SagaraRepository Unit Tests', () {
    late SagaraRepository repository;

    setUp(() {
      repository = SagaraRepository(isMockMode: true);
    });

    test('getAgents returns 9 canonical agents in mock mode', () async {
      final agents = await repository.getAgents();
      expect(agents.length, equals(9));
      expect(agents.any((a) => a.id == 'lead'), isTrue);
      expect(agents.any((a) => a.id == 'it-coding'), isTrue);
    });

    test('getProfiles returns 9 canonical profiles in mock mode', () async {
      final profiles = await repository.getProfiles();
      expect(profiles.length, equals(9));
      expect(profiles.any((p) => p.id == 'lead'), isTrue);
      expect(profiles.any((p) => p.id == 'exportir-handal'), isTrue);
    });

    test('getTasks returns mock tasks', () async {
      final tasks = await repository.getTasks();
      expect(tasks.isNotEmpty, isTrue);
    });

    test('getApprovals returns mock approvals', () async {
      final approvals = await repository.getApprovals();
      expect(approvals.isNotEmpty, isTrue);
    });

    test('getSchedules returns mock schedules', () async {
      final schedules = await repository.getSchedules();
      expect(schedules.isNotEmpty, isTrue);
    });

    test('toggleKillSwitch changes state correctly', () {
      expect(repository.isKillSwitchActive, isFalse);
      repository.toggleKillSwitch(true);
      expect(repository.isKillSwitchActive, isTrue);
      repository.toggleKillSwitch(false);
      expect(repository.isKillSwitchActive, isFalse);
    });

    test('approveAction updates approval state', () async {
      final approvals = await repository.getApprovals();
      final targetId = approvals.first.id;

      final success = await repository.approveAction(
        targetId,
        reason: 'Test approval',
      );

      expect(success, isTrue);
      final updatedApprovals = await repository.getApprovals();
      final updatedItem = updatedApprovals.firstWhere((a) => a.id == targetId);
      expect(updatedItem.state, equals('APPROVED'));
    });
    test('updateProfile updates stored profile in mock mode', () async {
      final profiles = await repository.getProfiles();
      final target = profiles.first;
      final updatedProfile = target.copyWith(name: 'Updated Lead Name');

      final success = await repository.updateProfile(updatedProfile);
      expect(success, isTrue);

      final updatedList = await repository.getProfiles();
      expect(updatedList.first.name, equals('Updated Lead Name'));
    });

    test('updateSchedule updates stored schedule in mock mode', () async {
      final schedules = await repository.getSchedules();
      final target = schedules.first;
      final updatedSchedule = target.copyWith(title: 'Updated Cron Schedule');

      final success = await repository.updateSchedule(updatedSchedule);
      expect(success, isTrue);

      final updatedList = await repository.getSchedules();
      expect(updatedList.first.title, equals('Updated Cron Schedule'));
    });
  });
}
