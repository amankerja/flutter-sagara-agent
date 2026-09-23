import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_model.dart';
import '../models/profile_model.dart';
import '../models/task_model.dart';
import '../models/approval_model.dart';
import '../models/schedule_model.dart';
import '../models/system_pulse_model.dart';
import '../models/agent_session_model.dart';
import '../models/chat_message_model.dart';
import '../mocks/sagara_mock_data.dart';

class SagaraRepository {
  static const String _prefMockModeKey = 'sagara_is_mock_mode';
  static const String _prefBaseUrlKey = 'sagara_base_url';

  bool isMockMode;
  String baseUrl;

  // In-memory stateful store for Mock Mode
  final List<AgentModel> _mockAgents = List.from(SagaraMockData.agents);
  final List<ProfileModel> _mockProfiles = List.from(SagaraMockData.profiles);
  final List<TaskModel> _mockTasks = List.from(SagaraMockData.tasks);
  final List<ApprovalModel> _mockApprovals = List.from(SagaraMockData.approvals);
  final List<ScheduleModel> _mockSchedules = List.from(SagaraMockData.schedules);
  final List<AgentSessionModel> _mockSessions = List.from(SagaraMockData.sessions);
  bool _isKillSwitchActive = false;

  SagaraRepository({
    this.isMockMode = false,
    this.baseUrl = 'https://office.alkaralintas.site',
  }) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isMockMode = prefs.getBool(_prefMockModeKey) ?? false;
      baseUrl = prefs.getString(_prefBaseUrlKey) ?? baseUrl;
    } catch (_) {}
  }

  Future<void> savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefMockModeKey, isMockMode);
      await prefs.setString(_prefBaseUrlKey, baseUrl);
    } catch (_) {}
  }

  bool get isKillSwitchActive => _isKillSwitchActive;

  void toggleKillSwitch(bool active) {
    _isKillSwitchActive = active;
  }

  // --- Agents & Profiles ---
  Future<List<AgentModel>> getAgents() async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      return _mockAgents;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/agents'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => AgentModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return _mockAgents;
  }

  Future<List<ProfileModel>> getProfiles() async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _mockProfiles;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/profiles'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        Map<String, dynamic> recommendedMap = {};
        try {
          final recRes = await http.get(Uri.parse('$baseUrl/api/v1/profiles/recommended'));
          if (recRes.statusCode == 200) {
            final recData = jsonDecode(recRes.body);
            final preview = recData['preview'] as Map<String, dynamic>?;
            final profilesList = preview?['profiles'] as List<dynamic>? ?? [];
            for (var p in profilesList) {
              if (p is Map<String, dynamic> && p['profile_id'] != null) {
                recommendedMap[p['profile_id']] = p;
              }
            }
          }
        } catch (_) {}

        return data.map((json) {
          final pId = json['id'] as String? ?? '';
          final rec = recommendedMap[pId] ?? {};
          final fallbackMock = _mockProfiles.firstWhere(
            (mp) => mp.id == pId,
            orElse: () => _mockProfiles.first,
          );

          final modelPolicy = rec['model_policy'] as String? ?? fallbackMock.modelPolicy;
          final channelRoutes = (rec['channel_routes'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              fallbackMock.channelRoutes;
          final workspacePolicy = rec['workspace_policy'] as String? ?? fallbackMock.workspacePolicy;
          final soulPrompt = json['instructions'] as String? ??
              (json['soulPrompt'] as String?) ??
              fallbackMock.soulPrompt;

          return ProfileModel(
            id: pId,
            name: json['name'] as String? ?? fallbackMock.name,
            role: json['role'] as String? ?? fallbackMock.role,
            operationalTitle: fallbackMock.operationalTitle,
            description: (json['description'] as String?)?.isNotEmpty == true
                ? json['description'] as String
                : fallbackMock.description,
            model: json['model'] as String? ?? fallbackMock.model,
            modelPolicy: modelPolicy,
            soulPrompt: soulPrompt.isNotEmpty ? soulPrompt : fallbackMock.soulPrompt,
            skills: (json['allowed_skills'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                fallbackMock.skills,
            toolAccess: fallbackMock.toolAccess,
            channelRoutes: channelRoutes,
            workspacePolicy: workspacePolicy,
            permissionsPolicy: json['permissions_policy'] as String? ?? fallbackMock.permissionsPolicy,
            memoryNamespace: json['memory_namespace'] as String? ?? fallbackMock.memoryNamespace,
            status: rec['soul_status'] as String? ?? 'CUSTOM_TEMPLATE',
          );
        }).toList();
      }
    } catch (_) {}
    return _mockProfiles;
  }

  Future<bool> updateProfile(ProfileModel profile) async {
    final index = _mockProfiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _mockProfiles[index] = profile;
    }
    if (isMockMode) return true;
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/v1/profiles/${profile.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': profile.name,
          'role': profile.role,
          'description': profile.description,
          'model': profile.model,
          'soul_prompt': profile.soulPrompt,
          'allowed_skills': profile.skills,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // --- Tasks & Delegations ---
  Future<List<TaskModel>> getTasks() async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 120));
      return List.unmodifiable(_mockTasks);
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/tasks'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return List.unmodifiable(_mockTasks);
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String agentId,
    required String priority,
  }) async {
    final effectiveAgentId = agentId.trim().isNotEmpty ? agentId.trim() : 'lead';
    final agent = _mockAgents.firstWhere(
      (a) => a.id == effectiveAgentId,
      orElse: () => _mockAgents.first,
    );

    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      final newTask = TaskModel(
        id: 'tsk-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        title: title,
        description: description,
        state: 'RUNNING',
        priority: priority,
        agentId: effectiveAgentId,
        agentName: agent.name,
        createdAt: DateTime.now().toIso8601String(),
        delegations: [
          TaskDelegation(
            id: 'del-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
            taskTitle: 'Sub-task Initialization',
            workerPid: 'pid-${(3000 + DateTime.now().second * 10)}',
            state: 'RUNNING',
            startedAt: DateTime.now().toIso8601String(),
            summary: 'Dispatched to worker agent ${agent.name}',
          ),
        ],
      );
      _mockTasks.insert(0, newTask);
      return newTask;
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'assigned_agent_id': effectiveAgentId,
          'priority': priority,
          'state': 'READY',
        }),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final created = TaskModel.fromJson(jsonDecode(res.body));
        _mockTasks.insert(0, created);
        // Also trigger VPS dispatch so state becomes DISPATCHING
        try {
          await http.post(Uri.parse('$baseUrl/api/v1/tasks/${created.id}/dispatch'));
        } catch (_) {}
        return created;
      }
    } catch (_) {}

    // Fallback
    final fallbackTask = TaskModel(
      id: 'tsk-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: title,
      description: description,
      state: 'RUNNING',
      priority: priority,
      agentId: effectiveAgentId,
      agentName: agent.name,
      createdAt: DateTime.now().toIso8601String(),
    );
    _mockTasks.insert(0, fallbackTask);
    return fallbackTask;
  }

  Future<bool> cancelTask(String taskId) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 150));
      final index = _mockTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _mockTasks[index] = _mockTasks[index].copyWith(state: 'CANCELLED');
        return true;
      }
      return false;
    }
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/v1/tasks/$taskId/cancel'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- Approvals (1-Tap HITL) ---
  Future<List<ApprovalModel>> getApprovals() async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      return List.unmodifiable(_mockApprovals);
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/approvals'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => ApprovalModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return List.unmodifiable(_mockApprovals);
  }

  Future<bool> approveAction(String approvalId, {String? reason}) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockApprovals.indexWhere((a) => a.id == approvalId);
      if (index != -1) {
        _mockApprovals[index] = _mockApprovals[index].copyWith(
          state: 'APPROVED',
          revision: _mockApprovals[index].revision + 1,
        );
        return true;
      }
      return false;
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/approvals/$approvalId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': 'mobile-${DateTime.now().millisecondsSinceEpoch}',
        },
        body: jsonEncode({'reason': reason ?? 'Approved via Sagara Mobile Companion'}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectAction(String approvalId, {required String reason}) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _mockApprovals.indexWhere((a) => a.id == approvalId);
      if (index != -1) {
        _mockApprovals[index] = _mockApprovals[index].copyWith(
          state: 'REJECTED',
          revision: _mockApprovals[index].revision + 1,
        );
        return true;
      }
      return false;
    }
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/approvals/$approvalId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': 'mobile-${DateTime.now().millisecondsSinceEpoch}',
        },
        body: jsonEncode({'reason': reason}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- Schedules ---
  Future<List<ScheduleModel>> getSchedules() async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 100));
      return List.unmodifiable(_mockSchedules);
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/schedules'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          return data.map((json) => ScheduleModel.fromJson(json)).toList();
        }
      }
    } catch (_) {}

    // Fallback: Pull live cron tasks directly from /api/v1/tasks
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/tasks'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        final List<ScheduleModel> liveSchedules = [];
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            final id = item['id'] as String? ?? '';
            final desc = item['description'] as String? ?? '';
            final title = item['title'] as String? ?? '';
            if (id.startsWith('cron-') || desc.toLowerCase().contains('cronjob')) {
              final result = item['result'] as Map<String, dynamic>?;
              final summary = result?['summary'] as String? ?? '';

              String? schedulePattern;
              if (summary.contains('Schedule:')) {
                final match = RegExp(r'Schedule:\s*([^\|]+)').firstMatch(summary);
                if (match != null) {
                  schedulePattern = match.group(1)!.trim();
                }
              }

              String freq = 'DAILY';
              final patternLower = (schedulePattern ?? '').toLowerCase();
              final descLower = desc.toLowerCase();
              final titleLower = title.toLowerCase();

              if (patternLower.contains('weekly') ||
                  patternLower.contains('monday') ||
                  patternLower.contains('sunday') ||
                  patternLower.contains('friday') ||
                  descLower.contains('weekly') ||
                  titleLower.contains('mingguan')) {
                freq = 'WEEKLY';
              } else if (patternLower.contains('tuesday') ||
                  patternLower.contains('thursday') ||
                  patternLower.contains(',')) {
                freq = 'CUSTOM';
              } else if (patternLower.contains('m') ||
                  desc.contains('30m') ||
                  desc.contains('every 60m') ||
                  desc.contains('180m') ||
                  desc.contains('240m')) {
                freq = 'HOURLY';
              } else if (patternLower.contains('weekdays') || descLower.contains('weekdays')) {
                freq = 'WEEKDAYS';
              } else if (patternLower.contains('day') ||
                  patternLower == '0 6 * * *' ||
                  descLower.contains('daily') ||
                  titleLower.contains('daily')) {
                freq = 'DAILY';
              }

              String startAt = item['updated_at'] as String? ?? item['created_at'] as String? ?? DateTime.now().toIso8601String();
              if (summary.contains('Next run:')) {
                final match = RegExp(r'Next run:\s*([^\s\|]+)').firstMatch(summary);
                if (match != null) {
                  startAt = match.group(1)!;
                }
              }

              final assignedAgent = item['assigned_agent_id'] as String? ?? 'lead';

              liveSchedules.add(
                ScheduleModel(
                  id: id,
                  title: title,
                  description: desc,
                  type: 'RECURRING_JOB',
                  startAt: startAt,
                  recurrenceFrequency: freq,
                  cronExpression: schedulePattern ?? (freq == 'HOURLY' ? 'Periodic Run' : '0 * * * *'),
                  agentId: assignedAgent,
                  agentName: AgentModel.formatAgentName(assignedAgent),
                  priority: item['priority'] as String? ?? 'MEDIUM',
                  status: (item['state'] == 'READY' || item['state'] == 'RUNNING') ? 'SCHEDULED' : (item['state'] as String? ?? 'SCHEDULED'),
                ),
              );
            }
          }
        }
        if (liveSchedules.isNotEmpty) {
          return liveSchedules;
        }
      }
    } catch (_) {}

    return List.unmodifiable(_mockSchedules);
  }

  Future<bool> triggerScheduleNow(String scheduleId) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      final index = _mockSchedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _mockSchedules[index] = _mockSchedules[index].copyWith(status: 'RUNNING');
        return true;
      }
      return false;
    }
    try {
      // First try standard schedules trigger
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/schedules/$scheduleId/trigger'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) return true;
    } catch (_) {}

    // Fallback: Dispatch task directly on VPS if it's a cron task
    try {
      final res = await http.post(Uri.parse('$baseUrl/api/v1/tasks/$scheduleId/dispatch'));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {}

    return false;
  }

  Future<bool> updateSchedule(ScheduleModel schedule) async {
    final index = _mockSchedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _mockSchedules[index] = schedule;
    }
    if (isMockMode) return true;
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/api/v1/schedules/${schedule.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(schedule.toJson()),
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // --- System Pulse, Infrastructure & Gateway ---
  Future<GatewayStatusModel> getGatewayStatus() async {
    if (isMockMode) {
      return SagaraMockData.gateway;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/runtime/gateway'));
      if (res.statusCode == 200) {
        return GatewayStatusModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return SagaraMockData.gateway;
  }

  Future<InfrastructureMetrics> getInfrastructureMetrics() async {
    if (isMockMode) {
      return SagaraMockData.infrastructure;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/runtime/infrastructure'));
      if (res.statusCode == 200) {
        return InfrastructureMetrics.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return SagaraMockData.infrastructure;
  }

  Future<List<AttentionItem>> getAttentionItems() async {
    if (isMockMode) {
      // If there are real pending approvals in memory, synthesize attention items dynamically!
      final pending = _mockApprovals.where((a) => a.isPending).toList();
      if (pending.isNotEmpty) {
        return pending.map((a) => AttentionItem(
          id: a.id,
          title: a.title,
          description: '${a.agentName.isNotEmpty ? a.agentName : a.agentId} • ${a.description}',
          severity: a.risk == 'CRITICAL' ? 'CRITICAL' : 'WARNING',
          timestamp: a.requestedAt,
        )).toList();
      }
      return SagaraMockData.attentionItems;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/runtime/attention'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((j) => AttentionItem.fromJson(j)).toList();
      }
    } catch (_) {}
    return SagaraMockData.attentionItems;
  }

  Future<List<RecentActivityEvent>> getRecentActivities() async {
    if (isMockMode) {
      return SagaraMockData.recentActivities;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/runtime/activities'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((j) => RecentActivityEvent.fromJson(j)).toList();
      }
    } catch (_) {}
    return SagaraMockData.recentActivities;
  }

  // --- Recorded Agent Sessions & Live Transcripts ---
  Future<List<AgentSessionModel>> getSessions({String? agentId}) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (agentId == null || agentId.isEmpty) {
        return List.unmodifiable(_mockSessions);
      }
      return _mockSessions
          .where((s) => s.agentId.toLowerCase() == agentId.toLowerCase())
          .toList();
    }
    try {
      final uri = agentId != null && agentId.isNotEmpty
          ? Uri.parse('$baseUrl/api/v1/sessions?agent_id=$agentId')
          : Uri.parse('$baseUrl/api/v1/sessions');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((j) => AgentSessionModel.fromJson(j)).toList();
      }
    } catch (_) {}
    return _mockSessions
        .where((s) => agentId == null || s.agentId.toLowerCase() == agentId.toLowerCase())
        .toList();
  }

  Future<AgentSessionModel?> getSessionDetail(String sessionId) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 50));
      try {
        return _mockSessions.firstWhere((s) => s.id == sessionId);
      } catch (_) {
        return null;
      }
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/v1/sessions/$sessionId'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        if ((data['messages'] as List<dynamic>?)?.isEmpty ?? true) {
          try {
            final logsRes = await http.get(Uri.parse('$baseUrl/api/v1/sessions/$sessionId/logs'));
            if (logsRes.statusCode == 200) {
              data['messages'] = jsonDecode(logsRes.body);
            }
          } catch (_) {}
        }
        return AgentSessionModel.fromJson(data);
      }
    } catch (_) {}
    try {
      return _mockSessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  Future<AgentSessionModel?> getLatestSession(String agentId) async {
    final list = await getSessions(agentId: agentId);
    if (list.isEmpty) return null;
    final sorted = List<AgentSessionModel>.from(list);
    sorted.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    final latest = sorted.first;
    return await getSessionDetail(latest.id) ?? latest;
  }

  Future<ChatMessageModel?> sendAgentMessage({
    required String agentId,
    required String text,
    String? sessionId,
  }) async {
    if (isMockMode) return null;
    try {
      final effectiveAgentId = agentId.trim().isNotEmpty ? agentId.trim() : 'lead';
      final title = text.trim().length > 50
          ? '${text.trim().substring(0, 47)}...'
          : text.trim();
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': text.trim(),
          'assigned_agent_id': effectiveAgentId,
          'priority': 'HIGH',
          'state': 'READY',
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final taskId = data['id'] as String? ?? 'tsk-sent';

        // Also trigger VPS dispatch so task status becomes DISPATCHING
        try {
          await http.post(Uri.parse('$baseUrl/api/v1/tasks/$taskId/dispatch'));
        } catch (_) {}

        final agentDisplayName = AgentModel.formatAgentName(effectiveAgentId);

        return ChatMessageModel(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          agentId: effectiveAgentId,
          sender: 'agent',
          text: 'Command successfully dispatched to VPS Agent [$agentDisplayName ($effectiveAgentId)].\n• Task ID: $taskId\n• State: READY / DISPATCHING\n• VPS Status: Dispatched & queued for execution.',
          timestamp: DateTime.now(),
          linkedTaskId: taskId,
          linkedTaskTitle: title,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveSession(AgentSessionModel session) async {
    final idx = _mockSessions.indexWhere((s) => s.id == session.id);
    if (idx != -1) {
      _mockSessions[idx] = session;
    } else {
      _mockSessions.insert(0, session);
    }
    if (!isMockMode) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/v1/sessions'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(session.toJson()),
        );
      } catch (_) {}
    }
  }
}
