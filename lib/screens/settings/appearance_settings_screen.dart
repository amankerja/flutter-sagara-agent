import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.canvasBg,
      appBar: AppBar(
        title: Text(
          'Pengaturan Tampilan & Warna',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              theme.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tema dikembalikan ke default (Sagara Blue & Light Editor)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textSecondary),
            label: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryButtonColor,
                foregroundColor: theme.onPrimaryButtonColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                theme.savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: theme.primaryButtonColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pengaturan tema berhasil disimpan & diterapkan!',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text(
                'Simpan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardBg,
          border: Border(top: BorderSide(color: theme.terminalBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: theme.isDarkMode ? Colors.black38 : const Color.fromRGBO(15, 23, 42, 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryButtonColor,
                foregroundColor: theme.onPrimaryButtonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                theme.savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: theme.primaryButtonColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pengaturan tema berhasil disimpan & diterapkan ke seluruh halaman!',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text(
                'SIMPAN & TERAPKAN TEMA',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // 1. LIVE PREVIEW CARD
          _buildLivePreview(theme),
          const SizedBox(height: 20),

          // 2. LIGHT / DARK MODE TOGGLE
          _buildModeToggle(theme),
          const SizedBox(height: 20),

          // 3. WARNA TOMBOL (PRIMARY BUTTON COLOR)
          _buildSectionHeader(
            title: 'WARNA TOMBOL & AKSI UTAMA',
            subtitle: 'Pilih warna untuk tombol aksi, floating buttons, dan dock terpilih.',
          ),
          const SizedBox(height: 10),
          _buildButtonColorSelector(theme),
          const SizedBox(height: 20),

          // 4. WARNA TERMINAL / KODE SCRIPT
          _buildSectionHeader(
            title: 'TEMA TERMINAL & KODE CLI',
            subtitle: 'Sesuaikan kontainer blok kode eksekusi skrip & log agen.',
          ),
          const SizedBox(height: 10),
          _buildTerminalThemeSelector(theme),
          const SizedBox(height: 20),

          // 5. GAYA KARTU & SURFACE
          _buildSectionHeader(
            title: 'GAYA KARTU (CARD SURFACE)',
            subtitle: 'Warna dasar kartu informasi, voucher boarding pass, dan panel.',
          ),
          const SizedBox(height: 10),
          _buildCardStyleSelector(theme),
          const SizedBox(height: 24),

          // 6. IN-BODY SAVE BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryButtonColor,
                foregroundColor: theme.onPrimaryButtonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                theme.savePreferences();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: theme.primaryButtonColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pengaturan tema berhasil disimpan & diterapkan ke seluruh halaman!',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text(
                'Simpan & Terapkan Perubahan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Perubahan otomatis langsung aktif di seluruh halaman & navigasi aplikasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: theme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // --- 1. LIVE PREVIEW CARD ---
  Widget _buildLivePreview(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderDefault, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryButtonColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE PREVIEW TAMPILAN',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: theme.primaryButtonColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? const Color(0xFF334155) : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  theme.isDarkMode ? 'DARK MODE' : 'LIGHT MODE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    color: theme.isDarkMode ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sample Card Text
          Text(
            'Simulasi Tampilan Elemen UI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Elemen tombol dan terminal akan langsung mengikuti konfigurasi yang Anda pilih di bawah.',
            style: TextStyle(fontSize: 12, color: theme.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 12),

          // Sample Terminal Preview
          Container(
            width: double.infinity,
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
                      'TERMINAL PREVIEW',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        color: theme.terminalHeaderColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Icon(Icons.terminal_rounded, size: 14, color: theme.terminalHeaderColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '> sagara-agent execute --target=node-sg01\n✓ Status: Nominal (Latency: 28ms)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: theme.terminalText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sample Button Preview
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryButtonColor,
                    foregroundColor: theme.onPrimaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                  label: const Text('Tombol Utama', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textPrimary,
                    side: BorderSide(color: theme.borderDefault),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  onPressed: () {},
                  child: const Text('Tombol Sekunder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. LIGHT / DARK MODE TOGGLE ---
  Widget _buildModeToggle(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderDefault, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? const Color(0xFF334155) : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  theme.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: theme.isDarkMode ? Colors.amber : const Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.isDarkMode ? 'Mode Gelap (Dark Mode)' : 'Mode Terang (Light Mode)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    theme.isDarkMode
                        ? 'Warna gelap nyaman untuk malam hari'
                        : 'Warna bersih tanpa hitam dominan',
                    style: TextStyle(fontSize: 11, color: theme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: theme.isDarkMode,
            activeThumbColor: theme.primaryButtonColor,
            onChanged: (val) => theme.toggleDarkMode(val),
          ),
        ],
      ),
    );
  }

  // --- 3. BUTTON COLOR SELECTOR ---
  Widget _buildButtonColorSelector(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderDefault, width: 1),
      ),
      child: Column(
        children: ThemeProvider.buttonColorPresets.map((preset) {
          final isSelected = theme.selectedButtonColor.id == preset.id;
          return InkWell(
            onTap: () => theme.setButtonColor(preset),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: preset.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? preset.color : theme.borderDefault,
                        width: isSelected ? 5 : 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 4. TERMINAL THEME SELECTOR ---
  Widget _buildTerminalThemeSelector(ThemeProvider theme) {
    return Column(
      children: ThemeProvider.terminalPresets.map((term) {
        final isSelected = theme.selectedTerminal.id == term.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => theme.setTerminalTheme(term),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? theme.primaryButtonColor : theme.borderDefault,
                  width: isSelected ? 2 : 1,
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
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            size: 18,
                            color: isSelected ? theme.primaryButtonColor : theme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            term.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (term.id == 'light_editor')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.pastelMint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TANPA HITAM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              color: AppColors.pastelMintText,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Snippet inside this terminal's colors
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: term.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: term.borderColor),
                    ),
                    child: Text(
                      'echo "Hermes swarm node ready" -> 200 OK',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.5,
                        color: term.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- 5. CARD STYLE SELECTOR ---
  Widget _buildCardStyleSelector(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderDefault, width: 1),
      ),
      child: Column(
        children: ThemeProvider.cardPresets.map((preset) {
          final isSelected = theme.selectedCardStyle.id == preset.id;
          return InkWell(
            onTap: () => theme.setCardStyle(preset),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: preset.surfaceColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: preset.borderColor, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        preset.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.primaryButtonColor : theme.borderDefault,
                        width: isSelected ? 5 : 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
