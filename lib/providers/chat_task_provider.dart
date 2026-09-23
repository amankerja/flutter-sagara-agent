import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/chat_message_model.dart';
import '../data/models/agent_session_model.dart';
import '../data/repositories/sagara_repository.dart';
import '../data/mocks/sagara_mock_data.dart';
import '../providers/task_provider.dart';

class ChatTaskProvider with ChangeNotifier {
  final SagaraRepository? repository;
  final Map<String, List<ChatMessageModel>> _agentChats = {};
  final Map<String, bool> _isAgentTyping = {};
  final Map<String, String?> _activeSessionId = {};
  final Map<String, bool> _isLoadingSession = {};
  final Map<String, List<AgentSessionModel>> _agentSessions = {};

  ChatTaskProvider({this.repository}) {
    _initializeSeedChats();
  }

  List<ChatMessageModel> getMessages(String agentId) {
    return _agentChats[agentId] ?? [];
  }

  bool isTyping(String agentId) {
    return _isAgentTyping[agentId] ?? false;
  }

  bool isLoadingSession(String agentId) {
    return _isLoadingSession[agentId] ?? false;
  }

  String? getActiveSessionId(String agentId) {
    return _activeSessionId[agentId] ?? 'sess-$agentId-latest';
  }

  List<AgentSessionModel> getCachedSessions(String agentId) {
    final list = _agentSessions[agentId];
    if (list != null && list.isNotEmpty) return list;
    return SagaraMockData.sessions
        .where((s) => s.agentId.toLowerCase() == agentId.toLowerCase())
        .toList();
  }

  AgentSessionModel? getLatestCachedSession(String agentId) {
    final list = getCachedSessions(agentId);
    if (list.isNotEmpty) {
      final sorted = List<AgentSessionModel>.from(list);
      sorted.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
      return sorted.first;
    }
    return null;
  }

  ChatMessageModel? getLastMessage(String agentId) {
    final msgs = _agentChats[agentId];
    if (msgs != null && msgs.isNotEmpty) {
      return msgs.last;
    }
    return null;
  }

  int getTotalMessageCount(String agentId) {
    return (_agentChats[agentId] ?? []).length;
  }

  // Fetch list of recorded sessions for this agent
  Future<List<AgentSessionModel>> fetchSessionsForAgent(String agentId) async {
    if (repository == null) return getCachedSessions(agentId);
    try {
      final list = await repository!.getSessions(agentId: agentId);
      _agentSessions[agentId] = list;
      notifyListeners();
      return list;
    } catch (_) {
      return getCachedSessions(agentId);
    }
  }

