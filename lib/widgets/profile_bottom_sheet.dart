import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../data/models/agent_model.dart';
import '../data/models/profile_model.dart';
import '../providers/chat_task_provider.dart';
import '../screens/chat/agent_chat_screen.dart';
import 'status_pill.dart';

class ProfileBottomSheet extends StatelessWidget {
  final AgentModel agent;
  final ProfileModel? profile;
  final dynamic onDispatchTask;
  final dynamic onOpenChat;

  const ProfileBottomSheet({
    super.key,
    required this.agent,
    this.profile,
    this.onDispatchTask,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final title = profile?.operationalTitle.isNotEmpty == true
        ? profile!.operationalTitle
        : agent.role;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile?.name.isNotEmpty == true ? profile!.name : agent.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        StatusPill(text: agent.state, statusType: agent.state),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Profile ID: ${profile?.id ?? agent.profileId} • Model: ${agent.model}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sesi Chat & Task Terakhir Card
          Builder(
            builder: (ctx) {
              final chatProvider = Provider.of<ChatTaskProvider>(ctx);
              final latestSess = chatProvider.getLatestCachedSession(agent.id);
              final activeSessId = chatProvider.getActiveSessionId(agent.id) ?? latestSess?.id ?? 'sess-${agent.id}-latest';
              final lastMsg = chatProvider.getLastMessage(agent.id);
              final msgCount = chatProvider.getMessages(agent.id).length;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
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
                            Icon(Icons.history_rounded, size: 15, color: AppColors.primary),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'SESI TERAKHIR (ACTIVE RUNTIME)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statusActiveBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            latestSess?.state ?? 'ACTIVE',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.statusActiveText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          activeSessId,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• $msgCount pesan',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        if (latestSess != null && latestSess.costUsd > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• \$${latestSess.costUsd.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace'),
                          ),
                        ],
                      ],
                    ),
                    if (lastMsg != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              lastMsg.isUser ? Icons.person_outline : Icons.smart_toy_outlined,
                              size: 13,
                              color: lastMsg.isUser ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                lastMsg.text,
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AgentChatScreen(
                                    initialAgentId: agent.id,
                                    initialSessionId: activeSessId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                            label: const Text(
                              'Lanjutkan Sesi Terakhir',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: AppColors.borderDefault),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () {
                              chatProvider.startNewSession(agent.id);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AgentChatScreen(
                                    initialAgentId: agent.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 14, color: AppColors.textPrimary),
                            label: const Text(
                              'Sesi Baru',
                              style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Formulir Buat Tugas',
                          icon: const Icon(Icons.add_task_rounded, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            Navigator.pop(context);
                            if (onDispatchTask != null) {
                              try {
                                if (profile != null) {
                                  onDispatchTask(profile!);
                                } else {
                                  onDispatchTask();
                                }
                              } catch (_) {
                                onDispatchTask();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Scrollable Content
          Expanded(
            child: ListView(
              children: [
                // Current Activity
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AKTIVITAS TERKINI (CURRENT RUNTIME)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.currentActivity,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStat(
                        label: 'Active Sessions',
                        value: '${agent.sessionCount}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSmallStat(
                        label: 'Delegations',
                        value: '${agent.activeDelegations}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSmallStat(
                        label: 'Cost Est.',
                        value: '\$${agent.estimatedCostUsd.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Model Policy & Execution Governance
                if (profile != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GOVERNANCE & POLICY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildPolicyRow('Model Policy', profile!.modelPolicy),
                        const SizedBox(height: 4),
                        _buildPolicyRow('Permissions', profile!.permissionsPolicy),
                        const SizedBox(height: 4),
                        _buildPolicyRow('Memory Namespace', profile!.memoryNamespace),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Channel Routes
                if (profile != null && profile!.channelRoutes.isNotEmpty) ...[
                  const Text(
                    'ASSIGNED CHANNEL ROUTES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: profile!.channelRoutes.map((channel) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          '#$channel',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // Active Skills
                const Text(
                  'SKILL MATRIX & CAPABILITIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                if (agent.skills.isEmpty && (profile == null || profile!.skills.isEmpty))
                  const Text('Tidak ada skill terdaftar.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                else
                  ..._buildSkillWidgets(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSkillWidgets() {
    final List<Widget> list = [];
    final Set<String> renderedIds = {};

    for (final skill in agent.skills) {
      renderedIds.add(skill.name);
      list.add(
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              Icon(
                skill.health == 'HEALTHY' ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                size: 16,
                color: skill.health == 'HEALTHY' ? AppColors.statusActiveText : AppColors.statusWarningText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    if (skill.description.isNotEmpty)
                      Text(skill.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusPill(text: skill.health, statusType: skill.health),
            ],
          ),
        ),
      );
    }

    if (profile != null) {
      for (final skillName in profile!.skills) {
        if (!renderedIds.contains(skillName)) {
          renderedIds.add(skillName);
          list.add(
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      skillName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                  const StatusPill(text: 'CANONICAL', statusType: 'ACTIVE'),
                ],
              ),
            ),
          );
        }
      }
    }

    return list;
  }

  Widget _buildSmallStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
