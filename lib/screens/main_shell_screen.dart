import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../providers/approval_provider.dart';
import '../widgets/settings_dialog.dart';
import 'command/command_center_screen.dart';
import 'approvals/approvals_screen.dart';
import 'office_2d/office_2d_screen.dart';
import 'tasks/tasks_screen.dart';
import 'schedule/schedule_screen.dart';
import 'chat/agent_chat_screen.dart';
import '../providers/theme_provider.dart';
import 'settings/appearance_settings_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  static const List<String> _tabSubtitles = [
    'Mission Overview',
    'Pending Approvals',
    'Agent Armada',
    'Swarm Tasks',
    'Mission Schedule',
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();
    final approvalProvider = context.watch<ApprovalProvider>();
    final theme = context.watch<ThemeProvider>();
    final currentIndex = app.selectedTabIndex;

    final screens = const [
      CommandCenterScreen(),
      ApprovalsScreen(),
      Office2DScreen(),
      TasksScreen(),
      ScheduleScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.canvasBg,
      drawer: _buildAppDrawer(context, app, approvalProvider, theme),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.02),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Drawer Hamburger / Logo Icon
                  Builder(
                    builder: (innerContext) => InkWell(
                      onTap: () => Scaffold.of(innerContext).openDrawer(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 20,
                          color: AppColors.pastelMintText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Title & Live Node Telemetry
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Sagara AI',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.02,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: app.isMockMode ? AppColors.pastelSky : AppColors.pastelMint,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: app.isMockMode ? AppColors.pastelSkyText : AppColors.approvalGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    app.isMockMode ? 'MOCK • SG-01' : 'LIVE • SG-01',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      color: app.isMockMode ? AppColors.pastelSkyText : AppColors.pastelMintText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _tabSubtitles[currentIndex],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  // 1. Direct Chat Console Trigger
                  IconButton(
                    tooltip: 'Console Chat Agen',
                    icon: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        size: 18,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AgentChatScreen(initialAgentId: 'lead'),
                        ),
                      );
                    },
                  ),

                  // 2. Notifications Bell with Badge
                  IconButton(
                    tooltip: 'Notifikasi',
                    icon: Stack(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 19,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (approvalProvider.pendingCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.rejectionRed,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${approvalProvider.pendingCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => app.setTabIndex(1), // Go to approvals
                  ),

                  // 3. Theme & Appearance Customizer Trigger
                  IconButton(
                    tooltip: 'Kustomisasi Warna & Tema',
                    icon: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.primaryButtonColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        size: 18,
                        color: theme.primaryButtonColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppearanceSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  // 4. VPS Settings Node
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const SettingsDialog(),
                      );
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.primaryButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Screen Content
          Column(
            children: [
              // Global Freeze Warning Banner if Kill-Switch Active
              if (app.isKillSwitchActive)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  color: AppColors.rejectionRedSubtle,
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: AppColors.rejectionRed, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'SAFETY KILL-SWITCH AKTIF: Seluruh aksi & eksekusi agen dibekukan.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.rejectionRed),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _confirmKillSwitch(context, app, theme),
                        child: const Text('Buka', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.rejectionRed)),
                      ),
                    ],
                  ),
                ),

              // Urgent High-Risk Approval Alert Banner
              if (app.latestHighRiskAlert != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.pastelPeach,
                    border: Border(bottom: BorderSide(color: Color(0xFFFED7AA))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.pastelPeachText, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HITL CLEARANCE: ${app.latestHighRiskAlert!.title}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.pastelPeachText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Agen ${app.latestHighRiskAlert!.agentName} butuh otorisasi.',
                              style: const TextStyle(fontSize: 10, color: AppColors.carbon),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryButtonColor,
                          foregroundColor: theme.onPrimaryButtonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          app.setTabIndex(1); // Jump to Approvals
                          app.dismissHighRiskAlert();
                        },
                        child: const Text('Review', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 15, color: AppColors.textSecondary),
                        onPressed: () => app.dismissHighRiskAlert(),
                      ),
                    ],
                  ),
                ),

              // Active Screen (Add bottom padding for the floating navigation dock)
              Expanded(
                child: IndexedStack(
                  index: currentIndex,
                  children: screens,
                ),
              ),
            ],
          ),

          // Floating Navigation Dock (Serene Transit Level 3 Dock)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.dockBg.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: theme.borderSubtle, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: theme.isDarkMode ? Colors.black26 : const Color.fromRGBO(15, 23, 42, 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDockItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Overview',
                        isSelected: currentIndex == 0,
                        selectedPillColor: theme.dockSelectedPill,
                        onTap: () => app.setTabIndex(0),
                      ),
                      _buildDockItem(
                        icon: Icons.verified_user_rounded,
                        label: 'Approvals',
                        badgeCount: approvalProvider.pendingCount,
                        isSelected: currentIndex == 1,
                        selectedPillColor: theme.dockSelectedPill,
                        onTap: () => app.setTabIndex(1),
                      ),
                      _buildDockItem(
                        icon: Icons.smart_toy_rounded,
                        label: 'Armada',
                        isSelected: currentIndex == 2,
                        selectedPillColor: theme.dockSelectedPill,
                        onTap: () => app.setTabIndex(2),
                      ),
                      _buildDockItem(
                        icon: Icons.assignment_turned_in_rounded,
                        label: 'Tasks',
                        isSelected: currentIndex == 3,
                        selectedPillColor: theme.dockSelectedPill,
                        onTap: () => app.setTabIndex(3),
                      ),
                      _buildDockItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Schedule',
                        isSelected: currentIndex == 4,
                        selectedPillColor: theme.dockSelectedPill,
                        onTap: () => app.setTabIndex(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockItem({
    required IconData icon,
    required String label,
    int? badgeCount,
    required bool isSelected,
    required Color selectedPillColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? selectedPillColor : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedPillColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            if (badgeCount != null && badgeCount > 0 && !isSelected)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.rejectionRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    '$badgeCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, AppStateProvider app, ApprovalProvider approvalProvider, ThemeProvider theme) {
    return Drawer(
      backgroundColor: theme.canvasBg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.hub_rounded, color: AppColors.pastelMintText, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'SAGARA AI',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.01),
                          ),
                          Text(
                            'Mission Control Mobile',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: app.isMockMode ? AppColors.pastelSky : AppColors.pastelMint,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      app.isMockMode ? 'MODE DEMO MOCK (DATASET)' : 'CONNECTED TO LIVE VPS (SG-01)',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: app.isMockMode ? AppColors.pastelSkyText : AppColors.pastelMintText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section: COMMAND
            _buildDrawerSectionHeader('MISSION COMMAND'),
            _buildDrawerItem(
              icon: Icons.grid_view_rounded,
              title: 'Command Center',
              isSelected: app.selectedTabIndex == 0,
              activeColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                app.setTabIndex(0);
              },
            ),
            _buildDrawerItem(
              icon: Icons.verified_user_rounded,
              title: 'Approvals Gate',
              badgeCount: approvalProvider.pendingCount,
              isSelected: app.selectedTabIndex == 1,
              activeColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                app.setTabIndex(1);
              },
            ),
            _buildDrawerItem(
              icon: Icons.assignment_turned_in_rounded,
              title: 'Tasks & Delegation Tree',
              isSelected: app.selectedTabIndex == 3,
              activeColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                app.setTabIndex(3);
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today_rounded,
              title: 'Schedule & Calendar View',
              isSelected: app.selectedTabIndex == 4,
              activeColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                app.setTabIndex(4);
              },
            ),

            // Section: AGENTS & PROFILES
            _buildDrawerSectionHeader('FLEET ARMADA & CHAT'),
            _buildDrawerItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat & Task Console',
              textColor: theme.primaryButtonColor,
              activeColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgentChatScreen(initialAgentId: 'lead'),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.smart_toy_rounded,
              title: 'Direktori Armada & SOUL (9)',
              isSelected: app.selectedTabIndex == 2,
              activeColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                app.setTabIndex(2);
              },
            ),

            // Section: SISTEM
            _buildDrawerSectionHeader('SISTEM & TAMPILAN'),
            _buildDrawerItem(
              icon: Icons.palette_outlined,
              title: 'Pengaturan Tampilan & Warna',
              textColor: theme.primaryButtonColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppearanceSettingsScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.tune_rounded,
              title: 'Konfigurasi VPS Node',
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => const SettingsDialog());
              },
            ),
            _buildDrawerItem(
              icon: app.isKillSwitchActive ? Icons.lock : Icons.shield_rounded,
              title: app.isKillSwitchActive ? 'Buka Freeze Darurat' : 'Emergency Kill-Switch (Freeze)',
              textColor: app.isKillSwitchActive ? AppColors.rejectionRed : null,
              onTap: () {
                Navigator.pop(context);
                _confirmKillSwitch(context, app, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    int? badgeCount,
    bool isSelected = false,
    Color? activeColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final highlight = activeColor ?? AppColors.brandBlue;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(icon, size: 20, color: isSelected ? highlight : AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: textColor ?? (isSelected ? highlight : AppColors.textPrimary),
        ),
      ),
      trailing: (badgeCount != null && badgeCount > 0)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.rejectionRed,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  void _confirmKillSwitch(BuildContext context, AppStateProvider app, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              app.isKillSwitchActive ? Icons.lock_open : Icons.warning_amber_rounded,
              color: AppColors.rejectionRed,
            ),
            const SizedBox(width: 8),
            Text(app.isKillSwitchActive ? 'Buka Freeze Darurat?' : 'Konfirmasi Kill-Switch'),
          ],
        ),
        content: Text(
          app.isKillSwitchActive
              ? 'Apakah Anda ingin menonaktifkan Kill-Switch dan melanjutkan aktivitas normal seluruh agen swarm?'
              : 'Perhatian: Mengaktifkan Kill-Switch akan SEGERA MEMBEKUKAN (FREEZE) seluruh eksekusi task dan koneksi alat agen otonom.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejectionRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              app.toggleKillSwitch();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: app.isKillSwitchActive ? AppColors.rejectionRed : theme.primaryButtonColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text(
                    app.isKillSwitchActive
                        ? 'Freeze darurat swarm aktif. Seluruh agen dibekukan.'
                        : 'Freeze darurat swarm dicabut. Operasi agen kembali nominal.',
                  ),
                ),
              );
            },
            child: Text(app.isKillSwitchActive ? 'Buka Freeze' : 'Aktifkan Freeze'),
          ),
        ],
      ),
    );
  }
}
