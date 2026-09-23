import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../providers/agent_provider.dart';
import '../providers/task_provider.dart';
import '../providers/approval_provider.dart';
import '../providers/schedule_provider.dart';
import '../screens/settings/appearance_settings_screen.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _urlController;
  late bool _isMock;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppStateProvider>();
    _urlController = TextEditingController(text: app.baseUrl);
    _isMock = app.isMockMode;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(
        children: const [
          Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
          SizedBox(width: 8),
          Text(
            'Konfigurasi Koneksi Sagara',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Switch
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mode Data Demo / Mock',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dataset lengkap bawaan dari GitHub origin/main',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isMock,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _isMock = val);
                      app.toggleMode(val);
                      context.read<AgentProvider>().fetchAgentsAndProfiles();
                      context.read<TaskProvider>().fetchTasks();
                      context.read<ApprovalProvider>().fetchApprovals();
                      context.read<ScheduleProvider>().fetchSchedules();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Server URL
            const Text(
              'Alamat URL Backend VPS / Gateway:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              enabled: !_isMock,
              decoration: const InputDecoration(
                hintText: 'https://office.alkaralintas.site',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preset: https://office.alkaralintas.site atau http://10.0.2.2:8000 (Android Emulator)',
              style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),

            // Diagnostic Status
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hermes Gateway:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        app.gatewayStatus?.status ?? 'UNKNOWN',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.statusActiveText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Latensi:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        '${app.gatewayStatus?.latencyMs ?? 0} ms',
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('WebSocket Stream:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(color: AppColors.statusActiveText, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            app.isMockMode ? 'MOCK PULSE' : 'CONNECTED',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.statusActiveText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Button to Open Color & Terminal Theme Settings
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBlue,
                  side: const BorderSide(color: Color(0xFF93C5FD)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen()),
                  );
                },
                icon: const Icon(Icons.palette_outlined, size: 18),
                label: const Text(
                  'Kustomisasi Warna Button & Terminal',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Button to Test Sound & Vibration Notification
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusDangerText,
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () async {
                  await app.testAudibleHighRiskAlert();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔔 Alarm suara & notifikasi berisiko tinggi berhasil dipicu!'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.volume_up_rounded, size: 18),
                label: const Text(
                  'Uji Coba Suara & Notifikasi Alert',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            app.updateBaseUrl(_urlController.text);
            context.read<AgentProvider>().fetchAgentsAndProfiles();
            context.read<TaskProvider>().fetchTasks();
            context.read<ApprovalProvider>().fetchApprovals();
            context.read<ScheduleProvider>().fetchSchedules();
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
