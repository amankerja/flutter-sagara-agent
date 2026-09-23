import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/agent_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/perforated_ticket_card.dart';
import '../../widgets/create_task_sheet.dart';
import '../chat/agent_chat_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final Set<String> _expandedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final agentProvider = context.watch<AgentProvider>();
    final theme = context.watch<ThemeProvider>();
    final tasks = taskProvider.tasks;

    return Scaffold(
      backgroundColor: theme.canvasBg,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60), // Above the floating navigation dock
        child: FloatingActionButton.extended(
          heroTag: 'tasks_fab_dispatch',
          backgroundColor: theme.primaryButtonColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CreateTaskSheet(
                agents: agentProvider.rawAgents,
                onSubmit: (title, desc, agentId, priority) {
                  taskProvider.createTask(
                    title: title,
                    description: desc,
                    agentId: agentId,
                    priority: priority,
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Dispatch Task', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ),
      body: RefreshIndicator(
        color: theme.primaryButtonColor,
        onRefresh: () => taskProvider.fetchTasks(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            // 1. Lead Orchestrator Sub-Task Delegation Hero Banner
            _buildOrchestratorHero(context),
            const SizedBox(height: 14),

            // 2. Swarm Route Pipeline Flow Strip
            _buildPipelineFlowStrip(taskProvider),
            const SizedBox(height: 14),

            // 3. Segmented Filter Pills
            _buildFilterPills(taskProvider, theme),
            const SizedBox(height: 16),

            // 4. Task Tickets List
            if (tasks.isEmpty)
              _buildEmptyState()
            else
              ...tasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildTaskTicket(context, task, taskProvider, theme),
                  )),
          ],
        ),
      ),
    );
  }

  // --- 1. ORCHESTRATOR HERO BANNER ---
  Widget _buildOrchestratorHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(109, 40, 217, 0.04),
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
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_tree_rounded, size: 20, color: AppColors.pastelLavenderText),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Lead Orchestrator',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.carbon,
                              letterSpacing: -0.01,
                            ),
                          ),
                          Text(
                            'Autonomous Sub-Task Routing',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.approvalGreen),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'ACTIVE',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: AppColors.pastelMintText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Lead Agent secara otonom mendekomposisi instruksi kompleks ke worker agen spesialis (Infra, Coder, Support, Growth).',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
          ),
        ],
      ),
    );
  }

  // --- 2. PIPELINE FLOW STRIP ---
  Widget _buildPipelineFlowStrip(TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStageNode('READY', '${provider.readyCount}', AppColors.pastelSkyText),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.borderDashed),
          _buildStageNode('ACTIVE', '${provider.runningCount}', AppColors.approvalGreen),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.borderDashed),
          _buildStageNode('HOLD', '${provider.awaitingApprovalCount}', AppColors.rejectionRed),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.borderDashed),
          _buildStageNode('DONE', '${provider.completedCount}', AppColors.pastelLavenderText),
        ],
      ),
    );
  }

  Widget _buildStageNode(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // --- 3. FILTER PILLS ---
  Widget _buildFilterPills(TaskProvider taskProvider, ThemeProvider theme) {
    final filters = ['ALL', 'RUNNING', 'READY', 'AWAITING_APPROVAL', 'COMPLETED', 'FAILED'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((s) {
          final isSelected = taskProvider.filterState == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => taskProvider.setFilter(s),
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
                  s.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 4. TASK TICKET (PERFORATED CARD) ---
  Widget _buildTaskTicket(
    BuildContext context,
    TaskModel task,
    TaskProvider provider,
    ThemeProvider theme,
  ) {
    Color headerBg = AppColors.pastelSky;
    Color headerText = AppColors.pastelSkyText;
    IconData taskIcon = Icons.assignment_outlined;

    if (task.priority == 'CRITICAL') {
      headerBg = AppColors.pastelPeach;
      headerText = AppColors.pastelPeachText;
      taskIcon = Icons.crisis_alert_rounded;
    } else if (task.priority == 'HIGH') {
      headerBg = AppColors.pastelLavender;
      headerText = AppColors.pastelLavenderText;
      taskIcon = Icons.bolt_rounded;
    } else if (task.isCompleted) {
      headerBg = AppColors.pastelMint;
      headerText = AppColors.pastelMintText;
      taskIcon = Icons.task_alt_rounded;
    }

    final isExpanded = _expandedTaskIds.contains(task.id);

    return PerforatedTicketCard(
      headerColor: headerBg,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 9,
      borderRadius: 18,
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedTaskIds.remove(task.id);
          } else {
            _expandedTaskIds.add(task.id);
          }
        });
      },
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: headerText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${task.id.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: headerText,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: task.isRunning ? AppColors.pastelMint : Colors.white,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      if (task.isRunning) ...[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.approvalGreen),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        task.state.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: task.isRunning ? AppColors.pastelMintText : AppColors.carbon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: headerText),
                ),
              ],
            ),
          ],
        ),
      ),
      body: AnimatedCrossFade(
        duration: const Duration(milliseconds: 220),
        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(taskIcon, size: 14, color: headerText),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  task.title,
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
              const Text(
                'Ketuk detail',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        secondChild: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.carbon,
                        letterSpacing: -0.01,
                      ),
                    ),
                  ),
                  Icon(taskIcon, size: 18, color: headerText),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 10),

              // Assigned Agent Tag
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_rounded, size: 12, color: AppColors.carbon),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    task.agentName.isNotEmpty ? task.agentName : task.agentId,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.carbon),
                  ),
                ],
              ),

              // Delegation Trace Chain
              if (task.delegations.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SUB-TASK DELEGATIONS:',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.6),
                      ),
                      const SizedBox(height: 4),
                      ...task.delegations.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right_rounded, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${d.taskTitle} (${d.workerPid})',
                                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.carbon),
                                  ),
                                ),
                                Text(
                                  d.state,
                                  style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', fontWeight: FontWeight.w700, color: AppColors.pastelMintText),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final targetAgentId = task.agentId.trim().isNotEmpty ? task.agentId.trim() : 'lead';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgentChatScreen(initialAgentId: targetAgentId),
                        ),
                      );
                    },
                    icon: Icon(Icons.forum_outlined, size: 14, color: theme.primaryButtonColor),
                    label: Text(
                      'Chat Agen (${task.agentId.trim().isNotEmpty ? task.agentId : (task.agentName.trim().isNotEmpty ? task.agentName : "lead")})',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primaryButtonColor),
                    ),
                  ),
                  if (task.isRunning)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rejectionRed,
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      onPressed: () => provider.cancelTask(task.id),
                      child: const Text('Batalkan', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: const [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Tidak ada task pada kategori ini',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