  // Load the latest session for this agent
  Future<bool> loadLatestSession(String agentId) async {
    if (repository == null) return false;
    _isLoadingSession[agentId] = true;
    notifyListeners();

    try {
      final latest = await repository!.getLatestSession(agentId);
      if (latest != null) {
        _activeSessionId[agentId] = latest.id;
        _agentChats[agentId] = List.from(latest.messages);
        _isLoadingSession[agentId] = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLoadingSession[agentId] = false;
    notifyListeners();
    return false;
  }

  // Load a specific recorded historical session by ID
  Future<bool> loadSession(String sessionId, String agentId) async {
    if (repository == null) return false;
    _isLoadingSession[agentId] = true;
    notifyListeners();

    try {
      final session = await repository!.getSessionDetail(sessionId);
      if (session != null) {
        _activeSessionId[agentId] = session.id;
        _agentChats[agentId] = List.from(session.messages);
        _isLoadingSession[agentId] = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLoadingSession[agentId] = false;
    notifyListeners();
    return false;
  }

  // Start a fresh, blank new session
  void startNewSession(String agentId) {
    final newSessId = 'sess-$agentId-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _activeSessionId[agentId] = newSessId;
    _agentChats[agentId] = [];
    if (repository != null) {
      final newSession = AgentSessionModel(
        id: newSessId,
        agentId: agentId,
        agentName: _getAgentDisplayName(agentId),
        model: 'claude-3-5-sonnet',
        startedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
        state: 'ACTIVE',
        messageCount: 0,
        toolsCount: 0,
        costUsd: 0.0,
        messages: [],
      );
      repository!.saveSession(newSession);
    }
    notifyListeners();
  }

  List<String> getSuggestions(String agentId) {
    switch (agentId.toLowerCase()) {
      case 'lead':
        return [
          'Audit status seluruh 9 agen armada',
          'Pecah task infrastruktur untuk IT team',
          'Evaluasi antrean approval mendesak',
          'Sinkronkan jadwal harian dengan kalender',
        ];
      case 'it-coding':
        return [
          'Refactor SQLite WAL lock di database adapter',
          'Tulis unit test untuk Hermes Gateway bridge',
          'Review pull request backend API endpoint',
          'Optimasi query index tabel audit logs',
        ];
      case 'it-support':
        return [
          'Cek kesehatan server sagara-vps-sg01',
          'Diagnosa latensi spike Hermes Gateway',
          'Jalankan snapshot backup WAL database',
          'Periksa kuota RAM dan Disk Space VPS',
        ];
      case 'marketing':
        return [
          'Buat draf posting LinkedIn tentang Multi-Agent',
          'Riset kata kunci SEO untuk Sagara Mission Control',
          'Analisis performa lead conversion minggu ini',
          'Susun copy newsletter mingguan klien',
        ];
      case 'cs':
        return [
          'Triage komplain webhook delay partner tiket #902',
          'Draft template balasan eskalasi insiden',
          'Audit kepatuhan SLA respons tiket darurat',
          'Kirimkan notifikasi resolusi pemeliharaan',
        ];
      case 'business':
        return [
          'Hitung estimasi token burn-rate minggu ini',
          'Analisis perbandingan biaya model Flagship vs Fast',
          'Forecast margin laba operasional Q4',
          'Audit biaya hosting VPS dan egress Cloudflare',
        ];
      case 'personal':
        return [
          'Apa daftar agenda darurat saya hari ini?',
          'Prioritaskan antrean tugas dan review approval',
          'Cek jadwal meeting dan briefing operasional',
          'Buatkan ringkasan aktivitas armada hari ini',
        ];
      case 'sagara-lab':
        return [
          'Benchmark latensi inferensi Claude vs Gemini Flash',
          'Uji prompt robustness untuk SOUL template',
          'Simulasi stress-test 100 concurrent workers',
          'Evaluasi akurasi retrieval grounded-citations',
        ];
      case 'exportir-handal':
        return [
          'Verifikasi dokumen PEB dan COO komoditas kopi',
          'Periksa kepatuhan regulasi EUDR pasar Eropa',
          'Hitung estimasi tarif bea cukai HS Code 0901.11',
          'Validasi sertifikasi phytosanitary ekspor',
        ];
      default:
        return [
          'Cek status operasional agen',
          'Berikan ringkasan task aktif',
          'Jalankan pemeriksaan diagnostik',
        ];
    }
  }

  void _initializeSeedChats() {
    // Populate directly from authentic canonical Sagara recorded sessions
    for (final sess in SagaraMockData.sessions) {
      if (!_activeSessionId.containsKey(sess.agentId)) {
        _activeSessionId[sess.agentId] = sess.id;
        _agentChats[sess.agentId] = List.from(sess.messages);
      }
    }
  }

  String _getAgentDisplayName(String agentId) {
    switch (agentId.toLowerCase()) {
      case 'lead':
        return 'Lead Manager Agent';
      case 'it-coding':
        return 'IT Coding Agent';
      case 'it-support':
        return 'IT Support Sentinel Agent';
      case 'marketing':
        return 'Marketing & Content Agent';
      case 'cs':
        return 'Customer Service Agent';
      case 'business':
        return 'Business Strategy Agent';
      case 'personal':
        return 'Personal Assistant Agent';
      case 'sagara-lab':
        return 'Sagara Lab R&D Agent';
      case 'exportir-handal':
        return 'Exportir Handal Agent';
      default:
        return 'Agent $agentId';
    }
  }

  Future<void> sendUserMessage({
    required String agentId,
    required String text,
    String priority = 'MEDIUM',
    TaskProvider? taskProvider,
  }) async {
    if (text.trim().isEmpty) return;

    final effectiveAgentId = agentId.trim().isNotEmpty ? agentId.trim() : 'lead';

    final userMsgId = 'usr-${DateTime.now().millisecondsSinceEpoch}';
    final userMsg = ChatMessageModel(
      id: userMsgId,
      agentId: effectiveAgentId,
      sender: 'user',
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    if (!_agentChats.containsKey(effectiveAgentId)) {
      _agentChats[effectiveAgentId] = [];
    }
    _agentChats[effectiveAgentId]!.add(userMsg);
    _isAgentTyping[effectiveAgentId] = true;
    notifyListeners();

    String? createdTaskId;
    String taskTitle = text.trim();
    if (taskTitle.length > 50) {
      taskTitle = '${taskTitle.substring(0, 47)}...';
    }

    ChatMessageModel? agentResponse;

    // 1. If live backend mode is enabled, attempt dispatching to server
    if (repository != null && !repository!.isMockMode) {
      try {
        final currentSessId = getActiveSessionId(effectiveAgentId);
        agentResponse = await repository!.sendAgentMessage(
          agentId: effectiveAgentId,
          text: text.trim(),
          sessionId: currentSessId,
        );
        // Refresh task provider so newly dispatched task appears in task pipeline
        if (agentResponse != null && taskProvider != null) {
          taskProvider.fetchTasks();
        }
      } catch (_) {
        // Fallback to local simulation if network or API fails
      }
    }

    // 2. Fallback / Mock Mode: Simulate Agent Thinking and Response based on Profile SOUL
    if (agentResponse == null) {
      if (taskProvider != null) {
        createdTaskId = 'tsk-${DateTime.now().millisecondsSinceEpoch % 10000}';
        taskProvider.createTask(
          title: taskTitle,
          description: text.trim(),
          agentId: effectiveAgentId,
          priority: priority,
        );
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      agentResponse = _generateAgentResponse(
        agentId: effectiveAgentId,
        userPrompt: text.trim(),
        createdTaskId: createdTaskId,
        taskTitle: taskTitle,
      );
    }

    _agentChats[effectiveAgentId]!.add(agentResponse);
    _isAgentTyping[effectiveAgentId] = false;

    // Persist active session state to repository
    if (repository != null) {
      final currentSessId = getActiveSessionId(effectiveAgentId) ?? 'sess-$effectiveAgentId-live';
      final updatedSess = AgentSessionModel(
        id: currentSessId,
        agentId: effectiveAgentId,
        agentName: _getAgentDisplayName(effectiveAgentId),
        model: 'claude-3-5-sonnet',
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        lastActivityAt: DateTime.now(),
        state: 'ACTIVE',
        messageCount: _agentChats[effectiveAgentId]!.length,
        toolsCount: _agentChats[effectiveAgentId]!.where((m) => m.toolName != null).length,
        costUsd: 0.04 * _agentChats[effectiveAgentId]!.length,
        messages: List.from(_agentChats[effectiveAgentId]!),
      );
      repository!.saveSession(updatedSess);
    }

    notifyListeners();
  }

  ChatMessageModel _generateAgentResponse({
    required String agentId,
    required String userPrompt,
    String? createdTaskId,
    String? taskTitle,
  }) {
    final now = DateTime.now();
    final resId = 'agt-${now.millisecondsSinceEpoch}';

    String toolUsed = 'hermes_runtime';
    String toolOutput = '{"status": "EXECUTION_COMPLETE", "code": 200}';
    String replyText = '';

    switch (agentId.toLowerCase()) {
      case 'lead':
        toolUsed = 'hermes_orchestrator';
        toolOutput = '{"action": "DELEGATE_AND_TRIAGE", "subtasks": 2, "state": "ACCEPTED"}';
        replyText =
            'Instruksi diterima: "$taskTitle".\n\nSebagai Lead Manager Agent, saya telah mendekomposisi instruksi Anda menjadi sub-task terkoordinasi dan mendaftarkannya ke sistem work queue operasional. Progres akan terus dipantau.';
        break;

      case 'it-coding':
        toolUsed = 'codebase_inspector';
        toolOutput = '{"git_branch": "feature/refactor-auto", "files_analyzed": 3, "status": "READY"}';
        replyText =
            'Tugas teknis diterima: "$taskTitle".\n\nSpesialisasi coding diaktifkan. Saya sedang menganalisis file terkait, memeriksa dependensi, dan menyiapkan patch implementasi yang clean sesuai standar arsitektur Sagara.';
        break;

      case 'it-support':
        toolUsed = 'vps_telemetry';
        toolOutput = '{"vps_target": "sagara-vps-sg01", "cpu": "15.2%", "ram": "846MB", "status": "HEALTHY"}';
        replyText =
            'Pemeriksaan infrastruktur dijalankan untuk: "$taskTitle".\n\nHermes Gateway dan server sagara-vps-sg01 berada dalam batas operasional aman. Log diagnostics tidak mencatat anomali kritis.';
        break;

      case 'marketing':
        toolUsed = 'content_orchestrator';
        toolOutput = '{"campaign": "Q4-Sagara-Autonomous", "channel": "LinkedIn", "draft_words": 180}';
        replyText =
            'Perintah kampanye diterima: "$taskTitle".\n\nDraf materi konten telah dirancang dengan fokus pada proposisi nilai efisiensi autonomous agent armada. Copy telah dioptimasi untuk engagement audiens profesional.';
        break;

      case 'cs':
        toolUsed = 'crm_resolution_bridge';
        toolOutput = '{"sla_status": "WITHIN_LIMIT", "priority": "STANDARD"}';
        replyText =
            'Tiket CS diterima: "$taskTitle".\n\nSaya telah memverifikasi riwayat interaksi dan menyiapkan respons solutif sesuai SOP penanganan komplain pelanggan.';
        break;

      case 'business':
        toolUsed = 'financial_auditor';
        toolOutput = '{"audit_metric": "TOKEN_BURN_RATE", "delta_percent": "-4.2%"}';
        replyText =
            'Permintaan analisis bisnis diproses: "$taskTitle".\n\nKalkulasi unit economics dan run-rate biaya infrastruktur telah diperbarui. Laporan terverifikasi dalam batas target efisiensi.';
        break;

      case 'personal':
        toolUsed = 'executive_briefing_engine';
        toolOutput = '{"agenda_items": 4, "pending_approvals": 2}';
        replyText =
            'Catatan diterima: "$taskTitle".\n\nJadwal dan pengingat telah disinkronkan dengan kalender Anda. Saya akan mengingatkan Anda jika ada prioritas darurat yang membutuhkan otorisasi segera.';
        break;

      case 'sagara-lab':
        toolUsed = 'synthetic_benchmark_runner';
        toolOutput = '{"test_suite": "matrix_eval", "avg_latency_ms": 38.5, "pass_rate": "100%"}';
        replyText =
            'Eksperimen lab dimulai untuk: "$taskTitle".\n\nMenjalankan suite evaluasi sintetis pada cluster model. Metrik akurasi dan latensi inferensi sedang dicatat ke dashboard telemetry.';
        break;

      case 'exportir-handal':
        toolUsed = 'customs_trade_checker';
        toolOutput = '{"hs_code_matched": true, "eudr_compliance": "PASSED"}';
        replyText =
            'Audit kepatuhan ekspor dijalankan untuk: "$taskTitle".\n\nRegulasi perdagangan internasional, validasi HS Code, serta kelengkapan dokumen pengapalan telah diverifikasi.';
        break;

      default:
        replyText =
            'Perintah diterima: "$taskTitle". Agen siap menjalankan tugas dan memperbarui status pada work queue.';
        break;
    }

    return ChatMessageModel(
      id: resId,
      agentId: agentId,
      sender: 'agent',
      text: replyText,
      timestamp: now,
      toolName: toolUsed,
      toolOutput: toolOutput,
      linkedTaskId: createdTaskId,
      linkedTaskTitle: taskTitle,
    );
  }
}
