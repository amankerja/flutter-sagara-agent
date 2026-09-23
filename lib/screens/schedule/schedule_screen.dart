import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/perforated_ticket_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _viewMode = 0; // 0 = Kalender Bulan (Month View), 1 = Daftar Agenda & Cron
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  String _formatMonthYear(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateStr(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatFullDateIndo(DateTime dt) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  bool _isScheduleOnDate(ScheduleModel s, DateTime date) {
    final dateStr = _formatDateStr(date);

    // 1. Exact string prefix match on startAt (e.g. "2026-09-23")
    if (s.startAt.startsWith(dateStr)) return true;

    // 2. Parse startDate to local timezone and strictly compare year, month, day
    try {
      final dt = DateTime.parse(s.startAt).toLocal();
      return dt.year == date.year && dt.month == date.month && dt.day == date.day;
    } catch (_) {
      return false;
    }
  }

  List<Map<String, dynamic>> _getApproachingCronItems(List<ScheduleModel> schedules) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> approaching = [];
    for (final s in schedules) {
      if (!s.isActive) continue;
      DateTime? dt;
      try {
        dt = DateTime.parse(s.startAt).toLocal();
      } catch (_) {}
      if (dt == null) continue;

      final diff = dt.difference(now);
      // Scheduled today, within the upcoming 6 hours or recently started within 15 minutes
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      if (isToday && diff.inMinutes >= -15 && diff.inHours <= 6) {
        approaching.add({
          'schedule': s,
          'dateTime': dt,
          'diff': diff,
          'isImminent': diff.inMinutes <= 45 && diff.inMinutes >= -5,
        });
      }
    }
    approaching.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
    return approaching;
  }

  Widget _buildApproachingCronNotificationBanner(
    List<Map<String, dynamic>> approaching,
    ScheduleProvider provider,
    ThemeProvider theme,
  ) {
    if (approaching.isEmpty) return const SizedBox.shrink();

    final imminentCount = approaching.where((item) => item['isImminent'] == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: imminentCount > 0 ? const Color(0xFFFDE68A) : AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: imminentCount > 0 ? const Color(0xFFFEF9C3) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                      color: imminentCount > 0 ? const Color(0xFF854D0E) : const Color(0xFF0369A1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PEMBERITAHUAN CRON MENDEKATI JADWAL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${approaching.length} cronjob terjadwal berjalan hari ini',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: imminentCount > 0 ? const Color(0xFFFEF9C3) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  imminentCount > 0 ? '$imminentCount Segera' : 'Terjadwal',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: imminentCount > 0 ? const Color(0xFF854D0E) : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // List of approaching items
          ...approaching.take(3).map((item) {
            final s = item['schedule'] as ScheduleModel;
            final dt = item['dateTime'] as DateTime;
            final diff = item['diff'] as Duration;
            final isImminent = item['isImminent'] as bool;
            final timeStr = s.startAt.length >= 16 && s.startAt.contains('T')
                ? s.startAt.substring(11, 16)
                : '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

            String countdownText;
            if (diff.inMinutes < 0) {
              countdownText = 'Sedang berjalan';
            } else if (diff.inMinutes == 0) {
              countdownText = 'Jadwal sekarang';
            } else if (diff.inMinutes < 60) {
              countdownText = 'Dalam ${diff.inMinutes}m';
            } else {
              final h = diff.inHours;
              final m = diff.inMinutes % 60;
              countdownText = 'Dalam ${h}j ${m > 0 ? '$m m' : ''}';
            }

            final isTriggering = provider.triggeringScheduleId == s.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isImminent ? const Color(0xFFFEFCE8) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isImminent ? const Color(0xFFFEF08A) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isImminent ? const Color(0xFFD97706) : const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '$timeStr WIB',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '•  $countdownText',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isImminent ? const Color(0xFFB45309) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '•  ${s.agentName.isNotEmpty ? s.agentName : s.agentId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 28,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: isTriggering
                          ? null
                          : () async {
                              final success = await provider.triggerScheduleNow(s.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Cron "${s.title}" berhasil dipicu ke server VPS!'
                                          : 'Gagal memicu cron.',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      child: isTriggering
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            )
                          : const Text(
                              'Picu',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Footer action: Test system notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengingat otomatis aktif saat < 60m',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
              ),
              InkWell(
                onTap: () async {
                  await provider.sendTestCronNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔔 Notifikasi uji cron terkirim ke status bar Android!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.notification_important_outlined, size: 13, color: Color(0xFF2563EB)),
                      SizedBox(width: 4),
                      Text(
                        'Uji Notifikasi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
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

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final theme = context.watch<ThemeProvider>();
    final schedules = scheduleProvider.schedules;
    final conflictItem = _detectConflict(schedules);
    final approachingCrons = _getApproachingCronItems(schedules);

    return Scaffold(
      backgroundColor: theme.canvasBg,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          heroTag: 'schedule_fab_add',
          backgroundColor: theme.primaryButtonColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          onPressed: () => _showAddScheduleSheet(context),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      ),
      body: RefreshIndicator(
        color: theme.primaryButtonColor,
        onRefresh: () => scheduleProvider.fetchSchedules(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            // 1. Top Schedule Engine Banner
            _buildScheduleEngineBanner(schedules.length),
            const SizedBox(height: 12),

            // Approaching Cron Notification Banner (if any)
            if (approachingCrons.isNotEmpty) ...[
              _buildApproachingCronNotificationBanner(approachingCrons, scheduleProvider, theme),
              const SizedBox(height: 12),
            ],

            // 2. Segmented View Toggle (Full Pill Capsule)
            _buildViewModeToggle(schedules.length, theme),
            const SizedBox(height: 14),

            // Conflict Warning Banner if detected
            if (conflictItem != null) ...[
              _buildConflictBanner(conflictItem),
              const SizedBox(height: 14),
            ],

            // Active View Mode Rendering
            if (_viewMode == 0) ...[
              _buildMonthCalendar(context, schedules, theme),
              const SizedBox(height: 16),
              _buildSelectedDateAgenda(context, schedules, scheduleProvider, theme),
            ] else ...[
              _buildFullAgendaList(context, schedules, scheduleProvider, theme),
            ],
          ],
        ),
      ),
    );
  }

  // --- 1. SCHEDULE ENGINE BANNER ---
  Widget _buildScheduleEngineBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.02),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.pastelMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.pastelMintText, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule Engine & Timeline',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.carbon,
                    letterSpacing: -0.01,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kalender operasional multi-agen: cron rutinitas & cron jobs ($count aktif).',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. VIEW MODE TOGGLE (FULL PILL) ---
  Widget _buildViewModeToggle(int count, ThemeProvider theme) {
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
                      ? [
                          BoxShadow(
                            color: theme.primaryButtonColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_view_month_rounded,
                      size: 16,
                      color: _viewMode == 0 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kalender Bulan',
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
                      ? [
                          BoxShadow(
                            color: theme.primaryButtonColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
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
                      color: _viewMode == 1 ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Agenda & Cron ($count)',
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

  // --- CONFLICT BANNER ---
  Widget _buildConflictBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pastelPeach,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.pastelPeachText, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conflict Advisory Alert',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.pastelPeachText),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(fontSize: 11, color: AppColors.carbon, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. MONTH CALENDAR GRID VIEW ---
  Widget _buildMonthCalendar(BuildContext context, List<ScheduleModel> schedules, ThemeProvider theme) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final startingOffset = firstDayOfMonth.weekday - 1;
    final totalSlots = ((startingOffset + daysInMonth + 6) ~/ 7) * 7;

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
        children: [
          // Navigation bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.carbon),
                onPressed: _prevMonth,
              ),
              InkWell(
                onTap: _goToday,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    _formatMonthYear(_currentMonth),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.carbon,
                      letterSpacing: -0.01,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.carbon),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Day of week headers
          Row(
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalSlots,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startingOffset + 1;
              final isCurrentMonth = dayNumber >= 1 && dayNumber <= daysInMonth;

              if (!isCurrentMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(year, month, dayNumber);
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              // Check if schedules exist on this date
              final hasEvents = schedules.any((s) => _isScheduleOnDate(s, date));

              return InkWell(
                onTap: () => setState(() => _selectedDate = date),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryButtonColor
                        : (isToday
                            ? theme.primaryButtonColor.withValues(alpha: 0.1)
                            : (hasEvents ? AppColors.surfaceContainerLow : Colors.transparent)),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : (isToday
                            ? Border.all(color: theme.primaryButtonColor, width: 1.5)
                            : (hasEvents ? Border.all(color: AppColors.borderDefault) : null)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? theme.primaryButtonColor : AppColors.carbon),
                        ),
                      ),
                      if (hasEvents)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : AppColors.approvalGreen,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 2. SELECTED DATE AGENDA ---
  Widget _buildSelectedDateAgenda(
    BuildContext context,
    List<ScheduleModel> schedules,
    ScheduleProvider provider,
    ThemeProvider theme,
  ) {
    final dateStr = _formatDateStr(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    final daySchedules = schedules.where((s) => _isScheduleOnDate(s, _selectedDate)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatFullDateIndo(_selectedDate).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.pastelMint,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Text(
                          'HARI INI',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.pastelMintText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (!isToday) ...[
                  InkWell(
                    onTap: _goToday,
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.today_rounded, size: 11, color: AppColors.carbon),
                          SizedBox(width: 3),
                          Text('Hari Ini', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.carbon)),
                        ],
                      ),
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: daySchedules.isEmpty ? AppColors.surfaceContainerLow : AppColors.pastelSky,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${daySchedules.length} Items',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: daySchedules.isEmpty ? AppColors.textSecondary : AppColors.pastelSkyText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (daySchedules.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.terminalBorder),
            ),
            alignment: Alignment.center,
            child: Text(
              'Tidak ada jadwal khusus pada $dateStr.',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          )
        else
          ...daySchedules.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBoardingPassTicket(context, item, provider, theme),
              )),
      ],
    );
  }

  // --- 3. FULL AGENDA & CRON LIST VIEW ---
  Widget _buildFullAgendaList(
    BuildContext context,
    List<ScheduleModel> schedules,
    ScheduleProvider provider,
    ThemeProvider theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SEMUA AGENDA RUTINITAS & CRON SWARM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.textSecondary,
              ),
            ),
            Text('${schedules.length} Total', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),

        if (schedules.isEmpty)
          const Center(child: Text('Tidak ada jadwal aktif'))
        else
          ...schedules.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBoardingPassTicket(context, item, provider, theme),
              )),
      ],
    );
  }

  // --- BOARDING PASS TICKET CARD ---
  Widget _buildBoardingPassTicket(
    BuildContext context,
    ScheduleModel s,
    ScheduleProvider provider,
    ThemeProvider theme,
  ) {
    String timeStr = '00:00';
    try {
      final dt = DateTime.parse(s.startAt).toLocal();
      timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      if (s.startAt.length >= 16 && s.startAt.contains('T')) {
        timeStr = s.startAt.substring(11, 16);
      }
    }
    final isCron = s.recurrenceFrequency != 'NONE';

    return PerforatedTicketCard(
      headerColor: isCron ? AppColors.pastelMint : AppColors.pastelSky,
      bodyColor: theme.cardBg,
      notchColor: theme.canvasBg,
      notchRadius: 9,
      borderRadius: 18,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: AppColors.carbon),
                      const SizedBox(width: 4),
                      Text(
                        '$timeStr WIB',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: AppColors.carbon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    s.recurrenceFrequency,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: isCron ? AppColors.pastelMintText : AppColors.pastelSkyText,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.isActive ? AppColors.approvalGreen : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  s.isActive ? 'ACTIVE' : 'OFF',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: s.isActive ? AppColors.approvalGreen : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.carbon,
                letterSpacing: -0.01,
              ),
            ),
            if (s.description.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                s.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
            const SizedBox(height: 12),

            // Trajectory Metaphor: AGENT ➔ [Trajectory] ➔ TARGET
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ORIGIN', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, letterSpacing: 0.6)),
                      Text(s.agentId.toUpperCase(), style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w800, color: AppColors.carbon)),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.borderDashed)),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.borderDashed,
                            ),
                          ),
                          const Icon(Icons.flight_takeoff_rounded, size: 14, color: AppColors.textSecondary),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.borderDashed,
                            ),
                          ),
                          Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.borderDashed)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('TARGET', style: TextStyle(fontSize: 9, color: AppColors.textSecondary, letterSpacing: 0.6)),
                      Text(s.type, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w800, color: AppColors.carbon)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Timing info and Run Now button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          (s.cronExpression != null && s.cronExpression!.isNotEmpty)
                              ? 'Cron: ${s.cronExpression}'
                              : 'One-shot task',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    shadowColor: theme.primaryButtonColor.withValues(alpha: 0.3),
                    elevation: 2,
                  ),
                  onPressed: () {
                    provider.triggerScheduleNow(s.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Jadwal "${s.title}" berhasil dipicu!')),
                    );
                  },
                  child: const Text('Jalankan Sekarang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _detectConflict(List<ScheduleModel> schedules) {
    for (int i = 0; i < schedules.length; i++) {
      for (int j = i + 1; j < schedules.length; j++) {
        final a = schedules[i];
        final b = schedules[j];
        if (a.agentId == b.agentId && a.startAt == b.startAt && a.isActive && b.isActive) {
          return 'Konflik waktu terdeteksi pada agen ${a.agentId}: "${a.title}" dan "${b.title}" pada jam yang sama (${a.startAt}).';
        }
      }
    }
    return null;
  }

  void _showAddScheduleSheet(BuildContext context) {
    // Standard bottom sheet to add schedule
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Tambah Agenda Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.carbon)),
            SizedBox(height: 8),
            Text('Silakan gunakan web console atau perintah chat di layar Console untuk menetapkan ekspresi cron otomatis.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
