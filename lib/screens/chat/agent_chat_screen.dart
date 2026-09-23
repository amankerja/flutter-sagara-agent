import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/agent_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../providers/agent_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/chat_task_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/perforated_ticket_card.dart';
import '../../widgets/profile_bottom_sheet.dart';

class AgentChatScreen extends StatefulWidget {
  final String initialAgentId;
  final String? initialSessionId;

  const AgentChatScreen({
    super.key,
    this.initialAgentId = 'lead',
    this.initialSessionId,
  });

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  late String _currentAgentId;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedPriority = 'MEDIUM'; // LOW, MEDIUM, HIGH, CRITICAL

  @override
  void initState() {
    super.initState();
    _currentAgentId = widget.initialAgentId.trim().isNotEmpty ? widget.initialAgentId.trim() : 'lead';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatTaskProvider>(context, listen: false);
      chatProvider.fetchSessionsForAgent(_currentAgentId);
      if (widget.initialSessionId != null) {
        chatProvider.loadSession(widget.initialSessionId!, _currentAgentId).then((_) => _scrollToBottom());
      } else {
        chatProvider.loadLatestSession(_currentAgentId).then((_) => _scrollToBottom());
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final targetAgentId = _currentAgentId.trim().isNotEmpty ? _currentAgentId.trim() : 'lead';

    _textController.clear();
    final chatProvider = Provider.of<ChatTaskProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    chatProvider.sendUserMessage(
      agentId: targetAgentId,
      text: text,
      priority: _selectedPriority,
      taskProvider: taskProvider,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final agentProvider = Provider.of<AgentProvider>(context);
    final chatProvider = Provider.of<ChatTaskProvider>(context);
    final theme = context.watch<ThemeProvider>();
    final app = context.watch<AppStateProvider>();
    final agents = agentProvider.rawAgents.isNotEmpty ? agentProvider.rawAgents : agentProvider.agents;

    final currentAgent = agents.firstWhere(
      (a) => a.id.toLowerCase() == _currentAgentId.toLowerCase(),
      orElse: () => agents.isNotEmpty
          ? agents.first
          : const AgentModel(
              id: 'lead',
              name: 'Lead Manager Agent',
              role: 'Fleet Operations Coordinator',
              description: 'Lead operations agent',
              state: 'ACTIVE',
              model: 'claude-3-5-sonnet',
              currentActivity: 'Orchestrating fleet operations',
            ),
    );

    if (_currentAgentId.isEmpty || !agents.any((a) => a.id.toLowerCase() == _currentAgentId.toLowerCase())) {
      _currentAgentId = currentAgent.id;
    }

    final currentProfile = agentProvider.getProfileForAgent(currentAgent.id);
    final messages = chatProvider.getMessages(_currentAgentId);
    final isTyping = chatProvider.isTyping(_currentAgentId);
    final suggestions = chatProvider.getSuggestions(_currentAgentId);

    return Scaffold(
      backgroundColor: theme.canvasBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardBg,
            border: Border(bottom: BorderSide(color: theme.terminalBorder)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.carbon),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.pastelMint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.terminal_rounded, size: 18, color: AppColors.pastelMintText),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Live Execution Trace',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.carbon,
                            letterSpacing: -0.01,
                          ),
                        ),
                        Text(
                          'NODE • SG-01 // AUDIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Lihat SOUL & Profil',
                    icon: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: theme.primaryButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded, size: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ProfileBottomSheet(
                          agent: currentAgent,
                          profile: currentProfile,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                // 1. Agent Sub-header & Session Banner
                _buildAgentSessionBanner(context, currentAgent, chatProvider, agents),
                const SizedBox(height: 12),

                // 2. Horizontal Telemetry Ribbon
                _buildTelemetryRibbon(app: app, agent: currentAgent),
                const SizedBox(height: 16),

                // Timestamp Divider
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'TODAY • 14:32:08 UTC',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Message Stream
                if (messages.isEmpty)
                  _buildEmptyState(currentAgent)
                else
                  ...messages.map((msg) => _buildMessageItem(context, msg, currentAgent, theme)),

                if (isTyping) _buildTypingIndicator(currentAgent, theme),
              ],
            ),
          ),

