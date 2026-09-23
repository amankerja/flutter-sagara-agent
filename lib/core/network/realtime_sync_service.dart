import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/notification_service.dart';
import '../../data/repositories/sagara_repository.dart';
import '../../data/models/approval_model.dart';

enum RealtimeConnectionStatus { disconnected, connecting, connected, simulated }

class RealtimeSyncService {
  final SagaraRepository repository;
  final Function() onDataUpdated;
  final Function(ApprovalModel approval) onHighRiskApprovalReceived;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _mockSimulationTimer;
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;
  bool _isDisposed = false;

  RealtimeSyncService({
    required this.repository,
    required this.onDataUpdated,
    required this.onHighRiskApprovalReceived,
  });

  RealtimeConnectionStatus get status => _status;

  void start() {
    if (repository.isMockMode) {
      _startMockSimulation();
    } else {
      _connectWebSocket();
    }
  }

  void switchMode() {
    stop();
    start();
  }

  void stop() {
    _mockSimulationTimer?.cancel();
    _mockSimulationTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close();
    _channel = null;
    _status = RealtimeConnectionStatus.disconnected;
  }

  void dispose() {
    _isDisposed = true;
    stop();
  }

  int _consecutiveFailures = 0;

  // --- Real WebSocket Connection with Polling Fallback ---
  void _connectWebSocket() {
    if (_isDisposed || repository.isMockMode) return;

    _status = RealtimeConnectionStatus.connecting;

    try {
      // Clean base URL and strip trailing slashes
      var wsUrl = repository.baseUrl.trim();
      while (wsUrl.endsWith('/')) {
        wsUrl = wsUrl.substring(0, wsUrl.length - 1);
      }
      if (wsUrl.startsWith('https://')) {
        wsUrl = 'wss://${wsUrl.substring(8)}';
      } else if (wsUrl.startsWith('http://')) {
        wsUrl = 'ws://${wsUrl.substring(7)}';
      }

      final uri = Uri.parse('$wsUrl/realtime/ws?protocol_version=1');
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;

      // Intercept .ready Future to prevent Unhandled Exception in Dart VM during handshake failure
      channel.ready.then((_) {
        if (!_isDisposed) {
          _consecutiveFailures = 0;
          _status = RealtimeConnectionStatus.connected;
        }
      }).catchError((err) {
        _handleConnectionError(err);
      });

      channel.stream.listen(
        (message) {
          _status = RealtimeConnectionStatus.connected;
          _handleMessage(message);
        },
        onError: (err) {
          _handleConnectionError(err);
        },
        onDone: () {
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  void _handleConnectionError(dynamic err) {
    if (_isDisposed) return;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _status = RealtimeConnectionStatus.disconnected;
    _consecutiveFailures++;

    // Fallback: Refresh data via HTTP polling every 10 seconds if WS upgrade is disabled
    _startPollingFallback();
    _scheduleReconnect();
  }

  void _startPollingFallback() {
    if (_mockSimulationTimer != null) return;
    _mockSimulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isDisposed || repository.isMockMode) {
        timer.cancel();
        _mockSimulationTimer = null;
        return;
      }
      onDataUpdated();
    });
  }

  void _scheduleReconnect() {
    if (_isDisposed || repository.isMockMode) return;
    _status = RealtimeConnectionStatus.disconnected;
    _reconnectTimer?.cancel();
    
    // Back off when remote endpoint doesn't support WebSocket upgrade:
    // 20s -> 30s -> 60s max to prevent spamming errors or wasting network
    final delaySeconds = _consecutiveFailures > 2 ? 60 : (_consecutiveFailures * 15 + 15);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed && !repository.isMockMode) {
        _connectWebSocket();
      }
    });
  }

  void _handleMessage(dynamic raw) {
    try {
      final Map<String, dynamic> data = jsonDecode(raw.toString());
      final type = data['type'] as String? ?? '';

      if (type == 'snapshot' || type == 'delta') {
        onDataUpdated();

        // Check for new approvals requiring high risk alert
        final payload = data['payload'] as Map<String, dynamic>?;
        if (payload != null && payload.containsKey('changes')) {
          final changes = payload['changes'] as Map<String, dynamic>? ?? {};
          final approvalsData = changes['approvals'] as List<dynamic>? ?? [];
          for (final rawAppr in approvalsData) {
            final appr = ApprovalModel.fromJson(rawAppr as Map<String, dynamic>);
            if (appr.isCritical || appr.isHigh) {
              onHighRiskApprovalReceived(appr);
              NotificationService.instance.triggerHighRiskAlert(
                title: appr.title,
                body: '${appr.agentName}: ${appr.description}',
                risk: appr.risk,
              );
            }
          }
        }
      }
    } catch (_) {}
  }

  // --- Mock Simulation Engine (Demo Mode Live Ticks) ---
  void _startMockSimulation() {
    _status = RealtimeConnectionStatus.simulated;
    _mockSimulationTimer?.cancel();

    // Pulse live updates every 8 seconds in Mock Mode
    _mockSimulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_isDisposed || !repository.isMockMode) {
        timer.cancel();
        return;
      }

      onDataUpdated();
    });
  }

  // Manual trigger for testing audible alarm & high-risk notification
  Future<void> triggerTestHighRiskAlert() async {
    const testApproval = ApprovalModel(
      id: 'appr-test',
      state: 'PENDING',
      risk: 'CRITICAL',
      actionType: 'INFRASTRUCTURE_LOCK',
      title: 'UJI COBA ALERT SUARA: Database Failover Triggered',
      description: 'Agen IT-Support mendeteksi failover darurat pada node VPS produksi. Diperlukan persetujuan operator seketika.',
      reasonRequired: 'Verifikasi sistem alarm dan notifikasi perangkat Android.',
      agentId: 'agent-gamma',
      agentName: 'Gamma — IT Support',
      requestedAt: 'Now',
      expiresAt: 'In 15m',
      targetLabel: 'vps-production-db.sagara.internal',
      targetType: 'PostgreSQL Primary Node',
      previewSummary: 'Failover cluster promotion script',
      previewFields: {
        'Action': 'TRIGGER_PROMOTION',
        'Cluster': 'sagara-postgres-primary',
        'Node Target': 'vps-node-01',
      },
    );

    onHighRiskApprovalReceived(testApproval);

    await NotificationService.instance.triggerHighRiskAlert(
      title: testApproval.title,
      body: testApproval.description,
      risk: testApproval.risk,
    );
  }
}
