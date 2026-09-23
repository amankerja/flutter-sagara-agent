import 'agent_model.dart';

class ScheduleModel {
  final String id;
  final String title;
  final String description;
  final String type; // TASK, REMINDER, RECURRING_JOB, CONTENT, MAINTENANCE, EVENT
  final String startAt;
  final String? endAt;
  final String recurrenceFrequency; // NONE, DAILY, WEEKDAYS, WEEKLY, MONTHLY, CUSTOM
  final String? cronExpression;
  final String agentId;
  final String agentName;
  final String priority; // LOW, MEDIUM, HIGH, CRITICAL
  final String status; // SCHEDULED, RUNNING, COMPLETED, PAUSED, CANCELLED

  const ScheduleModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.type,
    required this.startAt,
    this.endAt,
    this.recurrenceFrequency = 'DAILY',
    this.cronExpression,
    this.agentId = '',
    this.agentName = '',
    this.priority = 'MEDIUM',
    this.status = 'SCHEDULED',
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final recurrence = json['recurrence'] as Map<String, dynamic>? ?? {};
    final resolvedAgentId = json['assigned_agent_id'] as String? ??
        json['agent_id'] as String? ??
        json['agentId'] as String? ??
        '';

    return ScheduleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'RECURRING_JOB',
      startAt: json['startAt'] as String? ?? json['start_at'] as String? ?? '',
      endAt: json['endAt'] as String? ?? json['end_at'] as String?,
      recurrenceFrequency: recurrence['frequency'] as String? ?? 'DAILY',
      cronExpression: recurrence['cronExpression'] as String? ?? recurrence['cron_expression'] as String? ?? '0 * * * *',
      agentId: resolvedAgentId,
      agentName: json['agentName'] as String? ??
          json['agent_name'] as String? ??
          (resolvedAgentId.isNotEmpty ? AgentModel.formatAgentName(resolvedAgentId) : ''),
      priority: json['priority'] as String? ?? 'MEDIUM',
      status: json['status'] as String? ?? 'SCHEDULED',
    );
  }

  ScheduleModel copyWith({
    String? title,
    String? status,
  }) {
    return ScheduleModel(
      id: id,
      title: title ?? this.title,
      description: description,
      type: type,
      startAt: startAt,
      endAt: endAt,
      recurrenceFrequency: recurrenceFrequency,
      cronExpression: cronExpression,
      agentId: agentId,
      agentName: agentName,
      priority: priority,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'start_at': startAt,
      'end_at': endAt,
      'agent_id': agentId,
      'priority': priority,
      'status': status,
      'recurrence': {
        'frequency': recurrenceFrequency,
        'cronExpression': cronExpression,
      },
    };
  }

  bool get isActive => status == 'SCHEDULED' || status == 'RUNNING' || status == 'ACTIVE';
}
