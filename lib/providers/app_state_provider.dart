import 'package:flutter/material.dart';
import '../core/network/realtime_sync_service.dart';
import '../data/models/approval_model.dart';
import '../data/models/system_pulse_model.dart';
import '../data/repositories/sagara_repository.dart';

class AppStateProvider with ChangeNotifier {
  final SagaraRepository repository;
  late final RealtimeSyncService _syncService;

  int _selectedTabIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  GatewayStatusModel? _gatewayStatus;
  InfrastructureMetrics? _infrastructure;
  List<AttentionItem> _attentionItems = [];
  List<RecentActivityEvent> _recentActivities = [];
  ApprovalModel? _latestHighRiskAlert;

  AppStateProvider({required this.repository}) {
    _syncService = RealtimeSyncService(
      repository: repository,
      onDataUpdated: () {
        refreshDashboard(silent: true);
      },
      onHighRiskApprovalReceived: (appr) {
        _latestHighRiskAlert = appr;
        notifyListeners();
      },
    );

    refreshDashboard();
    _syncService.start();
  }

  RealtimeSyncService get syncService => _syncService;
  RealtimeConnectionStatus get syncStatus => _syncService.status;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isMockMode => repository.isMockMode;
  String get baseUrl => repository.baseUrl;
  bool get isKillSwitchActive => repository.isKillSwitchActive;
  ApprovalModel? get latestHighRiskAlert => _latestHighRiskAlert;

  GatewayStatusModel? get gatewayStatus => _gatewayStatus;
  InfrastructureMetrics? get infrastructure => _infrastructure;
  List<AttentionItem> get attentionItems => _attentionItems;
  List<RecentActivityEvent> get recentActivities => _recentActivities;

  void dismissHighRiskAlert() {
    _latestHighRiskAlert = null;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void toggleMode(bool useMock) {
    repository.isMockMode = useMock;
    repository.savePreferences();
    _syncService.switchMode();
    refreshDashboard();
    notifyListeners();
  }

  void updateBaseUrl(String url) {
    repository.baseUrl = url.trim();
    repository.savePreferences();
    _syncService.switchMode();
    refreshDashboard();
    notifyListeners();
  }

  void toggleKillSwitch() {
    repository.toggleKillSwitch(!repository.isKillSwitchActive);
    notifyListeners();
  }

  Future<void> testAudibleHighRiskAlert() async {
    await _syncService.triggerTestHighRiskAlert();
  }

  Future<void> refreshDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final futures = await Future.wait([
        repository.getGatewayStatus(),
        repository.getInfrastructureMetrics(),
        repository.getAttentionItems(),
        repository.getRecentActivities(),
      ]);

      _gatewayStatus = futures[0] as GatewayStatusModel;
      _infrastructure = futures[1] as InfrastructureMetrics;
      _attentionItems = futures[2] as List<AttentionItem>;
      _recentActivities = futures[3] as List<RecentActivityEvent>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
