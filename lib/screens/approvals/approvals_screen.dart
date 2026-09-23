import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/approval_model.dart';
import '../../providers/approval_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/perforated_ticket_card.dart';
import '../../widgets/approval_detail_sheet.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  String _selectedFilter = 'PENDING'; // PENDING, APPROVED, REJECTED, ALL

  @override
  Widget build(BuildContext context) {
    final approvalProvider = context.watch<ApprovalProvider>();
    final theme = context.watch<ThemeProvider>();
    final app = context.watch<AppStateProvider>();
    final allApprovals = approvalProvider.approvals;

    final pendingList = allApprovals.where((a) => a.state == 'PENDING').toList();
    final approvedList = allApprovals.where((a) => a.state == 'APPROVED').toList();
    final rejectedList = allApprovals.where((a) => a.state == 'REJECTED').toList();

    List<ApprovalModel> filtered;
    switch (_selectedFilter) {
      case 'PENDING':
        filtered = pendingList;
        break;
      case 'APPROVED':
        filtered = approvedList;
        break;
      case 'REJECTED':
        filtered = rejectedList;
        break;
      case 'ALL':
      default:
        filtered = allApprovals;
        break;
    }

    return RefreshIndicator(
      color: theme.primaryButtonColor,
      onRefresh: () => approvalProvider.fetchApprovals(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), // Spacing for floating dock
        children: [
          // 1. Top Telemetry & Status Strip (HITL Gate & Telegram status)
          _buildTopStatusStrip(approvalProvider.pendingCount, app, theme),
          const SizedBox(height: 12),

          // 2. Quick Mode / Filter Pills (Travel Booking Style)
          _buildFilterPills(
            pendingCount: pendingList.length,
            approvedCount: approvedList.length,
            rejectedCount: rejectedList.length,
            totalCount: allApprovals.length,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // 3. Ticket Stream
          if (filtered.isEmpty)
            _buildEmptyState()
          else
            ...filtered.map((approval) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTicketCard(context, approval, approvalProvider, theme),
                )),

          // 4. Bulk Action Button: "Setujui Semua (N)"
          if (pendingList.isNotEmpty && _selectedFilter == 'PENDING') ...[
            const SizedBox(height: 8),
            _buildBulkApproveButton(context, pendingList, approvalProvider, theme),
          ],
        ],
      ),
    );
  }

  // --- 1. TOP TELEMETRY STRIP ---
  Widget _buildTopStatusStrip(int pendingCount, AppStateProvider app, ThemeProvider theme) {
    final latencyMs = app.gatewayStatus?.latencyMs ?? 0;
    final latencyText = latencyMs > 0 ? '$latencyMs ms' : '--';
    final syncLabel = app.gatewayStatus?.connected == true
        ? 'Telegram Bot Sync • $latencyText'
        : 'Connecting to VPS...';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.terminalBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.02),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.pastelMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync_rounded,
                    size: 20,
                    color: AppColors.pastelMintText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'HITL Gate',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.carbon,
                                letterSpacing: -0.01,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.approvalGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        syncLabel,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.pastelPeach,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, size: 13, color: AppColors.pastelPeachText),
                const SizedBox(width: 4),
                Text(
                  '$pendingCount PENDING',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: AppColors.pastelPeachText,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. FILTER PILLS ---
  Widget _buildFilterPills({
    required int pendingCount,
    required int approvedCount,
    required int rejectedCount,
    required int totalCount,
    required ThemeProvider theme,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPillItem(
            label: 'Pending',
            badge: '$pendingCount',
            filterKey: 'PENDING',
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            label: 'Approved ($approvedCount)',
            filterKey: 'APPROVED',
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            label: 'Rejected ($rejectedCount)',
            filterKey: 'REJECTED',
            theme: theme,
          ),
          const SizedBox(width: 8),
          _buildPillItem(
            label: 'Semua ($totalCount)',
            filterKey: 'ALL',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildPillItem({
    required String label,
    String? badge,
    required String filterKey,
    required ThemeProvider theme,
  }) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: isSelected ? theme.primaryButtonColor : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 3. TICKET CARD ---
  Widget _buildTicketCard(
    BuildContext context,
    ApprovalModel a,
    ApprovalProvider provider,
    ThemeProvider theme,
  ) {
    final isProcessing = provider.processingApprovalId == a.id;

    // Tint theme based on risk/type
    Color headerBg = AppColors.pastelLavender;
    Color headerText = AppColors.pastelLavenderText;
    String badgeCategory = 'MEDIUM • ROUTINE';
    IconData typeIcon = Icons.rule_rounded;

    if (a.isCritical) {
      headerBg = AppColors.pastelLavender;
      headerText = AppColors.pastelLavenderText;
      badgeCategory = 'CRITICAL • INFRA';
      typeIcon = Icons.router_rounded;
    } else if (a.isHigh) {
      headerBg = AppColors.pastelMint;
      headerText = AppColors.pastelMintText;
      badgeCategory = 'HIGH • DATABASE';
      typeIcon = Icons.storage_rounded;
    } else {
      headerBg = AppColors.pastelSky;
      headerText = AppColors.pastelSkyText;
      badgeCategory = 'DISPATCH • AGENT';
      typeIcon = Icons.campaign_rounded;
    }

    final targetScript = a.targetScript.isNotEmpty
        ? a.targetScript
        : 'systemctl restart hermes-agent-${a.agentId}.service --force';

    return PerforatedTicketCard(
      headerColor: headerBg,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 10,
      borderRadius: 20,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ApprovalDetailSheet(approval: a),
        );
      },
      header: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Pill, ID, Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: a.isCritical
                            ? AppColors.rejectionRedSubtle
                            : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        badgeCategory,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: a.isCritical ? AppColors.rejectionRed : headerText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#APPR-${a.id.substring(0, a.id.length > 5 ? 5 : a.id.length).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        color: headerText,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: headerText),
                    const SizedBox(width: 4),
                    Text(
                      a.requestedAt.contains(' ')
                          ? '${a.requestedAt.split(' ').last.substring(0, 5)} WIB'
                          : '09:42 WIB',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: headerText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Title, Subtitle, and Type Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.carbon,
                          letterSpacing: -0.01,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${a.agentName} • ${a.environment}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
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
                  child: Icon(typeIcon, size: 20, color: headerText),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monospace code drawer
            Container(
              padding: const EdgeInsets.all(12),
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
                      Text(
                        a.actionType.contains('SQL') ? 'SQL QUERY' : 'TARGET SCRIPT',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: theme.terminalHeaderColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: targetScript));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perintah disalin ke clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.content_copy_rounded,
                          size: 14,
                          color: theme.terminalHeaderColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    targetScript,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.terminalText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // SLA & Risk chips
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.timer_outlined, size: 12, color: AppColors.pastelMintText),
                      SizedBox(width: 4),
                      Text(
                        '< 400ms SLA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pastelMintText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.history_rounded, size: 12, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'Auto-Rollback',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Risk: ${a.isCritical ? "82%" : (a.isHigh ? "41%" : "9%")}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Action Buttons
            if (a.isPending) ...[
              if (isProcessing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    // Tolak (Reject)
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.rejectionRedSubtle,
                          foregroundColor: AppColors.rejectionRed,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        ),
                        onPressed: () => _confirmAction(context, a, provider, isApprove: false),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Setujui (Approve)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          shadowColor: theme.primaryButtonColor.withValues(alpha: 0.3),
                          elevation: 3,
                        ),
                        onPressed: () => _confirmAction(context, a, provider, isApprove: true),
                        icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                        label: const Text('Setujui', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: a.isApproved ? AppColors.pastelMint : AppColors.rejectionRedSubtle,
                  borderRadius: BorderRadius.circular(9999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      a.isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 15,
                      color: a.isApproved ? AppColors.approvalGreen : AppColors.rejectionRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      a.isApproved ? 'DISETUJUI OLEH SUPERVISOR' : 'DITOLAK OLEH OPERATOR',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: a.isApproved ? AppColors.approvalGreen : AppColors.rejectionRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 4. BULK APPROVE BUTTON ---
  Widget _buildBulkApproveButton(
    BuildContext context,
    List<ApprovalModel> pendingList,
    ApprovalProvider provider,
    ThemeProvider theme,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryButtonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          shadowColor: theme.primaryButtonColor.withValues(alpha: 0.3),
          elevation: 4,
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Setujui Semua Persetujuan?'),
              content: Text(
                'Anda akan menyetujui ${pendingList.length} aksi secara batch sekaligus. Seluruh agen akan melanjutkan eksekusi.',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primaryButtonColor),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Ya, Setujui Semua'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            for (final a in pendingList) {
              await provider.approveAction(a.id, reason: 'Batch 1-Tap Approval');
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: theme.primaryButtonColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text('Berhasil menyetujui ${pendingList.length} tiket persetujuan.'),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.verified_rounded, size: 18, color: Colors.white),
        label: Text(
          'Setujui Semua (${pendingList.length})',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.pastelMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, size: 32, color: AppColors.approvalGreen),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gerbang Bersih & Aman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.carbon),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tidak ada tiket tertahan pada filter ini.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    ApprovalModel a,
    ApprovalProvider provider, {
    required bool isApprove,
  }) {
    final theme = context.read<ThemeProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isApprove ? AppColors.approvalGreen : AppColors.rejectionRed,
            ),
            const SizedBox(width: 8),
            Text(isApprove ? 'Setujui Eksekusi?' : 'Tolak Eksekusi?'),
          ],
        ),
        content: Text(
          isApprove
              ? 'Tindakan "${a.title}" akan segera dijalankan oleh agen ${a.agentName} di server ${a.environment}.'
              : 'Tindakan "${a.title}" akan dibatalkan. Agen akan mencari jalur mitigasi alternatif.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? theme.primaryButtonColor : AppColors.rejectionRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (isApprove) {
                await provider.approveAction(a.id, reason: 'Approved by Operator');
              } else {
                await provider.rejectAction(a.id, reason: 'Rejected by Operator');
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: isApprove ? theme.primaryButtonColor : AppColors.rejectionRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(isApprove ? 'Tiket disetujui & dieksekusi.' : 'Tiket ditolak.'),
                  ),
                );
              }
            },
            child: Text(isApprove ? 'Konfirmasi Setujui' : 'Tolak Tindakan'),
          ),
        ],
      ),
    );
  }
}
