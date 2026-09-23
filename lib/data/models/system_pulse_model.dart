class GatewayStatusModel {
  final String status; // HEALTHY, DEGRADED, STALE, NOT_CONNECTED
  final bool connected;
  final int latencyMs;
  final String host;
  final int pid;
  final String lastHeartbeatAt;
  final int heartbeatAgeSeconds;

  const GatewayStatusModel({
    required this.status,
    required this.connected,
    required this.latencyMs,
    required this.host,
    required this.pid,
    required this.lastHeartbeatAt,
    required this.heartbeatAgeSeconds,
  });

  factory GatewayStatusModel.fromJson(Map<String, dynamic> json) {
    return GatewayStatusModel(
      status: json['status'] as String? ?? 'HEALTHY',
      connected: json['connected'] as bool? ?? true,
      latencyMs: json['latency_ms'] as int? ?? json['latencyMs'] as int? ?? 14,
      host: json['host'] as String? ?? 'hermes-vps-prod',
      pid: json['pid'] as int? ?? 4821,
      lastHeartbeatAt: json['last_heartbeat_at'] as String? ?? json['lastHeartbeatAt'] as String? ?? '',
      heartbeatAgeSeconds: json['heartbeat_age_seconds'] as int? ?? json['heartbeatAgeSeconds'] as int? ?? 8,
    );
  }

  bool get isHealthy => status == 'HEALTHY';
  bool get isDegraded => status == 'DEGRADED';
  bool get isOnline => connected && status != 'NOT_CONNECTED';
}

class InfrastructureMetrics {
  final double cpuPercent;
  final int memoryUsedMb;
  final int memoryTotalMb;
  final double diskUsedGb;
  final double diskTotalGb;
  final String uptime;

  const InfrastructureMetrics({
    required this.cpuPercent,
    required this.memoryUsedMb,
    required this.memoryTotalMb,
    required this.diskUsedGb,
    required this.diskTotalGb,
    required this.uptime,
  });

  factory InfrastructureMetrics.fromJson(Map<String, dynamic> json) {
    return InfrastructureMetrics(
      cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? (json['cpuPercent'] as num?)?.toDouble() ?? 18.0,
      memoryUsedMb: (json['memory_used_mb'] as num?)?.toInt() ?? (json['memoryUsedMb'] as num?)?.toInt() ?? 1420,
      memoryTotalMb: (json['memory_total_mb'] as num?)?.toInt() ?? (json['memoryTotalMb'] as num?)?.toInt() ?? 3780,
      diskUsedGb: (json['disk_used_gb'] as num?)?.toDouble() ?? (json['diskUsedGb'] as num?)?.toDouble() ?? 24.5,
      diskTotalGb: (json['disk_total_gb'] as num?)?.toDouble() ?? (json['diskTotalGb'] as num?)?.toDouble() ?? 80.0,
      uptime: json['uptime'] as String? ?? '14d 6h 22m',
    );
  }

  int get memoryPercent => ((memoryUsedMb / (memoryTotalMb > 0 ? memoryTotalMb : 1)) * 100).round();
  int get diskPercent => ((diskUsedGb / (diskTotalGb > 0 ? diskTotalGb : 1)) * 100).round();
}

class AttentionItem {
  final String id;
  final String title;
  final String description;
  final String severity; // CRITICAL, WARNING, INFO
  final String timestamp;

  const AttentionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
  });

  factory AttentionItem.fromJson(Map<String, dynamic> json) {
    return AttentionItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severity: json['severity'] as String? ?? 'INFO',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  bool get actionNeeded => severity == 'CRITICAL' || severity == 'WARNING';
  String get action => description;
}

class RecentActivityEvent {
  final String id;
  final String agentName;
  final String actionType;
  final String summary;
  final String timestamp;
  final String severity;

  const RecentActivityEvent({
    required this.id,
    required this.agentName,
    required this.actionType,
    required this.summary,
    required this.timestamp,
    this.severity = 'INFO',
  });

  factory RecentActivityEvent.fromJson(Map<String, dynamic> json) {
    return RecentActivityEvent(
      id: json['id'] as String? ?? '',
      agentName: json['agent_name'] as String? ?? json['agentName'] as String? ?? 'Agent',
      actionType: json['action_type'] as String? ?? json['actionType'] as String? ?? 'EXECUTION',
      summary: json['summary'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      severity: json['severity'] as String? ?? 'INFO',
    );
  }
}
