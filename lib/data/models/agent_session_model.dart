import 'chat_message_model.dart';

class AgentSessionModel {
  final String id;
  final String agentId;
  final String agentName;
  final String source;
  final String model;
  final String provider;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final String state; // ACTIVE, RECENT, COMPLETED, FAILED, ARCHIVED
  final int messageCount;
  final int toolsCount;
  final double costUsd;
  final List<ChatMessageModel> messages;

  const AgentSessionModel({
    required this.id,
    required this.agentId,
    required this.agentName,
    this.source = 'web_console',
    required this.model,
    this.provider = 'anthropic',
    required this.startedAt,
    required this.lastActivityAt,
    this.state = 'ACTIVE',
    this.messageCount = 0,
    this.toolsCount = 0,
    this.costUsd = 0.0,
    this.messages = const [],
  });

  bool get isActive => state.toUpperCase() == 'ACTIVE';
  bool get isCompleted => state.toUpperCase() == 'COMPLETED';

  AgentSessionModel copyWith({
    String? id,
    String? agentId,
    String? agentName,
    String? source,
    String? model,
    String? provider,
    DateTime? startedAt,
    DateTime? lastActivityAt,
    String? state,
    int? messageCount,
    int? toolsCount,
    double? costUsd,
    List<ChatMessageModel>? messages,
  }) {
    return AgentSessionModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      source: source ?? this.source,
      model: model ?? this.model,
      provider: provider ?? this.provider,
      startedAt: startedAt ?? this.startedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      state: state ?? this.state,
      messageCount: messageCount ?? this.messageCount,
      toolsCount: toolsCount ?? this.toolsCount,
      costUsd: costUsd ?? this.costUsd,
      messages: messages ?? this.messages,
    );
  }

  factory AgentSessionModel.fromJson(Map<String, dynamic> json) {
    final usage = json['usage'] as Map<String, dynamic>? ?? {};
    final rawMessages = json['messages'] as List<dynamic>? ?? [];

    final rawStarted = json['started_at'] ?? json['startedAt'];
    final rawLast = json['last_activity_at'] ?? json['lastActivityAt'];

    return AgentSessionModel(
      id: json['id'] as String? ?? 'sess-unknown',
      agentId: json['agent_id'] as String? ?? json['agentId'] as String? ?? json['profile_id'] as String? ?? '',
      agentName: json['agent_name'] as String? ?? json['agentName'] as String? ?? '',
      source: json['source'] as String? ?? 'web_console',
      model: json['model'] as String? ?? 'claude-3-5-sonnet',
      provider: json['provider'] as String? ?? 'anthropic',
      startedAt: rawStarted != null ? DateTime.tryParse(rawStarted.toString()) ?? DateTime.now() : DateTime.now(),
      lastActivityAt: rawLast != null ? DateTime.tryParse(rawLast.toString()) ?? DateTime.now() : DateTime.now(),
      state: json['state'] as String? ?? 'ACTIVE',
      messageCount: (json['message_count'] ?? json['messageCount'] ?? json['messagesCount'] ?? rawMessages.length) as int? ?? 0,
      toolsCount: (json['tool_call_count'] ?? json['toolsCount'] ?? 0) as int? ?? 0,
      costUsd: ((usage['actual_cost_usd'] ?? usage['estimated_cost_usd'] ?? usage['costUsd'] ?? 0.0) as num).toDouble(),
      messages: rawMessages.map((m) {
        if (m is Map<String, dynamic>) {
          return ChatMessageModel(
            id: m['id']?.toString() ?? 'msg-${DateTime.now().millisecondsSinceEpoch}',
            agentId: json['agent_id']?.toString() ?? '',
            sender: m['role']?.toString() ?? 'agent',
            text: m['contentPreview']?.toString() ?? m['content']?.toString() ?? '',
            timestamp: m['timestamp'] != null
                ? DateTime.tryParse(m['timestamp'].toString()) ?? DateTime.now()
                : DateTime.now(),
            toolName: m['toolAssociation']?.toString() ?? m['tool_name']?.toString(),
            toolOutput: m['tool_output']?.toString(),
          );
        }
        return ChatMessageModel(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          agentId: '',
          sender: 'agent',
          text: m.toString(),
          timestamp: DateTime.now(),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent_id': agentId,
      'agent_name': agentName,
      'source': source,
      'model': model,
      'provider': provider,
      'started_at': startedAt.toIso8601String(),
      'last_activity_at': lastActivityAt.toIso8601String(),
      'state': state,
      'message_count': messageCount,
      'tools_count': toolsCount,
      'cost_usd': costUsd,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
