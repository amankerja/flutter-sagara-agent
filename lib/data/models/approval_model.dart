import 'agent_model.dart';

class ApprovalModel {
  final String id;
  final String state; // PENDING, APPROVED, REJECTED, EXPIRED
  final String risk; // LOW, MEDIUM, HIGH, CRITICAL
  final String actionType;
  final String title;
  final String description;
  final String reasonRequired;
  final String? taskId;
  final String agentId;
  final String agentName;
  final String requestedAt;
  final String expiresAt;
  final String targetLabel;
  final String targetType;
  final String previewSummary;
  final Map<String, String> previewFields;
  final int revision;

  const ApprovalModel({
    required this.id,
    required this.state,
    required this.risk,
    required this.actionType,
    required this.title,
    required this.description,
    required this.reasonRequired,
    this.taskId,
    required this.agentId,
    this.agentName = '',
    required this.requestedAt,
    required this.expiresAt,
    required this.targetLabel,
    required this.targetType,
    required this.previewSummary,
    this.previewFields = const {},
    this.revision = 1,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    final target = json['target'] as Map<String, dynamic>? ?? {};
    final preview = json['preview'] as Map<String, dynamic>? ?? {};
    final rawFields = preview['fields'] as Map<String, dynamic>? ?? {};
    final fields = rawFields.map((k, v) => MapEntry(k, v.toString()));

    final resolvedAgentId = json['agent_id'] as String? ??
        json['agentId'] as String? ??
        json['assigned_agent_id'] as String? ??
        '';

    final reasonReq = json['reason_required'] == true
        ? 'Reason required'
        : (json['reasonRequired'] as String? ?? '');

    return ApprovalModel(
      id: json['id'] as String? ?? '',
      state: json['state'] as String? ?? 'PENDING',
      risk: json['risk'] as String? ?? 'MEDIUM',
      actionType: json['actionType'] as String? ?? json['action_type'] as String? ?? 'EXECUTE_CODE',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      reasonRequired: reasonReq,
      taskId: json['taskId'] as String? ?? json['task_id'] as String?,
      agentId: resolvedAgentId,
      agentName: json['agentName'] as String? ??
          json['agent_name'] as String? ??
          (resolvedAgentId.isNotEmpty ? AgentModel.formatAgentName(resolvedAgentId) : ''),
      requestedAt: json['requestedAt'] as String? ?? json['requested_at'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? json['expires_at'] as String? ?? '',
      targetLabel: target['label'] as String? ?? '',
      targetType: target['type'] as String? ?? '',
      previewSummary: preview['summary'] as String? ?? '',
      previewFields: fields,
      revision: json['revision'] as int? ?? 1,
    );
  }

  ApprovalModel copyWith({
    String? state,
    int? revision,
  }) {
    return ApprovalModel(
      id: id,
      state: state ?? this.state,
      risk: risk,
      actionType: actionType,
      title: title,
      description: description,
      reasonRequired: reasonRequired,
      taskId: taskId,
      agentId: agentId,
      agentName: agentName,
      requestedAt: requestedAt,
      expiresAt: expiresAt,
      targetLabel: targetLabel,
      targetType: targetType,
      previewSummary: previewSummary,
      previewFields: previewFields,
      revision: revision ?? this.revision,
    );
  }

  bool get isPending => state == 'PENDING';
  bool get isApproved => state == 'APPROVED';
  bool get isRejected => state == 'REJECTED';
  bool get isCritical => risk == 'CRITICAL';
  bool get isHigh => risk == 'HIGH';
  bool get isMedium => risk == 'MEDIUM';
  bool get isLow => risk == 'LOW';

  String get environment => targetLabel.isNotEmpty ? targetLabel : 'production-sg01';
  String? get resolvedAt => null;
  String get targetScript =>
      previewFields['Command'] ??
      previewFields['Script'] ??
      previewFields['Query'] ??
      previewSummary;
  String get payload => previewFields.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}