          // 4. Quick Command Dispatch Chips
          if (suggestions.isNotEmpty) _buildQuickCommandsTray(suggestions),

          // 5. Mission Priority Selector
          _buildPrioritySelector(theme),

          // 6. Floating Capsule Command Input Bar
          _buildFloatingInputCapsule(currentAgent, theme),
        ],
      ),
    );
  }

  // --- 1. AGENT SUB-HEADER & SESSION BANNER ---
  Widget _buildAgentSessionBanner(
    BuildContext context,
    AgentModel agent,
    ChatTaskProvider chatProvider,
    List<AgentModel> agents,
  ) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.pastelMint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.terminal_rounded, size: 20, color: AppColors.pastelMintText),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.approvalGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
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
                                  agent.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.carbon,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelLavender,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    agent.model,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.pastelLavenderText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Builder(builder: (ctx) {
                            final agentProv = Provider.of<AgentProvider>(ctx, listen: false);
                            final profile = agentProv.getProfileForAgent(agent.id);
                            final primaryChannel = (profile != null && profile.channelRoutes.isNotEmpty)
                                ? profile.channelRoutes.first
                                : '#${agent.id}';
                            final sessId = chatProvider.getActiveSessionId(agent.id) ?? "sess-main";
                            return Text(
                              'Profil: ${agent.id} • Session: $sessId • Channel: $primaryChannel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.0,
                                fontFamily: 'monospace',
                                color: AppColors.textSecondary,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showAgentSelector(context, agents),
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Active Subtask Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pastelSky.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.commit_rounded, size: 16, color: AppColors.pastelSkyText),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE SUBTASK',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.pastelSkyText,
                        ),
                      ),
                      Text(
                        agent.currentActivity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.carbon,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: AppColors.pastelSkyText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. HORIZONTAL TELEMETRY RIBBON ---
  Widget _buildTelemetryRibbon({required AppStateProvider app, required AgentModel agent}) {
    final latencyMs = app.gatewayStatus?.latencyMs ?? 0;
    final latencyText = latencyMs > 0 ? 'Latency: ${latencyMs}ms' : 'Latency: --';
    final isOnline = app.gatewayStatus?.connected ?? false;
    final agentTokens = agent.totalTokens;
    final tokenText = agentTokens >= 1000
        ? 'Tokens: ${(agentTokens / 1000).toStringAsFixed(1)}k'
        : (agentTokens > 0 ? 'Tokens: $agentTokens' : 'Tokens: --');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Latency — live
          _buildTelemetryChip(
            dotColor: latencyMs > 0 && latencyMs < 200 ? AppColors.approvalGreen : AppColors.pastelPeachText,
            text: latencyText,
          ),
          const SizedBox(width: 8),
          // Tokens — live from agent
          _buildTelemetryChip(
            icon: Icons.storage_rounded,
            iconColor: AppColors.pastelLavenderText,
            text: tokenText,
          ),
          const SizedBox(width: 8),
          // Connection status — live
          _buildTelemetryChip(
            bgColor: isOnline ? AppColors.pastelMint : AppColors.pastelPeach,
            icon: isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            iconColor: isOnline ? AppColors.pastelMintText : AppColors.pastelPeachText,
            text: isOnline ? 'Replica Online (SG-01)' : 'Connecting...',
            textColor: isOnline ? AppColors.pastelMintText : AppColors.pastelPeachText,
            isBold: true,
          ),
          const SizedBox(width: 8),
          // Model of agent
          _buildTelemetryChip(
            icon: Icons.smart_toy_rounded,
            iconColor: AppColors.pastelPeachText,
            text: agent.model.isNotEmpty ? agent.model : 'Unknown Model',
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryChip({
    IconData? icon,
    Color? iconColor,
    Color? dotColor,
    Color? bgColor,
    Color? textColor,
    required String text,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.borderDefault, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.02),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10.5,
              fontFamily: 'monospace',
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: textColor ?? AppColors.carbon,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. MESSAGE ITEM ---
  Widget _buildMessageItem(
    BuildContext context,
    ChatMessageModel msg,
    AgentModel agent,
    ThemeProvider theme,
  ) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.userChatBubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.userChatBubbleBg.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(fontSize: 13, color: theme.userChatBubbleText, height: 1.35),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.timestamp),
                  style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textSecondary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.done_all_rounded, size: 14, color: AppColors.pastelSkyText),
              ],
            ),
          ],
        ),
      );
    }

    // Check if this message is a Tool Execution
    if (msg.toolName != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildToolTicketCard(msg, theme),
      );
    }

    // Check if this message contains an HITL proposal
    if (msg.text.contains('HITL') || msg.text.contains('Simulasi') || msg.text.contains('Migrasi')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _buildHitlProposalTicket(msg, theme),
      );
    }

    // Standard Agent Explanation Bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.pastelMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_rounded, size: 13, color: AppColors.pastelMintText),
              ),
              const SizedBox(width: 6),
              Text(
                agent.name,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.carbon),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: theme.terminalBorder, width: 1),
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
                  msg.text,
                  style: const TextStyle(fontSize: 13, color: AppColors.carbon, height: 1.4),
                ),
                if (msg.linkedTaskId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Task: ${msg.linkedTaskId}',
                          style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.carbon, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TOOL EXECUTION TICKET CARD ---
  Widget _buildToolTicketCard(ChatMessageModel msg, ThemeProvider theme) {
    return PerforatedTicketCard(
      headerColor: AppColors.pastelMint,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 8,
      borderRadius: 16,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle_rounded, size: 18, color: AppColors.pastelMintText),
                const SizedBox(width: 6),
                Text(
                  'TOOL DISPATCH • ${msg.toolName?.toUpperCase() ?? "EXEC-891"}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.pastelMintText,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, size: 11, color: AppColors.approvalGreen),
                  SizedBox(width: 3),
                  Text(
                    'SUCCESS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: AppColors.approvalGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('RUN: codebase_inspector()', style: TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.textSecondary)),
                Text('TIME: 412ms', style: TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.terminalBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.terminalBorder, width: 1),
              ),
              child: Text(
                msg.toolOutput ?? '// AST Diff Tree:\n+ def acquire_wal_checkpoint(mode="PASSIVE")\n- db.execute("PRAGMA synchronous = FULL;")',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  color: theme.terminalText,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Target: SQLite Replica SG-01', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                Text('View full AST trace >', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.pastelSkyText)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- HITL AUTHORIZATION REQUEST TICKET ---
  Widget _buildHitlProposalTicket(ChatMessageModel msg, ThemeProvider theme) {
    return PerforatedTicketCard(
      headerColor: AppColors.pastelLavender,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 8,
      borderRadius: 16,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.verified_user_rounded, size: 18, color: AppColors.pastelLavenderText),
                SizedBox(width: 6),
                Text(
                  'HITL ACTION • TICKET #AUTH-402',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.pastelLavenderText,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.pastelPeach,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Text(
                'AWAITING APPROVAL',
                style: TextStyle(
                  fontSize: 8.5,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reindex Dry-Run Proposal',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.carbon),
            ),
            const SizedBox(height: 2),
            const Text(
              'Dry-run simulasi migrasi B-Tree & validasi integritas WAL',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            // Telemetry stats row
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: const [
                      Text('Est. Lock', style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                      Text('12 ms', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppColors.approvalGreen)),
                    ],
                  ),
                  Column(
                    children: const [
                      Text('Rows Affected', style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                      Text('148,290', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppColors.carbon)),
                    ],
                  ),
                  Column(
                    children: const [
                      Text('Safety Check', style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                      Text('PASSED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppColors.pastelSkyText)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // JSON Payload drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.terminalBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.terminalBorder, width: 1),
              ),
              child: Text(
                '{\n  "action": "REINDEX_BTREE_SIMULATION",\n  "target_table": "telemetry_event_ledger",\n  "lock_strategy": "DEFERRED_SHARED"\n}',
                style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: theme.terminalText),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.approvalGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Otorisasi disetujui & dikirim ke replica')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 15),
                    label: const Text('Otorisasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.rejectionRedSubtle,
                      foregroundColor: AppColors.rejectionRed,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✕ Eksekusi ditolak oleh operator')),
                      );
                    },
                    icon: const Icon(Icons.cancel_rounded, size: 15),
                    label: const Text('Tolak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 4. QUICK COMMANDS TRAY ---
  Widget _buildQuickCommandsTray(List<String> suggestions) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'QUICK COMMANDS',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Auto-Triage Active',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.pastelSkyText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: suggestions.map((sug) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      _textController.text = sug;
                      _handleSend();
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.code_rounded, size: 13, color: AppColors.pastelMintText),
                          const SizedBox(width: 4),
                          Text(
                            '+ $sug',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pastelMintText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. MISSION PRIORITY SELECTOR ---
  Widget _buildPrioritySelector(ThemeProvider theme) {
    return Container(
      color: theme.cardBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Text(
            'PRIORITY:',
            style: TextStyle(
              fontSize: 9.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPriorityBtn('LOW', theme),
                  const SizedBox(width: 4),
                  _buildPriorityBtn('MEDIUM', theme),
                  const SizedBox(width: 4),
                  _buildPriorityBtn('HIGH', theme),
                  const SizedBox(width: 4),
                  _buildPriorityBtn('CRITICAL', theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBtn(String prio, ThemeProvider theme) {
    final isSelected = _selectedPriority == prio;
    final isCrit = prio == 'CRITICAL';
    return InkWell(
      onTap: () => setState(() => _selectedPriority = prio),
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCrit ? AppColors.rejectionRed : theme.primaryButtonColor)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          prio == 'CRITICAL' ? 'CRIT' : prio,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            color: isSelected
                ? Colors.white
                : (isCrit ? AppColors.rejectionRed : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // --- 6. FLOATING CAPSULE COMMAND INPUT BAR ---
  Widget _buildFloatingInputCapsule(AgentModel currentAgent, ThemeProvider theme) {
    return Container(
      color: theme.cardBg,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: SafeArea(
        top: false,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: theme.canvasBg,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: theme.terminalBorder, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Target Mode Chip
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.terminal_rounded, size: 18, color: theme.primaryButtonColor),
              ),
              const SizedBox(width: 8),

              // Input field
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(fontSize: 13, color: AppColors.carbon),
                  decoration: const InputDecoration(
                    hintText: 'Kirim instruksi kode atau CLI command...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),

              // Mic Trigger
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.mic_none_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: () {},
              ),

              // Send button (Theme capsule)
              InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryButtonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryButtonColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_upward_rounded, size: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(AgentModel agent, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: theme.terminalBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: theme.primaryButtonColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '${agent.name} sedang mengeksekusi...',
                  style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AgentModel agent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.pastelMint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.terminal_rounded, size: 28, color: AppColors.pastelMintText),
            ),
            const SizedBox(height: 12),
            Text(
              'Console Aktif: ${agent.name}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.carbon),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kirim perintah langsung ke node agen ini untuk eksekusi real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgentSelector(BuildContext context, List<AgentModel> agents) {
    final theme = context.read<ThemeProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: theme.cardBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Pilih Target Agen Swarm',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.textPrimary),
              ),
            ),
            Divider(height: 1, color: theme.terminalBorder),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: agents.length,
                itemBuilder: (context, index) {
                  final a = agents[index];
                  final isSelected = a.id == _currentAgentId;
                  return ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryButtonColor : AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      a.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? theme.primaryButtonColor : theme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${a.id} • ${a.model}',
                      style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.textSecondary),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.approvalGreen, size: 18)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _currentAgentId = a.id);
                      final chatProvider = Provider.of<ChatTaskProvider>(context, listen: false);
                      chatProvider.fetchSessionsForAgent(a.id);
                      chatProvider.loadLatestSession(a.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
