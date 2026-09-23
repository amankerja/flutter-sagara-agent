class AgentModel {
  final String id;
  final String name;
  final String role;
  final String description;
  final String state; // ACTIVE, IDLE, DEGRADED, OFFLINE, CONFIGURATION_INCOMPLETE
  final String model;
  final String currentActivity;
  final int sessionCount;
  final int activeDelegations;
  final double estimatedCostUsd;
  final int totalTokens;
  final String profileId;
  final List<AgentSkill> skills;

  const AgentModel({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.state,
    required this.model,
    required this.currentActivity,
    this.sessionCount = 0,
    this.activeDelegations = 0,
    this.estimatedCostUsd = 0.0,
    this.totalTokens = 0,
    this.profileId = '',
    this.skills = const [],
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    final def = json['definition'] as Map<String, dynamic>? ?? {};
    final runtime = json['runtime'] as Map<String, dynamic>? ?? {};
    final usage = json['usage'] as Map<String, dynamic>? ?? {};
    final rawSkills = json['skills'] as List<dynamic>? ?? [];

    // Fallback profileId from definition or ID
    final resolvedProfileId = json['profileId'] as String? ??
        def['role'] as String? ??
        def['id'] as String? ??
        json['id'] as String? ??
        '';

    final name = def['name'] as String? ?? json['name'] as String? ?? formatAgentName(resolvedProfileId);
    final role = def['role'] as String? ?? json['role'] as String? ?? resolvedProfileId;
    final state = runtime['state'] as String? ?? json['state'] as String? ?? 'ACTIVE';
    final model = runtime['model'] as String? ?? json['model'] as String? ?? 'SAGARA-AGENTIC-AI-1';
    final currentActivity = runtime['current_activity'] as String? ??
        runtime['currentActivity'] as String? ??
        json['currentActivity'] as String? ??
        'Standing by for operational tasks';

    final sessionCount = runtime['session_count'] as int? ??
        runtime['sessionCount'] as int? ??
        json['sessionCount'] as int? ??
        0;

    final activeDelegations = runtime['active_delegations'] as int? ??
        runtime['activeDelegations'] as int? ??
        json['activeDelegations'] as int? ??
        0;

    final cost = (usage['estimated_cost_usd'] as num?)?.toDouble() ??
        (usage['estimatedCostUsd'] as num?)?.toDouble() ??
        (json['estimatedCostUsd'] as num?)?.toDouble() ??
        0.0;

    final inTokens = (usage['input_tokens'] as num?)?.toInt() ??
        (usage['inputTokens'] as num?)?.toInt() ??
        0;
    final outTokens = (usage['output_tokens'] as num?)?.toInt() ??
        (usage['outputTokens'] as num?)?.toInt() ??
        0;
    final totalToks = (inTokens + outTokens) > 0 ? (inTokens + outTokens) : (json['totalTokens'] as int? ?? 0);

    return AgentModel(
      id: json['id'] as String? ?? resolvedProfileId,
      name: name,
      role: role,
      description: def['description'] as String? ?? json['description'] as String? ?? '',
      state: state.toUpperCase(),
      model: model,
      currentActivity: currentActivity,
      sessionCount: sessionCount,
      activeDelegations: activeDelegations,
      estimatedCostUsd: cost,
      totalTokens: totalToks,
      profileId: resolvedProfileId,
      skills: rawSkills.map((s) {
        if (s is Map<String, dynamic>) {
          return AgentSkill.fromJson(s);
        }
        return AgentSkill(id: s.toString(), name: s.toString(), category: 'Registered', health: 'HEALTHY');
      }).toList(),
    );
  }

  static String formatAgentName(String id) {
    switch (id.toLowerCase().trim()) {
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
        if (id.trim().isEmpty) return 'Lead Manager Agent';
        return id.toUpperCase();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'description': description,
        'state': state,
        'model': model,
        'currentActivity': currentActivity,
        'sessionCount': sessionCount,
        'activeDelegations': activeDelegations,
        'estimatedCostUsd': estimatedCostUsd,
        'totalTokens': totalTokens,
        'profileId': profileId,
      };

  bool get isActive => state == 'ACTIVE' || state == 'RUNNING';
  bool get isIdle => state == 'IDLE' || state == 'UNKNOWN';
  bool get isDegraded => state == 'DEGRADED' || state == 'CONFIGURATION_INCOMPLETE';
  bool get isOffline => state == 'OFFLINE';
}

class AgentSkill {
  final String id;
  final String name;
  final String category;
  final String health; // HEALTHY, DEGRADED, MISSING, UNKNOWN
  final String description;

  const AgentSkill({
    required this.id,
    required this.name,
    required this.category,
    required this.health,
    this.description = '',
  });

  factory AgentSkill.fromJson(Map<String, dynamic> json) {
    return AgentSkill(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      health: json['health'] as String? ?? 'HEALTHY',
      description: json['description'] as String? ?? '',
    );
  }
}
