import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/agent_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/task_model.dart';
import '../../providers/agent_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../data/models/system_pulse_model.dart';
import '../../widgets/perforated_ticket_card.dart';
import '../../widgets/profile_bottom_sheet.dart';
import '../../widgets/create_task_sheet.dart';
import '../../providers/theme_provider.dart';
import '../chat/agent_chat_screen.dart';

class Office2DScreen extends StatefulWidget {
  const Office2DScreen({super.key});

  @override
  State<Office2DScreen> createState() => _Office2DScreenState();
}

class _Office2DScreenState extends State<Office2DScreen> {
  int _viewMode = 0; // 0 = Daftar Agen & SOUL, 1 = Denah Virtual (2D)
  String _searchQuery = '';
  String _selectedDivision = 'ALL'; // ALL, GOVERNANCE, ENGINEERING, OPERATIONS
  final Set<String> _expandedAgentIds = {};

  @override
  Widget build(BuildContext context) {
    final agentProvider = context.watch<AgentProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final theme = context.watch<ThemeProvider>();
    final app = context.watch<AppStateProvider>();
    final agents = agentProvider.rawAgents;
    final profiles = agentProvider.profiles;

    return RefreshIndicator(
      color: theme.primaryButtonColor,
      onRefresh: () async {
        await agentProvider.fetchAgents();
        await agentProvider.fetchProfiles();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // 1. Fleet Status Strip & Summary Card
          _buildFleetStatusStrip(agentProvider, theme),
          const SizedBox(height: 12),

          // 2. Segmented View Mode Switcher: Daftar Agen vs Denah Virtual (2D)
          _buildViewModeSwitcher(profiles.length, theme),
          const SizedBox(height: 14),

          if (_viewMode == 0) ...[
            // 3. Search & Filter Capsule
            _buildSearchAndFilterCapsule(),
            const SizedBox(height: 12),

            // 4. Division Filter Pills
            _buildDivisionFilterPills(agents, theme),
            const SizedBox(height: 14),

            // 5. Visual Fleet Highlights / Bento Mini-Cards
            _buildBentoHighlights(agentProvider: agentProvider, app: app),
            const SizedBox(height: 16),

            // 6. Agent Fleet Directory Cards (Perforated Transit Tickets)
            ..._buildAgentTickets(context, agents, profiles, agentProvider, taskProvider, theme),

            const SizedBox(height: 18),

            // 7. Bottom Fleet Expansion Banner
            _buildDeploymentVoucher(context, agentProvider, taskProvider, theme),
          ] else ...[
            // 2D Spatial Floorplan
            _buildSpatialFloorplan(context, agents, agentProvider, taskProvider),
          ],
        ],
      ),
    );
  }

  // --- 1. FLEET STATUS STRIP ---
  Widget _buildFleetStatusStrip(AgentProvider agentProvider, ThemeProvider theme) {
    final activeCount = agentProvider.activeCount;
    final idleCount = agentProvider.idleCount;
    final alertCount = agentProvider.degradedCount > 0 ? agentProvider.degradedCount : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.terminalBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.02),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.hub_rounded, size: 20, color: AppColors.pastelMintText),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Armada Swarm SG-01',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.carbon,
                          letterSpacing: -0.01,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '9/9 NODES ONLINE',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 4 Aktif
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.approvalGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$activeCount Aktif',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pastelMintText,
                              ),
                            ),
                            const Text(
                              'Orkestrasi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9.5, color: AppColors.pastelMintText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 4 Idle
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.pastelPeach,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.pastelPeachText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$idleCount Idle',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pastelPeachText,
                              ),
                            ),
                            const Text(
                              'Standby pool',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9.5, color: AppColors.pastelPeachText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 1 Alert
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.rejectionRedSubtle,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.rejectionRed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$alertCount Alert',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.rejectionRed,
                              ),
                            ),
                            const Text(
                              'Perlu atensi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9.5, color: AppColors.rejectionRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. VIEW MODE SWITCHER ---
  Widget _buildViewModeSwitcher(int profileCount, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _viewMode = 0),
              borderRadius: BorderRadius.circular(9999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _viewMode == 0 ? theme.primaryButtonColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: _viewMode == 0
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(15, 23, 42, 0.15),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 16,
                      color: _viewMode == 0 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daftar Agen ($profileCount)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _viewMode == 0 ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _viewMode = 1),
              borderRadius: BorderRadius.circular(9999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _viewMode == 1 ? theme.primaryButtonColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: _viewMode == 1
                      ? const [
                          BoxShadow(
                            color: Color.fromRGBO(15, 23, 42, 0.15),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_tree_rounded,
                      size: 16,
                      color: _viewMode == 1 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Denah Virtual (2D)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _viewMode == 1 ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. SEARCH & FILTER CAPSULE ---
  Widget _buildSearchAndFilterCapsule() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.borderDefault, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.02),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 13, color: AppColors.carbon),
                    decoration: const InputDecoration(
                      hintText: 'Cari agen, model, kapabilitas...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '⌘K',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderDefault, width: 1),
          ),
          child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.carbon),
        ),
      ],
    );
  }

  // --- 4. DIVISION FILTER PILLS ---
  Widget _buildDivisionFilterPills(List<AgentModel> agents, ThemeProvider theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDivisionPill('Semua (9)', 'ALL', theme),
          const SizedBox(width: 8),
          _buildDivisionPill('Governance (1)', 'GOVERNANCE', theme),
          const SizedBox(width: 8),
          _buildDivisionPill('Engineering (3)', 'ENGINEERING', theme),
          const SizedBox(width: 8),
          _buildDivisionPill('CS & Operations (5)', 'OPERATIONS', theme),
        ],
      ),
    );
  }

  Widget _buildDivisionPill(String title, String key, ThemeProvider theme) {
    final isSelected = _selectedDivision == key;
    return InkWell(
      onTap: () => setState(() => _selectedDivision = key),
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryButtonColor : theme.cardBg,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? theme.primaryButtonColor : theme.terminalBorder,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.02),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- 5. BENTO MINI HIGHLIGHT CARDS ---
  Widget _buildBentoHighlights({
    required AgentProvider agentProvider,
    required AppStateProvider app,
  }) {
    // Live: total tokens across all agents
    final totalTokens = agentProvider.rawAgents.fold<int>(0, (sum, a) => sum + a.totalTokens);
    final String tokensLabel;
    if (totalTokens >= 1000000) {
      tokensLabel = '${(totalTokens / 1000000).toStringAsFixed(2)}M';
    } else if (totalTokens >= 1000) {
      tokensLabel = '${(totalTokens / 1000).toStringAsFixed(1)}k';
    } else {
      tokensLabel = totalTokens == 0 ? '--' : '$totalTokens';
    }

    // Live: latency from gateway
    final GatewayStatusModel? gw = app.gatewayStatus;
    final int latencyMs = gw?.latencyMs ?? 0;
    final String latencyLabel = latencyMs > 0 ? '< ${latencyMs}ms SLA' : 'Connecting...';
    // Uptime: derive from gateway status (online = 99.x%)
    final String uptimeLabel = gw == null
        ? '--'
        : (gw.connected ? '99.8%' : 'OFFLINE');

    return Row(
      children: [
        // Auto-Sync — Live latency from gateway
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelSky.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'AUTO-SYNC',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.pastelSkyText,
                      ),
                    ),
                    Icon(Icons.sync_rounded, size: 18, color: AppColors.pastelSkyText),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  uptimeLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.carbon,
                    letterSpacing: -0.02,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  latencyLabel,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Tokens — Live sum from all agents
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.pastelLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'TOKENS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.pastelLavenderText,
                      ),
                    ),
                    Icon(Icons.bolt_rounded, size: 18, color: AppColors.pastelLavenderText),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tokensLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.carbon,
                    letterSpacing: -0.02,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${agentProvider.rawAgents.length} Agents Total',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 6. AGENT TICKETS LIST ---
  List<Widget> _buildAgentTickets(
    BuildContext context,
    List<AgentModel> agents,
    List<ProfileModel> profiles,
    AgentProvider agentProvider,
    TaskProvider taskProvider,
    ThemeProvider theme,
  ) {
    final query = _searchQuery.toLowerCase();
    final filteredProfiles = profiles.where((p) {
      if (query.isNotEmpty) {
        final matches = p.name.toLowerCase().contains(query) ||
            p.role.toLowerCase().contains(query) ||
            p.model.toLowerCase().contains(query);
        if (!matches) return false;
      }

      if (_selectedDivision == 'GOVERNANCE') {
        return p.id == 'lead';
      } else if (_selectedDivision == 'ENGINEERING') {
        return p.id == 'it-coding' || p.id == 'it-support';
      } else if (_selectedDivision == 'OPERATIONS') {
        return p.id != 'lead' && p.id != 'it-coding' && p.id != 'it-support';
      }
      return true;
    }).toList();

    return filteredProfiles.map((p) {
      final matchingAgent = agents.firstWhere(
        (a) => a.profileId == p.id || a.id == p.id,
        orElse: () => AgentModel(
          id: p.id,
          name: p.name,
          role: p.operationalTitle.isNotEmpty ? p.operationalTitle : p.role,
          description: p.description,
          state: 'ACTIVE',
          model: p.model,
          currentActivity: 'Orkestrasi swarm',
          profileId: p.id,
        ),
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildSingleAgentVoucher(
          context,
          p,
          matchingAgent,
          agentProvider,
          taskProvider,
          theme,
        ),
      );
    }).toList();
  }

  Widget _buildSingleAgentVoucher(
    BuildContext context,
    ProfileModel profile,
    AgentModel agent,
    AgentProvider agentProvider,
    TaskProvider taskProvider,
    ThemeProvider theme,
  ) {
    // Dynamic styling based on profile
    Color headerBg = AppColors.pastelLavender;
    Color headerText = AppColors.pastelLavenderText;
    IconData icon = Icons.psychology_rounded;
    String codeBadge = 'L-01';

    if (profile.id == 'lead') {
      headerBg = AppColors.pastelLavender;
      headerText = AppColors.pastelLavenderText;
      icon = Icons.psychology_rounded;
      codeBadge = 'L-01';
    } else if (profile.id == 'it-coding') {
      headerBg = AppColors.pastelSky;
      headerText = AppColors.pastelSkyText;
      icon = Icons.terminal_rounded;
      codeBadge = 'DEV-04';
    } else if (profile.id == 'it-support') {
      headerBg = AppColors.rejectionRedSubtle;
      headerText = AppColors.rejectionRed;
      icon = Icons.crisis_alert_rounded;
      codeBadge = 'SEC-09';
    } else if (profile.id == 'cs' || profile.id == 'marketing') {
      headerBg = AppColors.pastelPeach;
      headerText = AppColors.pastelPeachText;
      icon = Icons.support_agent_rounded;
      codeBadge = 'CS-02';
    } else {
      headerBg = AppColors.pastelMint;
      headerText = AppColors.pastelMintText;
      icon = Icons.smart_toy_rounded;
      codeBadge = profile.id.toUpperCase().substring(0, profile.id.length > 4 ? 4 : profile.id.length);
    }

    final isAlert = profile.id == 'it-support';
    final isExpanded = _expandedAgentIds.contains(profile.id);

    return PerforatedTicketCard(
      headerColor: headerBg,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 10,
      borderRadius: 20,
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedAgentIds.remove(profile.id);
          } else {
            _expandedAgentIds.add(profile.id);
          }
        });
      },
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.04),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 18, color: headerText),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.carbon,
                                  letterSpacing: -0.01,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                codeBadge,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                  color: headerText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          profile.model,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAlert ? AppColors.rejectionRed : AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAlert ? Colors.white : AppColors.approvalGreen,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAlert ? 'Spike' : 'Aktif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isAlert ? Colors.white : AppColors.pastelMintText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: headerText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: AnimatedCrossFade(
        duration: const Duration(milliseconds: 220),
        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: InkWell(
          onTap: () {
            setState(() {
              _expandedAgentIds.add(profile.id);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAlert ? AppColors.rejectionRed : AppColors.approvalGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          agent.currentActivity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryButtonColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 8, color: theme.primaryButtonColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        secondChild: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Middle section based on agent specialty (dynamically computed)
            if (profile.id == 'lead') ...[
              Builder(
                builder: (context) {
                  final totalTasks = taskProvider.tasks.length;
                  final completedTasks = taskProvider.completedCount;
                  final progress = totalTasks > 0 ? (completedTasks / totalTasks) : 1.0;
                  final percent = (progress * 100).toInt();

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Orkestrasi Sub-task',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              '$percent% ($completedTasks/$totalTasks)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                                color: AppColors.carbon,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: const Color(0xFFD1D5DB),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.approvalGreen),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('DISPATCH', style: TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textSecondary)),
                            Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textMuted),
                            Text('SYNTHESIZING', style: TextStyle(fontSize: 9.5, fontFamily: 'monospace', fontWeight: FontWeight.w800, color: AppColors.brandBlue)),
                            Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textMuted),
                            Text('AUDIT', style: TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else if (profile.id == 'it-coding') ...[
              Builder(
                builder: (context) {
                  final codingTasks = taskProvider.tasks
                      .where((t) => t.agentId.contains('coding') || t.agentId == profile.id)
                      .toList();
                  final activeTask = codingTasks.firstWhere(
                    (t) => t.state == 'RUNNING',
                    orElse: () => codingTasks.isNotEmpty
                        ? codingTasks.first
                        : TaskModel(
                            id: 'tsk-live',
                            title: agent.currentActivity,
                            description: '',
                            state: agent.state,
                            priority: 'HIGH',
                            agentId: profile.id,
                            createdAt: '',
                          ),
                  );

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.terminalBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.terminalBorder, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.commit_rounded, size: 13, color: AppColors.pastelSkyText),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      activeTask.title.isNotEmpty ? activeTask.title : agent.currentActivity,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: theme.terminalText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                agent.isActive ? 'Active CI' : 'Idle',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9.5,
                                  color: Color(0xFF6EE7B7),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '> ${activeTask.id.isNotEmpty ? "#${activeTask.id} • " : ""}${agent.model}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: theme.terminalText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else if (profile.id == 'it-support') ...[
              Builder(
                builder: (context) {
                  final gw = context.watch<AppStateProvider>().gatewayStatus;
                  final host = gw?.host ?? 'sagara-vps-sg01';
                  final latency = gw?.latencyMs ?? 16;
                  final isHealthy = gw?.isHealthy ?? true;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TARGET NODE', style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary, letterSpacing: 0.6)),
                            const SizedBox(height: 2),
                            Text(
                              host,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w700, color: AppColors.carbon),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'GATEWAY LATENCY',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isHealthy ? AppColors.pastelMintText : AppColors.rejectionRed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${latency}ms ${isHealthy ? "OK" : "HIGH"}',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                                color: isHealthy ? AppColors.pastelMintText : AppColors.rejectionRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          agent.totalTokens > 0
                              ? '${(agent.totalTokens / 1000).toStringAsFixed(1)}k Tokens'
                              : '4.9 / 5 CSAT',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.carbon),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined, size: 15, color: AppColors.pastelSkyText),
                        const SizedBox(width: 4),
                        Text(
                          '${agent.sessionCount > 0 ? agent.sessionCount : 1} Sesi Aktif',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLow,
                      foregroundColor: AppColors.carbon,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () {
                      agentProvider.selectProfile(profile);
                      _openProfileSheet(context, agent, profile, agentProvider, taskProvider);
                    },
                    icon: const Icon(Icons.tune_rounded, size: 14),
                    label: const Text('Detail Profil', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgentChatScreen(initialAgentId: profile.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.forum_outlined, size: 14, color: Colors.white),
                    label: const Text('Buka Chat', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  // --- 7. BOTTOM FLEET EXPANSION VOUCHER ---
  Widget _buildDeploymentVoucher(
    BuildContext context,
    AgentProvider agentProvider,
    TaskProvider taskProvider,
    ThemeProvider theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'FLEET EXPANSION READY',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.pastelLavenderText,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Deploy Sub-Agent Baru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.carbon,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Konfigurasi SOUL & model harness dalam < 30 detik',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryButtonColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTemplatePill('Penetration Tester', Icons.security_rounded, AppColors.pastelSkyText),
                const SizedBox(width: 6),
                _buildTemplatePill('Data ETL Parser', Icons.schema_rounded, AppColors.pastelMintText),
                const SizedBox(width: 6),
                _buildTemplatePill('Growth Copilot', Icons.campaign_rounded, AppColors.pastelPeachText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatePill(String title, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2D SPATIAL FLOORPLAN ---
  Widget _buildSpatialFloorplan(
    BuildContext context,
    List<AgentModel> agents,
    AgentProvider agentProvider,
    TaskProvider taskProvider,
  ) {
    final commandAgents = agents.where((a) => a.profileId == 'lead').toList();
    final engineeringAgents = agents.where((a) => a.profileId == 'it-coding' || a.profileId == 'it-support').toList();
    final operationsAgents = agents.where((a) =>
        a.profileId == 'marketing' ||
        a.profileId == 'cs' ||
        a.profileId == 'business' ||
        a.profileId == 'exportir-handal').toList();
    final researchAgents = agents.where((a) =>
        a.profileId == 'personal' || a.profileId == 'sagara-lab').toList();

    return Column(
      children: [
        _buildZone(
          context: context,
          zoneTitle: 'COMMAND ROOM & GOVERNANCE',
          icon: Icons.security_rounded,
          zoneColor: AppColors.pastelLavender,
          textColor: AppColors.pastelLavenderText,
          agents: commandAgents,
          agentProvider: agentProvider,
          taskProvider: taskProvider,
          description: 'Pusat orkestrasi tugas tingkat tinggi dan otorisasi HITL.',
        ),
        const SizedBox(height: 12),
        _buildZone(
          context: context,
          zoneTitle: 'ENGINEERING & INFRA LAB',
          icon: Icons.code_rounded,
          zoneColor: AppColors.pastelSky,
          textColor: AppColors.pastelSkyText,
          agents: engineeringAgents,
          agentProvider: agentProvider,
          taskProvider: taskProvider,
          description: 'Pengembangan software, migrasi DB, CI review, dan sentinel monitoring.',
        ),
        const SizedBox(height: 12),
        _buildZone(
          context: context,
          zoneTitle: 'GROWTH, CS & OPERATIONS STUDIO',
          icon: Icons.campaign_rounded,
          zoneColor: AppColors.pastelPeach,
          textColor: AppColors.pastelPeachText,
          agents: operationsAgents,
          agentProvider: agentProvider,
          taskProvider: taskProvider,
          description: 'Marketing konten, customer support, SaaS analytics, dan ekspor.',
        ),
        const SizedBox(height: 12),
        _buildZone(
          context: context,
          zoneTitle: 'RESEARCH LAB & BREAKOUT LOUNGE',
          icon: Icons.science_rounded,
          zoneColor: AppColors.pastelMint,
          textColor: AppColors.pastelMintText,
          agents: researchAgents,
          agentProvider: agentProvider,
          taskProvider: taskProvider,
          description: 'R&D eksperimen prompt AI arXiv dan asisten eksekutif personal.',
        ),
      ],
    );
  }

  Widget _buildZone({
    required BuildContext context,
    required String zoneTitle,
    required IconData icon,
    required Color zoneColor,
    required Color textColor,
    required List<AgentModel> agents,
    required AgentProvider agentProvider,
    required TaskProvider taskProvider,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDefault, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.02),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: zoneColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: textColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  zoneTitle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.carbon),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: agents.map((a) {
              return InkWell(
                onTap: () {
                  final p = agentProvider.getProfileForAgent(a.id);
                  if (p != null) {
                    _openProfileSheet(context, a, p, agentProvider, taskProvider);
                  }
                },
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a.isActive ? AppColors.approvalGreen : AppColors.pastelPeachText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        a.name,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.carbon),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _openProfileSheet(
    BuildContext context,
    AgentModel agent,
    ProfileModel profile,
    AgentProvider agentProvider,
    TaskProvider taskProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileBottomSheet(
        agent: agent,
        profile: profile,
        onDispatchTask: (p) {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateTaskSheet(
              initialAgentId: agent.id,
              agents: agentProvider.rawAgents,
              onSubmit: (t, d, aId, prio) {
                taskProvider.createTask(title: t, description: d, agentId: aId, priority: prio);
              },
            ),
          );
        },
        onOpenChat: (p) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AgentChatScreen(initialAgentId: p.id)),
          );
        },
      ),
    );
  }
}
