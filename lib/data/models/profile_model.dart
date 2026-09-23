class ProfileModel {
  final String id;
  final String name;
  final String role;
  final String operationalTitle;
  final String description;
  final String model;
  final String modelPolicy;
  final String soulPrompt; // The full SOUL.md system persona
  final List<String> skills;
  final List<String> toolAccess;
  final List<String> channelRoutes;
  final String workspacePolicy;
  final String permissionsPolicy;
  final String memoryNamespace;
  final String status; // CONFIGURED, CUSTOM_TEMPLATE, TEMPLATE_DEFAULT

  const ProfileModel({
    required this.id,
    required this.name,
    required this.role,
    this.operationalTitle = '',
    required this.description,
    required this.model,
    this.modelPolicy = 'primary=balanced, fallback=fast',
    required this.soulPrompt,
    this.skills = const [],
    this.toolAccess = const [],
    this.channelRoutes = const [],
    this.workspacePolicy = '',
    this.permissionsPolicy = 'default',
    this.memoryNamespace = '',
    this.status = 'CONFIGURED',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['allowed_skills'] as List<dynamic>? ??
        json['skills'] as List<dynamic>? ??
        json['recommended_skills'] as List<dynamic>? ??
        [];
    final rawTools = json['toolAccess'] as List<dynamic>? ??
        json['allowed_tools'] as List<dynamic>? ??
        [];
    final rawChannels = json['channel_routes'] as List<dynamic>? ??
        json['channelRoutes'] as List<dynamic>? ??
        [];

    return ProfileModel(
      id: json['id'] as String? ?? json['profile_id'] as String? ?? '',
      name: json['name'] as String? ?? _formatFallbackName(json['id'] as String? ?? ''),
      role: json['role'] as String? ?? json['current_role'] as String? ?? '',
      operationalTitle: json['operational_title'] as String? ??
          json['operationalTitle'] as String? ??
          _formatFallbackTitle(json['id'] as String? ?? ''),
      description: json['description'] as String? ?? '',
      model: json['model'] as String? ?? json['model_tier'] as String? ?? 'SAGARA-AGENTIC-AI-1',
      modelPolicy: json['model_policy'] as String? ??
          json['modelPolicy'] as String? ??
          'primary=balanced, fallback=fast',
      soulPrompt: json['soulPrompt'] as String? ?? json['instructions'] as String? ?? '',
      skills: rawSkills.map((e) => e.toString()).toList(),
      toolAccess: rawTools.map((e) => e.toString()).toList(),
      channelRoutes: rawChannels.map((e) => e.toString()).toList(),
      workspacePolicy: json['workspace_policy'] as String? ?? json['workspacePolicy'] as String? ?? '',
      permissionsPolicy: json['permissions_policy'] as String? ?? 'default',
      memoryNamespace: json['memory_namespace'] as String? ?? 'profile:${json['id'] ?? ''}',
      status: json['soul_status'] as String? ?? json['status'] as String? ?? 'CONFIGURED',
    );
  }

  static String _formatFallbackName(String id) {
    switch (id) {
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
        return 'Exportir Handal Specialist';
      default:
        return id.toUpperCase();
    }
  }

  static String _formatFallbackTitle(String id) {
    switch (id) {
      case 'lead':
        return 'Fleet Operations Coordinator & Triage Director';
      case 'it-coding':
        return 'Software Engineer & Technical Development Specialist';
      case 'it-support':
        return 'Systems Reliability & Operational Monitoring Specialist';
      case 'marketing':
        return 'Creative Content & Multichannel Growth Specialist';
      case 'cs':
        return 'Customer Support & Order Fulfillment Coordinator';
      case 'business':
        return 'Commercial Strategy & Product Operations Specialist';
      case 'personal':
        return 'Executive Personal Assistant & Schedule Coordinator';
      case 'sagara-lab':
        return 'R&D & Architectural Experimentation Specialist';
      case 'exportir-handal':
        return 'Cross-Border Commerce & Export Logistics Specialist';
      default:
        return 'Operational Autonomous Specialist';
    }
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? role,
    String? operationalTitle,
    String? description,
    String? model,
    String? modelPolicy,
    String? soulPrompt,
    List<String>? skills,
    List<String>? toolAccess,
    List<String>? channelRoutes,
    String? workspacePolicy,
    String? permissionsPolicy,
    String? memoryNamespace,
    String? status,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      operationalTitle: operationalTitle ?? this.operationalTitle,
      description: description ?? this.description,
      model: model ?? this.model,
      modelPolicy: modelPolicy ?? this.modelPolicy,
      soulPrompt: soulPrompt ?? this.soulPrompt,
      skills: skills ?? this.skills,
      toolAccess: toolAccess ?? this.toolAccess,
      channelRoutes: channelRoutes ?? this.channelRoutes,
      workspacePolicy: workspacePolicy ?? this.workspacePolicy,
      permissionsPolicy: permissionsPolicy ?? this.permissionsPolicy,
      memoryNamespace: memoryNamespace ?? this.memoryNamespace,
      status: status ?? this.status,
    );
  }
}
