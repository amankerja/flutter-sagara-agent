import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/agent_provider.dart';
import '../../providers/approval_provider.dart';
import '../../widgets/perforated_ticket_card.dart';
import '../../providers/theme_provider.dart';
import '../chat/agent_chat_screen.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  String _selectedEventFilter = 'ALL'; // ALL, DISPATCH, AUDIT, ROLLBACK
  final Set<String> _expandedFleetIds = {};

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final agentProvider = context.watch<AgentProvider>();
    final approvalProvider = context.watch<ApprovalProvider>();
    final theme = context.watch<ThemeProvider>();
    final infra = app.infrastructure;
    final gw = app.gatewayStatus;

    // Dynamically prioritize live pending approvals from ApprovalProvider
    final hasPendingApprovals = approvalProvider.pendingApprovals.isNotEmpty;
    final hasAttention = app.attentionItems.isNotEmpty;
    final attentionCount = hasPendingApprovals
        ? approvalProvider.pendingCount
        : app.attentionItems.length;
    final attentionTitle = hasPendingApprovals
        ? '${approvalProvider.pendingCount} Approvals Blocked'
        : (hasAttention ? '${app.attentionItems.length} Actions Required' : '');
    final attentionDesc = hasPendingApprovals
        ? approvalProvider.pendingApprovals.first.title
        : (hasAttention ? app.attentionItems.first.description : '');

    return RefreshIndicator(
      color: theme.primaryButtonColor,
      onRefresh: () async {
        await Future.wait([
          app.refreshDashboard(),
          taskProvider.fetchTasks(),
          agentProvider.fetchAgents(),
          approvalProvider.fetchApprovals(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), // Extra bottom padding for floating dock
        children: [
          // 1. Aerodynamic Telemetry Status Hero Card
          _buildHeroTelemetryCard(app, infra, gw),
          const SizedBox(height: 18),

          // 2. Department Division Units (Travel App Transport Metaphor)
          _buildDepartmentUnits(context, app),
          const SizedBox(height: 20),

          // 3. Attention Voucher Banner (Ticket Stash Perforated Design)
          if (hasPendingApprovals || hasAttention) ...[
            _buildAttentionVoucher(
              context: context,
              app: app,
              count: attentionCount,
              title: attentionTitle,
              description: attentionDesc,
              theme: theme,
            ),
            const SizedBox(height: 20),
          ],

          // 4. Work Stream Pipeline (4 Operational Counters)
          _buildWorkStreamPipeline(context, app, taskProvider, approvalProvider, theme),
          const SizedBox(height: 22),

          // 5. Active Autonomous Agents List (Active Fleet Units)
          _buildActiveFleetSection(context, app, agentProvider, taskProvider, theme),
          const SizedBox(height: 22),

          // 6. Live Swarm Telemetry Activity Stream
          _buildLiveTelemetryStream(app, theme),
        ],
      ),
    );
  }

  // --- 1. HERO TELEMETRY CARD ---
  Widget _buildHeroTelemetryCard(AppStateProvider app, dynamic infra, dynamic gw) {
    final cpuLoad = infra?.cpuPercent ?? 18;
    final memUsed = infra?.memoryUsedMb ?? 1420;
    final memPercent = infra?.memoryPercent ?? 38;
    final latency = gw?.latencyMs ?? 16;
    final host = gw?.host ?? 'sagara-vps-sg01';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pastelMint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCCFBF1), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(13, 148, 136, 0.04),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Atmospheric tech curves
          Positioned(
            right: -20,
            bottom: -15,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.hub_rounded,
                size: 140,
                color: AppColors.pastelMintText,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row badge + host
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.03),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.approvalGreen,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'ONLINE • ${latency}ms',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              color: AppColors.pastelMintText,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        host,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title & Subtitle
                const Text(
                  'AUTONOMOUS GATEWAY',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mission Control',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.carbon,
                    letterSpacing: -0.02,
                  ),
                ),
                const SizedBox(height: 14),

                // Telemetry metrics row (Horizontally scrollable to avoid overflow on narrow screens)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.dns_outlined, size: 16, color: AppColors.pastelMintText),
                          SizedBox(width: 5),
                          Text(
                            'Cluster SG-Primary',
                            style: TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.borderDashed)),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.memory_rounded, size: 16, color: AppColors.pastelMintText),
                          const SizedBox(width: 5),
                          Text(
                            'RAM $memPercent% ($memUsed MB)',
                            style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.borderDashed)),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 16, color: AppColors.pastelMintText),
                          const SizedBox(width: 4),
                          Text(
                            'CPU $cpuLoad%',
                            style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. DEPARTMENT DIVISION UNITS ---
  Widget _buildDepartmentUnits(BuildContext context, AppStateProvider app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Department Units',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.carbon,
                letterSpacing: -0.01,
              ),
            ),
            InkWell(
              onTap: () => app.setTabIndex(2), // Jump to Armada
              child: const Text(
                'MANAGE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.pastelSkyText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 1. Governance
            Expanded(
              child: _buildUnitCard(
                title: 'Governance',
                icon: Icons.shield_rounded,
                bgColor: AppColors.pastelLavender,
                textColor: AppColors.pastelLavenderText,
                onTap: () => app.setTabIndex(1), // Approvals
              ),
            ),
            const SizedBox(width: 8),
            // 2. Infra Lab
            Expanded(
              child: _buildUnitCard(
                title: 'Infra Lab',
                icon: Icons.terminal_rounded,
                bgColor: AppColors.pastelMint,
                textColor: AppColors.pastelMintText,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgentChatScreen(initialAgentId: 'it-coding')),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 3. Growth & CS
            Expanded(
              child: _buildUnitCard(
                title: 'Growth & CS',
                icon: Icons.auto_awesome_rounded,
                bgColor: AppColors.pastelPeach,
                textColor: AppColors.pastelPeachText,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgentChatScreen(initialAgentId: 'cs')),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 4. Swarm Sync
            Expanded(
              child: _buildUnitCard(
                title: 'Swarm Sync',
                icon: Icons.hub_rounded,
                bgColor: AppColors.pastelSky,
                textColor: AppColors.pastelSkyText,
                onTap: () => app.setTabIndex(2), // 2D office
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitCard({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
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
              child: Icon(icon, size: 20, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.01,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. ATTENTION VOUCHER BANNER (PERFORATED TICKET CARD) ---
  Widget _buildAttentionVoucher({
    required BuildContext context,
    required AppStateProvider app,
    required int count,
    required String title,
    required String description,
    required ThemeProvider theme,
  }) {
    return PerforatedTicketCard(
      headerColor: AppColors.pastelPeach,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 9,
      borderRadius: 18,
      onTap: () => app.setTabIndex(1), // Go to approvals
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.warning_rounded, size: 18, color: AppColors.pastelPeachText),
                SizedBox(width: 8),
                Text(
                  'HUMAN-IN-THE-LOOP CLEARANCE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.pastelPeachText,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Text(
                'GATE 03',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: AppColors.pastelPeachText,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.carbon,
                letterSpacing: -0.01,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.timer_outlined, size: 15, color: AppColors.rejectionRed),
                    SizedBox(width: 4),
                    Text(
                      'Action Required',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: AppColors.rejectionRed,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  onPressed: () => app.setTabIndex(1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Review Tickets', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. WORK STREAM PIPELINE (4 COUNTERS) ---
  Widget _buildWorkStreamPipeline(
    BuildContext context,
    AppStateProvider app,
    TaskProvider taskProvider,
    ApprovalProvider approvalProvider,
    ThemeProvider theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Work Stream Pipeline',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.carbon,
                letterSpacing: -0.01,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'TASKS (${taskProvider.tasks.length})',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Ready
            Expanded(
              child: _buildQueueTile(
                label: 'Ready',
                count: taskProvider.readyCount,
                tag: 'Queued',
                tagColor: AppColors.pastelSkyText,
                dotColor: AppColors.pastelSkyText,
                theme: theme,
                onTap: () {
                  taskProvider.setFilter('READY');
                  app.setTabIndex(3);
                },
              ),
            ),
            const SizedBox(width: 8),
            // Active
            Expanded(
              child: _buildQueueTile(
                label: 'Active',
                count: taskProvider.runningCount,
                tag: 'Running',
                tagColor: AppColors.pastelMintText,
                dotColor: AppColors.approvalGreen,
                theme: theme,
                onTap: () {
                  taskProvider.setFilter('RUNNING');
                  app.setTabIndex(3);
                },
              ),
            ),
            const SizedBox(width: 8),
            // Needs OK / Hold
            Expanded(
              child: _buildQueueTile(
                label: 'Needs OK',
                count: approvalProvider.pendingCount,
                tag: 'Hold',
                tagColor: AppColors.rejectionRed,
                dotColor: AppColors.rejectionRed,
                isAlert: approvalProvider.pendingCount > 0,
                theme: theme,
                onTap: () => app.setTabIndex(1),
              ),
            ),
            const SizedBox(width: 8),
            // Done
            Expanded(
              child: _buildQueueTile(
                label: 'Done',
                count: taskProvider.completedCount,
                tag: 'Today',
                tagColor: AppColors.textSecondary,
                theme: theme,
                onTap: () {
                  taskProvider.setFilter('COMPLETED');
                  app.setTabIndex(3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQueueTile({
    required String label,
    required int count,
    required String tag,
    required Color tagColor,
    Color? dotColor,
    bool isAlert = false,
    required VoidCallback onTap,
    required ThemeProvider theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isAlert ? AppColors.rejectionRedSubtle : theme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAlert ? const Color(0xFFFECACA) : theme.terminalBorder,
            width: 1,
          ),
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
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isAlert ? AppColors.rejectionRed : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isAlert ? AppColors.rejectionRed : AppColors.carbon,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 5. ACTIVE FLEET UNITS SECTION ---
  Widget _buildActiveFleetSection(
    BuildContext context,
    AppStateProvider app,
    AgentProvider agentProvider,
    TaskProvider taskProvider,
    ThemeProvider theme,
  ) {
    final rawAgents = agentProvider.rawAgents;
    final activeAgents = rawAgents.where((a) => a.isActive).toList();
    final displayAgents = activeAgents.isNotEmpty
        ? activeAgents.take(3).toList()
        : rawAgents.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Active Fleet Units',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.carbon,
                    letterSpacing: -0.01,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${agentProvider.activeCount} Live',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => app.setTabIndex(2), // All armada
              child: const Text(
                'ALL ARMADA',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.pastelSkyText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (displayAgents.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.terminalBorder),
            ),
            child: const Center(
              child: Text(
                'Tidak ada unit armada terdeteksi',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...displayAgents.map((agent) {
            Color iconColor = AppColors.pastelSky;
            Color iconTextColor = AppColors.pastelSkyText;
            IconData icon = Icons.smart_toy_outlined;
            String version = 'v3.5';

            if (agent.id.contains('lead')) {
              iconColor = AppColors.pastelLavender;
              iconTextColor = AppColors.pastelLavenderText;
              icon = Icons.psychology_rounded;
              version = 'v3.7';
            } else if (agent.id.contains('coding')) {
              iconColor = AppColors.pastelSky;
              iconTextColor = AppColors.pastelSkyText;
              icon = Icons.terminal_rounded;
              version = 'v3.5';
            } else if (agent.id.contains('support')) {
              iconColor = AppColors.pastelMint;
              iconTextColor = AppColors.pastelMintText;
              icon = Icons.health_and_safety_rounded;
              version = 'v2.4';
            } else if (agent.id.contains('cs')) {
              iconColor = AppColors.pastelMint;
              iconTextColor = AppColors.pastelMintText;
              icon = Icons.headset_mic_rounded;
              version = 'v2.1';
            } else if (agent.id.contains('marketing')) {
              iconColor = AppColors.pastelPeach;
              iconTextColor = AppColors.pastelPeachText;
              icon = Icons.campaign_rounded;
              version = 'v2.0';
            }

            // Correlate with active task assigned to this agent
            final assignedTasks = taskProvider.tasks
                .where((t) => t.agentId == agent.id || t.agentId == agent.profileId)
                .toList();
            final runningTask = assignedTasks.firstWhere(
              (t) => t.state == 'RUNNING',
              orElse: () => assignedTasks.isNotEmpty
                  ? assignedTasks.first
                  : const TaskModel(
                      id: '',
                      title: '',
                      description: '',
                      state: 'READY',
                      priority: 'MEDIUM',
                      agentId: '',
                      createdAt: '',
                    ),
            );

            final subtask = runningTask.title.isNotEmpty ? runningTask.title : agent.currentActivity;
            final progressPercent = agent.isActive ? 78 : (agent.isIdle ? 100 : 35);
            final tokenMemory = agent.totalTokens > 0
                ? '${(agent.totalTokens / 1000).toStringAsFixed(1)}k tokens'
                : '${agent.sessionCount} sessions';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAgentCard(
                context: context,
                agentId: agent.id,
                name: agent.name,
                version: version,
                model: agent.model,
                subtask: subtask,
                progressPercent: progressPercent,
                tokenMemory: tokenMemory,
                dispatchTarget: agent.id.contains('coding') ? null : 'Infra-01',
                terminalSnippet: agent.id.contains('coding')
                    ? '> git checkout -b agent/task-${agent.id} && pnpm test'
                    : null,
                iconColor: iconColor,
                iconTextColor: iconTextColor,
                icon: icon,
                theme: theme,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAgentCard({
    required BuildContext context,
    required String agentId,
    required String name,
    required String version,
    required String model,
    required String subtask,
    required int progressPercent,
    required String tokenMemory,
    String? dispatchTarget,
    String? terminalSnippet,
    required Color iconColor,
    required Color iconTextColor,
    required IconData icon,
    required ThemeProvider theme,
  }) {
    final isExpanded = _expandedFleetIds.contains(agentId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedFleetIds.remove(agentId);
          } else {
            _expandedFleetIds.add(agentId);
          }
        });
      },
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.terminalBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.03),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Compact Header Row (always visible) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 20, color: iconTextColor),
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
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.carbon,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: iconColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  version,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'monospace',
                                    color: iconTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            model,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Progress badge + chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.pastelMint,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: AppColors.pastelMintText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- Expandable Body ---
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
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
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      subtask,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Ketuk detail',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtask + progress
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtask,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.carbon,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: LinearProgressIndicator(
                            value: progressPercent / 100.0,
                            minHeight: 4,
                            backgroundColor: const Color(0xFFCBD5E1),
                            valueColor: AlwaysStoppedAnimation<Color>(iconTextColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Terminal or memory info
                        if (terminalSnippet != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.terminalBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.terminalBorder, width: 1),
                            ),
                            child: Text(
                              terminalSnippet,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: theme.terminalText,
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              const Icon(Icons.memory_rounded, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                tokenMemory,
                                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textSecondary),
                              ),
                              if (dispatchTarget != null) ...[
                                const SizedBox(width: 10),
                                Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.borderDashed)),
                                const SizedBox(width: 6),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.approvalGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'To $dispatchTarget',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Chat button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerLow,
                        foregroundColor: AppColors.carbon,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AgentChatScreen(initialAgentId: agentId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.forum_outlined, size: 14, color: AppColors.carbon),
                      label: const Text('Buka Chat Sesi Agen', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // --- 6. LIVE SWARM TELEMETRY STREAM ---
  Widget _buildLiveTelemetryStream(AppStateProvider app, ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Live Swarm Telemetry',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.carbon,
                letterSpacing: -0.01,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.approvalGreen,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'STREAMING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: AppColors.pastelMintText,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStreamFilterPill('All Events', 'ALL', theme),
              const SizedBox(width: 6),
              _buildStreamFilterPill('Swarm Dispatch', 'DISPATCH', theme),
              const SizedBox(width: 6),
              _buildStreamFilterPill('Audits & Tests', 'AUDIT', theme),
              const SizedBox(width: 6),
              _buildStreamFilterPill('Rollbacks', 'ROLLBACK', theme),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Stream Items
        Builder(
          builder: (context) {
            final filteredActivities = app.recentActivities.where((act) {
              if (_selectedEventFilter == 'ALL') return true;
              final type = act.actionType.toUpperCase();
              if (_selectedEventFilter == 'DISPATCH') {
                return type.contains('DISPATCH') || type.contains('EXEC') || type.contains('TASK') || type.contains('ROUT');
              }
              if (_selectedEventFilter == 'AUDIT') {
                return type.contains('AUDIT') || type.contains('APPROVAL') || type.contains('TEST') || type.contains('CHECK');
              }
              if (_selectedEventFilter == 'ROLLBACK') {
                return type.contains('ROLLBACK') || type.contains('ALERT') || type.contains('FAIL') || type.contains('WARN');
              }
              return true;
            }).toList();

            if (filteredActivities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.terminalBorder),
                ),
                child: const Center(
                  child: Text(
                    'Tidak ada aktivitas yang sesuai dengan filter',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredActivities.length > 5 ? 5 : filteredActivities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final act = filteredActivities[index];
            final isApproval = act.actionType.contains('APPROVAL');
            final isNotif = act.actionType.contains('NOTIFICATION') || act.actionType.contains('ALERT');

            final iconBg = isApproval
                ? AppColors.pastelLavender
                : (isNotif ? AppColors.pastelPeach : AppColors.pastelMint);
            final iconColor = isApproval
                ? AppColors.pastelLavenderText
                : (isNotif ? AppColors.pastelPeachText : AppColors.pastelMintText);
            final icon = isApproval
                ? Icons.verified_user_rounded
                : (isNotif ? Icons.flag_rounded : Icons.check_circle_rounded);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.terminalBorder, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(15, 23, 42, 0.02),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                act.summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.carbon,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              act.timestamp,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${act.agentName} • ${act.actionType}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  ],
);
  }

  Widget _buildStreamFilterPill(String title, String filterKey, ThemeProvider theme) {
    final isSelected = _selectedEventFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedEventFilter = filterKey),
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
}
