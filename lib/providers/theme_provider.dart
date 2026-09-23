import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';

/// Available primary button colors
class ThemeColorOption {
  final String id;
  final String name;
  final Color color;
  final Color onColor;

  const ThemeColorOption({
    required this.id,
    required this.name,
    required this.color,
    this.onColor = Colors.white,
  });
}

/// Available terminal theme options
class TerminalThemeOption {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color headerColor;
  final Color borderColor;

  const TerminalThemeOption({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.headerColor,
    required this.borderColor,
  });
}

/// Available card surface options
class CardStyleOption {
  final String id;
  final String name;
  final Color surfaceColor;
  final Color borderColor;

  const CardStyleOption({
    required this.id,
    required this.name,
    required this.surfaceColor,
    required this.borderColor,
  });
}

class ThemeProvider with ChangeNotifier {
  static const String _prefDarkModeKey = 'sagara_dark_mode';
  static const String _prefButtonColorKey = 'sagara_button_color_id';
  static const String _prefTerminalKey = 'sagara_terminal_id';
  static const String _prefCardStyleKey = 'sagara_card_style_id';

  // Preset Button Colors (NO pitch-black default!)
  static const List<ThemeColorOption> buttonColorPresets = [
    ThemeColorOption(
      id: 'blue',
      name: 'Sagara Blue (Utama)',
      color: Color(0xFF2563EB), // Blue 600 - Standard brand action
    ),
    ThemeColorOption(
      id: 'indigo',
      name: 'Deep Indigo',
      color: Color(0xFF4F46E5), // Indigo 600
    ),
    ThemeColorOption(
      id: 'teal',
      name: 'Ocean Teal',
      color: Color(0xFF0D9488), // Teal 600
    ),
    ThemeColorOption(
      id: 'emerald',
      name: 'Emerald Mint',
      color: Color(0xFF059669), // Emerald 600
    ),
    ThemeColorOption(
      id: 'violet',
      name: 'Royal Violet',
      color: Color(0xFF7C3AED), // Violet 600
    ),
    ThemeColorOption(
      id: 'slate',
      name: 'Slate Navy (Soft)',
      color: Color(0xFF334155), // Slate 700 (Soft navy, not pitch black)
    ),
    ThemeColorOption(
      id: 'carbon',
      name: 'Carbon (Khusus Dark)',
      color: Color(0xFF0F172A), // Slate 900
    ),
  ];

  // Preset Terminal Themes
  static const List<TerminalThemeOption> terminalPresets = [
    TerminalThemeOption(
      id: 'light_editor',
      name: 'Light Slate Editor',
      backgroundColor: Color(0xFFF1F5F9), // Slate 100 - Clean light editor without black
      textColor: Color(0xFF0F172A), // High contrast readable dark text
      headerColor: Color(0xFF64748B),
      borderColor: Color(0xFFE2E8F0),
    ),
    TerminalThemeOption(
      id: 'midnight_slate',
      name: 'Midnight Slate (Serene)',
      backgroundColor: Color(0xFF1E293B), // Slate 800
      textColor: Color(0xFF38BDF8), // Cyan sky
      headerColor: Color(0xFF94A3B8),
      borderColor: Color(0xFF334155),
    ),
    TerminalThemeOption(
      id: 'deep_obsidian',
      name: 'Cyber Obsidian',
      backgroundColor: Color(0xFF0F172A),
      textColor: Color(0xFFDAE2FD),
      headerColor: Color(0xFF7C839B),
      borderColor: Color(0xFF1E293B),
    ),
    TerminalThemeOption(
      id: 'matrix_mint',
      name: 'Matrix Emerald',
      backgroundColor: Color(0xFF061A14),
      textColor: Color(0xFF34D399),
      headerColor: Color(0xFF10B981),
      borderColor: Color(0xFF064E3B),
    ),
  ];

