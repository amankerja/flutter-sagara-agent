import 'package:flutter_test/flutter_test.dart';
import 'package:sagara_mobile/data/repositories/sagara_repository.dart';
import 'package:sagara_mobile/providers/agent_provider.dart';
import 'package:sagara_mobile/providers/approval_provider.dart';
import 'package:sagara_mobile/providers/schedule_provider.dart';
import 'package:sagara_mobile/providers/task_provider.dart';
import 'package:sagara_mobile/providers/theme_provider.dart';

void main() {
  group('Providers Unit Tests', () {
    late SagaraRepository repository;

    setUp(() {
      repository = SagaraRepository(isMockMode: true);
    });

    test('AgentProvider loads agents and profiles', () async {
      final provider = AgentProvider(repository: repository);
      await provider.fetchAgents();

      expect(provider.agents.length, equals(9));
      expect(provider.profiles.length, equals(9));
      expect(provider.isLoading, isFalse);
    });

    test('ApprovalProvider filter and response handling', () async {
      final provider = ApprovalProvider(repository: repository);
      await provider.fetchApprovals();

      expect(provider.approvals.isNotEmpty, isTrue);

      final initialPendingCount = provider.pendingCount;
      if (provider.approvals.any((a) => a.isPending)) {
        final pendingItem = provider.approvals.firstWhere((a) => a.isPending);
        await provider.approve(pendingItem.id, reason: 'Approved in unit test');
        expect(provider.pendingCount, equals(initialPendingCount - 1));
      }
    });

    test('TaskProvider filter by status works', () async {
      final provider = TaskProvider(repository: repository);
      await provider.fetchTasks();

      expect(provider.tasks.isNotEmpty, isTrue);
      provider.setFilter('RUNNING');
      expect(provider.filterState, equals('RUNNING'));
    });

    test('ScheduleProvider loads schedule items', () async {
      final provider = ScheduleProvider(repository: repository);
      await provider.fetchSchedules();

      expect(provider.schedules.isNotEmpty, isTrue);
    });

    test('ThemeProvider toggles dark mode and button colors', () {
      final theme = ThemeProvider();
      expect(theme.isDarkMode, isFalse);

      theme.toggleDarkMode(true);
      expect(theme.isDarkMode, isTrue);

      theme.setButtonColor(ThemeProvider.buttonColorPresets[1]);
      expect(theme.selectedButtonColor.id, equals('indigo'));
    });
  });
}
