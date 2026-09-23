import 'agent_model.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String state; // READY, RUNNING, DISPATCHING, QUEUED, AWAITING_APPROVAL, COMPLETED, FAILED, CANCELLED
  final String priority; // LOW, MEDIUM, HIGH, CRITICAL
  final String agentId;
  final String agentName;
  final String createdAt;
  final String? completedAt;
  final String? resultSummary;
  final int revision;
  final List<TaskDelegation> delegations;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.state,
    required this.priority,
    required this.agentId,
    this.agentName = '',
    required this.createdAt,
    this.completedAt,
    this.resultSummary,
    this.revision = 1,
    this.delegations = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final rawDelegations = json['delegations'] as List<dynamic>? ?? [];

    final resolvedAgentId = json['assigned_agent_id'] as String? ??
        json['agent_id'] as String? ??
        json['agentId'] as String? ??
        '';

    final resultObj = json['result'] is Map<String, dynamic>
        ? json['result'] as Map<String, dynamic>
        : null;
    final resolvedSummary = resultObj?['summary'] as String? ??
        json['resultSummary'] as String? ??
        json['result_summary'] as String?;

    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      state: json['state'] as String? ?? 'READY',
      priority: json['priority'] as String? ?? 'MEDIUM',
      agentId: resolvedAgentId,
      agentName: json['agentName'] as String? ??
          json['agent_name'] as String? ??
          (resolvedAgentId.isNotEmpty ? AgentModel.formatAgentName(resolvedAgentId) : ''),
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      completedAt: json['completedAt'] as String? ?? json['completed_at'] as String?,
      resultSummary: resolvedSummary,
      revision: json['revision'] as int? ?? 1,
      delegations: rawDelegations.map((d) => TaskDelegation.fromJson(d as Map<String, dynamic>)).toList(),
    );
  }

  TaskModel copyWith({
    String? state,
    String? resultSummary,
    String? completedAt,
    int? revision,
  }) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      state: state ?? this.state,
      priority: priority,
      agentId: agentId,
      agentName: agentName,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      resultSummary: resultSummary ?? this.resultSummary,
      revision: revision ?? this.revision,
      delegations: delegations,
    );
  }

  bool get isRunning => state == 'RUNNING' || state == 'DISPATCHING';
  bool get isReady => state == 'READY';
  bool get isAwaitingApproval => state == 'AWAITING_APPROVAL';
  bool get isCompleted => state == 'COMPLETED';
  bool get isFailed => state == 'FAILED';
}

class TaskDelegation {
  final String id;
  final String taskTitle;
  final String workerPid;
  final String state; // QUEUED, RUNNING, COMPLETED, FAILED
  final String startedAt;
  final String? summary;

  const TaskDelegation({
    required this.id,
    required this.taskTitle,
    required this.workerPid,
    required this.state,
    required this.startedAt,
    this.summary,
  });

  factory TaskDelegation.fromJson(Map<String, dynamic> json) {
    return TaskDelegation(
      id: json['id'] as String? ?? '',
      taskTitle: json['taskTitle'] as String? ?? '',
      workerPid: json['workerPid'] as String? ?? 'pid-worker',
      state: json['state'] as String? ?? 'RUNNING',
      startedAt: json['startedAt'] as String? ?? '',
      summary: json['summary'] as String?,
    );
  }
}
