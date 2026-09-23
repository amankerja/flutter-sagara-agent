import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../data/models/agent_model.dart';
import '../providers/theme_provider.dart';

class CreateTaskSheet extends StatefulWidget {
  final List<AgentModel> agents;
  final String? initialAgentId;
  final Function(String title, String description, String agentId, String priority) onSubmit;

  const CreateTaskSheet({
    super.key,
    required this.agents,
    this.initialAgentId,
    required this.onSubmit,
  });

  @override
  State<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<CreateTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late String _selectedAgentId;
  String _selectedPriority = 'MEDIUM';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAgentId = (widget.initialAgentId != null && widget.initialAgentId!.trim().isNotEmpty)
        ? widget.initialAgentId!.trim()
        : (widget.agents.isNotEmpty ? widget.agents.first.id : 'lead');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);
    widget.onSubmit(title, desc, _selectedAgentId, _selectedPriority);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            const Text(
              'Beri Perintah / Dispatch Task Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.carbon, letterSpacing: -0.01),
            ),
            const SizedBox(height: 14),

            // Select Agent
            const Text('TARGET AGEN SWARM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAgentId,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.carbon),
                  items: widget.agents.map((agent) {
                    return DropdownMenuItem<String>(
                      value: agent.id,
                      child: Text('${agent.name} (${agent.role})', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.carbon)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAgentId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Priority
            const Text('TINGKAT PRIORITAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map((p) {
                final isSelected = _selectedPriority == p;
                final isCrit = p == 'CRITICAL';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPriority = p),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isCrit ? AppColors.rejectionRed : theme.primaryButtonColor)
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          p == 'CRITICAL' ? 'CRIT' : p,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Title
            const Text('JUDUL TUGAS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Misal: Analisis log error pada secondary gateway',
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderDefault)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderDefault)),
              ),
            ),
            const SizedBox(height: 14),

            // Description / Instructions
            const Text('INSTRUKSI DETAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tuliskan perintah spesifik atau batasan yang harus dipatuhi agen...',
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderDefault)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.borderDefault)),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryButtonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  shadowColor: theme.primaryButtonColor.withValues(alpha: 0.3),
                  elevation: 3,
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Kirim Tugas Sekarang', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
