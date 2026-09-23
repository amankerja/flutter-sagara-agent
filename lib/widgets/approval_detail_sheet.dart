import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../data/models/approval_model.dart';
import '../providers/approval_provider.dart';
import '../providers/theme_provider.dart';
import 'status_pill.dart';

class ApprovalDetailSheet extends StatefulWidget {
  final ApprovalModel approval;
  final Function(String approvalId, String? reason)? onApprove;
  final Function(String approvalId, String reason)? onReject;

  const ApprovalDetailSheet({
    super.key,
    required this.approval,
    this.onApprove,
    this.onReject,
  });

  @override
  State<ApprovalDetailSheet> createState() => _ApprovalDetailSheetState();
}

class _ApprovalDetailSheetState extends State<ApprovalDetailSheet> {
  final _rejectReasonController = TextEditingController();
  bool _showRejectInput = false;

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.approval;
    final theme = context.watch<ThemeProvider>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#APPR-${a.id.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            color: AppColors.pastelLavenderText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(text: a.risk, statusType: a.risk),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.carbon,
                        letterSpacing: -0.01,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Expanded(
            child: ListView(
              children: [
                // Info Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildRow('Target Agen:', '${a.agentName} (${a.agentId})'),
                      _buildRow('Tipe Aksi:', a.actionType),
                      _buildRow('Node/Target:', a.environment),
                      _buildRow('Waktu Minta:', a.requestedAt),
                      if (a.resolvedAt != null) _buildRow('Diselesaikan:', a.resolvedAt!),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Description
                const Text(
                  'JUSTIFIKASI & DAMPAK SISTEM:',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  a.description,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.carbon, height: 1.4),
                ),
                const SizedBox(height: 14),

                // Code Payload
                if (a.targetScript.isNotEmpty || a.payload.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RAW PAYLOAD / SCRIPT:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary),
                      ),
                      InkWell(
                        onTap: () {
                          final script = a.targetScript.isNotEmpty ? a.targetScript : a.payload;
                          Clipboard.setData(ClipboardData(text: script));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payload disalin ke clipboard')),
                          );
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.content_copy_rounded, size: 12, color: AppColors.brandBlue),
                            SizedBox(width: 4),
                            Text('Salin', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.brandBlue)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.terminalBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.terminalBorder, width: 1),
                    ),
                    child: Text(
                      a.targetScript.isNotEmpty ? a.targetScript : a.payload,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: theme.terminalText,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Reject input box if active
                if (_showRejectInput) ...[
                  TextField(
                    controller: _rejectReasonController,
                    decoration: InputDecoration(
                      labelText: 'Alasan Penolakan',
                      hintText: 'Tuliskan alasan penolakan untuk audit log...',
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          if (a.isPending) ...[
            if (!_showRejectInput)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.rejectionRedSubtle,
                        foregroundColor: AppColors.rejectionRed,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      onPressed: () => setState(() => _showRejectInput = true),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        shadowColor: theme.primaryButtonColor.withValues(alpha: 0.3),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onApprove != null) {
                          widget.onApprove!(a.id, null);
                        } else {
                          Provider.of<ApprovalProvider>(context, listen: false)
                              .approveAction(a.id, reason: 'Approved by modal');
                        }
                      },
                      icon: const Icon(Icons.bolt_rounded, size: 17, color: Colors.white),
                      label: const Text('Setujui Eksekusi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      onPressed: () => setState(() => _showRejectInput = false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rejectionRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      onPressed: () {
                        final reason = _rejectReasonController.text.trim();
                        Navigator.pop(context);
                        if (widget.onReject != null) {
                          widget.onReject!(a.id, reason.isNotEmpty ? reason : 'Rejected by mobile operator');
                        } else {
                          Provider.of<ApprovalProvider>(context, listen: false).rejectAction(
                              a.id,
                              reason: reason.isNotEmpty ? reason : 'Rejected by operator');
                        }
                      },
                      child: const Text('Konfirmasi Tolak', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
          ] else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Aksi ini telah ${a.state}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.carbon)),
        ],
      ),
    );
  }
}
