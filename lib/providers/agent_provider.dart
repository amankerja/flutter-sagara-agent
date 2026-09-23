import 'package:flutter/material.dart';
import '../data/models/agent_model.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/sagara_repository.dart';

class AgentProvider with ChangeNotifier {
  final SagaraRepository repository;

  List<AgentModel> _agents = [];
  List<ProfileModel> _profiles = [];
  AgentModel? _selectedAgent;
  ProfileModel? _selectedProfile;
  bool _isLoading = false;
  String _filterState = 'ALL'; // ALL, ACTIVE, IDLE, DEGRADED, OFFLINE

  AgentProvider({required this.repository}) {
    fetchAgentsAndProfiles();
  }

  List<AgentModel> get agents {
    if (_filterState == 'ALL') return _agents;
    return _agents.where((a) => a.state == _filterState).toList();
  }

  List<AgentModel> get rawAgents => _agents;
  List<ProfileModel> get profiles => _profiles;
  AgentModel? get selectedAgent => _selectedAgent;
  ProfileModel? get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;
  String get filterState => _filterState;

  int get activeCount => _agents.where((a) => a.isActive).length;
  int get idleCount => _agents.where((a) => a.isIdle).length;
  int get degradedCount => _agents.where((a) => a.isDegraded).length;

  void setFilter(String state) {
    _filterState = state;
    notifyListeners();
  }

  void selectAgent(AgentModel? agent) {
    _selectedAgent = agent;
    if (agent != null) {
      _selectedProfile = _profiles.firstWhere(
        (p) =>
            p.id == agent.profileId ||
            p.role == agent.profileId ||
            p.id == agent.id ||
            p.role == agent.role,
        orElse: () => _profiles.first,
      );
    } else {
      _selectedProfile = null;
    }
    notifyListeners();
  }

  ProfileModel? getProfileForAgent(String agentId) {
    if (_profiles.isEmpty) return null;
    return _profiles.firstWhere(
      (p) =>
          p.id.toLowerCase() == agentId.toLowerCase() ||
          p.role.toLowerCase() == agentId.toLowerCase(),
      orElse: () => _profiles.first,
    );
  }

  void selectProfile(ProfileModel profile) {
    _selectedProfile = profile;
    _selectedAgent = _agents.firstWhere(
      (a) =>
          a.profileId == profile.id ||
          a.id == profile.id ||
          a.role == profile.role,
      orElse: () => AgentModel(
        id: profile.id,
        name: profile.name,
        role: profile.operationalTitle.isNotEmpty
            ? profile.operationalTitle
            : profile.role,
        description: profile.description,
        state: 'ACTIVE',
        model: profile.model,
        currentActivity: 'Standing by for operational directives',
        profileId: profile.id,
        skills: profile.skills
            .map((s) => AgentSkill(
                  id: s,
                  name: s,
                  category: 'Capability',
                  health: 'HEALTHY',
                ))
            .toList(),
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAgentsAndProfiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = await Future.wait([
        repository.getAgents(),
        repository.getProfiles(),
      ]);

      _agents = futures[0] as List<AgentModel>;
      _profiles = futures[1] as List<ProfileModel>;
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAgents() => fetchAgentsAndProfiles();
  Future<void> fetchProfiles() => fetchAgentsAndProfiles();
}