  // Preset Card Surface Styles
  static const List<CardStyleOption> cardPresets = [
    CardStyleOption(
      id: 'pure_white',
      name: 'Pure White (Bersih)',
      surfaceColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE2E8F0),
    ),
    CardStyleOption(
      id: 'soft_slate',
      name: 'Soft Slate Tint',
      surfaceColor: Color(0xFFF8FAFC),
      borderColor: Color(0xFFE2E8F0),
    ),
    CardStyleOption(
      id: 'warm_canvas',
      name: 'Warm Airy Canvas',
      surfaceColor: Color(0xFFFAFAFA),
      borderColor: Color(0xFFE5E7EB),
    ),
  ];

  // Active State
  bool _isDarkMode = false;
  ThemeColorOption _selectedButtonColor = buttonColorPresets[0]; // Sagara Blue #2563EB by default!
  TerminalThemeOption _selectedTerminal = terminalPresets[0]; // Light Slate Editor by default!
  CardStyleOption _selectedCardStyle = cardPresets[0]; // Pure White by default

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_prefDarkModeKey) ?? false;
      final btnId = prefs.getString(_prefButtonColorKey);
      if (btnId != null) {
        _selectedButtonColor = buttonColorPresets.firstWhere(
          (opt) => opt.id == btnId,
          orElse: () => buttonColorPresets[0],
        );
      }
      final termId = prefs.getString(_prefTerminalKey);
      if (termId != null) {
        _selectedTerminal = terminalPresets.firstWhere(
          (opt) => opt.id == termId,
          orElse: () => terminalPresets[0],
        );
      }
      final cardId = prefs.getString(_prefCardStyleKey);
      if (cardId != null) {
        _selectedCardStyle = cardPresets.firstWhere(
          (opt) => opt.id == cardId,
          orElse: () => cardPresets[0],
        );
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persistPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefDarkModeKey, _isDarkMode);
      await prefs.setString(_prefButtonColorKey, _selectedButtonColor.id);
      await prefs.setString(_prefTerminalKey, _selectedTerminal.id);
      await prefs.setString(_prefCardStyleKey, _selectedCardStyle.id);
    } catch (_) {}
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  ThemeColorOption get selectedButtonColor => _selectedButtonColor;
  TerminalThemeOption get selectedTerminal => _selectedTerminal;
  CardStyleOption get selectedCardStyle => _selectedCardStyle;

  // Active Color Tokens (Fully Reactive across the whole app)
  Color get primaryButtonColor => _selectedButtonColor.color;
  Color get onPrimaryButtonColor => _selectedButtonColor.onColor;

  Color get terminalBg => _isDarkMode
      ? (_selectedTerminal.id == 'light_editor'
          ? const Color(0xFF1E293B)
          : _selectedTerminal.backgroundColor)
      : _selectedTerminal.backgroundColor;

  Color get terminalText => _isDarkMode
      ? (_selectedTerminal.id == 'light_editor'
          ? const Color(0xFFDAE2FD)
          : _selectedTerminal.textColor)
      : _selectedTerminal.textColor;

  Color get terminalHeaderColor => _selectedTerminal.headerColor;
  Color get terminalBorder => _selectedTerminal.borderColor;

  Color get cardBg => _isDarkMode ? const Color(0xFF1E293B) : _selectedCardStyle.surfaceColor;
  Color get canvasBg => _isDarkMode ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);
  Color get textPrimary => _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get textSecondary => _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get borderDefault => _isDarkMode ? const Color(0xFF334155) : _selectedCardStyle.borderColor;
  Color get borderSubtle => _isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

  // Chat Bubble Color (Dynamic: uses selected button color or soft slate, NOT pitch black in light mode!)
  Color get userChatBubbleBg => _isDarkMode ? const Color(0xFF1E293B) : _selectedButtonColor.color;
  Color get userChatBubbleText => Colors.white;

  // Dock & Active Highlights
  Color get dockBg => _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get dockSelectedPill => _selectedButtonColor.color;

  // Setters
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    if (_isDarkMode && _selectedTerminal.id == 'light_editor') {
      _selectedTerminal = terminalPresets[1]; // midnight_slate
    }
    _persistPreferences();
    notifyListeners();
  }

  void setButtonColor(ThemeColorOption option) {
    _selectedButtonColor = option;
    _persistPreferences();
    notifyListeners();
  }

  void setTerminalTheme(TerminalThemeOption option) {
    _selectedTerminal = option;
    _persistPreferences();
    notifyListeners();
  }

  void setCardStyle(CardStyleOption option) {
    _selectedCardStyle = option;
    _persistPreferences();
    notifyListeners();
  }

  void resetToDefaults() {
    _isDarkMode = false;
    _selectedButtonColor = buttonColorPresets[0]; // Sagara Blue
    _selectedTerminal = terminalPresets[0]; // Light Slate Editor
    _selectedCardStyle = cardPresets[0]; // Pure White
    _lastSavedAt = DateTime.now();
    _persistPreferences();
    notifyListeners();
  }

  DateTime? _lastSavedAt;
  DateTime? get lastSavedAt => _lastSavedAt;

  void savePreferences() {
    _lastSavedAt = DateTime.now();
    _persistPreferences();
    notifyListeners();
  }

  ThemeData get themeData {
    final base = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: canvasBg,
      colorScheme: ColorScheme(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryButtonColor,
        onPrimary: onPrimaryButtonColor,
        secondary: AppColors.brandBlue,
        onSecondary: Colors.white,
        error: AppColors.rejectionRed,
        onError: Colors.white,
        surface: cardBg,
        onSurface: textPrimary,
        outline: borderDefault,
        outlineVariant: borderSubtle,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderDefault, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButtonColor,
          foregroundColor: onPrimaryButtonColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryButtonColor,
        foregroundColor: onPrimaryButtonColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvasBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
