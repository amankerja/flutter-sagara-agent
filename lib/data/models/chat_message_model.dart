class ChatMessageModel {
  final String id;
  final String agentId;
  final String sender; // 'user', 'agent', 'system', 'tool'
  final String text;
  final DateTime timestamp;
  final String? toolName;
  final String? toolOutput;
  final bool isThinking;
  final String? linkedTaskId;
  final String? linkedTaskTitle;

  const ChatMessageModel({
    required this.id,
    required this.agentId,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.toolName,
    this.toolOutput,
    this.isThinking = false,
    this.linkedTaskId,
    this.linkedTaskTitle,
  });

  bool get isUser => sender == 'user';
  bool get isAgent => sender == 'agent';
  bool get isTool => sender == 'tool';
  bool get isSystem => sender == 'system';

  ChatMessageModel copyWith({
    String? id,
    String? agentId,
    String? sender,
    String? text,
    DateTime? timestamp,
    String? toolName,
    String? toolOutput,
    bool? isThinking,
    String? linkedTaskId,
    String? linkedTaskTitle,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      toolName: toolName ?? this.toolName,
      toolOutput: toolOutput ?? this.toolOutput,
      isThinking: isThinking ?? this.isThinking,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      linkedTaskTitle: linkedTaskTitle ?? this.linkedTaskTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'toolName': toolName,
      'toolOutput': toolOutput,
      'isThinking': isThinking,
      'linkedTaskId': linkedTaskId,
      'linkedTaskTitle': linkedTaskTitle,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime;
    try {
      final rawTime = json['timestamp'] ?? json['created_at'] ?? json['createdAt'];
      parsedTime = rawTime != null ? DateTime.parse(rawTime.toString()) : DateTime.now();
    } catch (_) {
      parsedTime = DateTime.now();
    }

    final resolvedAgentId = json['assigned_agent_id'] as String? ??
        json['agent_id'] as String? ??
        json['agentId'] as String? ??
        'lead';

    return ChatMessageModel(
      id: json['id']?.toString() ?? 'msg-${DateTime.now().millisecondsSinceEpoch}',
      agentId: resolvedAgentId,
      sender: json['sender'] as String? ?? json['role'] as String? ?? 'agent',
      text: json['text'] as String? ?? json['content'] as String? ?? json['message'] as String? ?? '',
      timestamp: parsedTime,
      toolName: json['toolName'] as String? ?? json['tool_name'] as String?,
      toolOutput: json['toolOutput'] as String? ?? json['tool_output'] as String?,
      isThinking: json['isThinking'] as bool? ?? json['is_thinking'] as bool? ?? false,
      linkedTaskId: json['linkedTaskId'] as String? ?? json['linked_task_id'] as String? ?? json['task_id'] as String?,
      linkedTaskTitle: json['linkedTaskTitle'] as String? ?? json['linked_task_title'] as String?,
    );
  }
}
