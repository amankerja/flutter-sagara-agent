import 'package:flutter/material.dart';

/// App Color Palette adhering strictly to Stitch UI/UX Redesign
/// (Pastel Mission Telemetry & Serene Transit Design System)
class AppColors {
  AppColors._();

  // Base Canvas & Elevated Surfaces
  static const Color canvasBg = Color(0xFFF8FAFF);
  static const Color primaryBackground = Color(0xFFF8FAFF); // Soft airy canvas
  static const Color secondaryBackground = Color(0xFFF1F5F9); // Slate 100
  static const Color surface = Color(0xFFFFFFFF); // Pure white card

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Carbon / Obsidian Anchor (High-Contrast Grounding)
  static const Color carbon = Color(0xFF0F172A); // Slate 900
  static const Color primary = Color(0xFF0F172A); // Primary CTA & active indicator
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color brandBlue = Color(0xFF2563EB); // Sagara AI Brand Accent
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 (Titles, values, IDs)
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 (Labels, descriptions)
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400 (Placeholders)

  // Borders & Perforations
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color borderDefault = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDashed = Color(0xFFCBD5E1); // Slate 300 (Ticket tear line)

  // Pastel Mission Telemetry Tokens
  static const Color pastelMint = Color(0xFFE8FAF6);
  static const Color pastelMintText = Color(0xFF0D9488);

  static const Color pastelLavender = Color(0xFFF0EFFF);
  static const Color pastelLavenderText = Color(0xFF6D28D9);

  static const Color pastelSky = Color(0xFFE0F2FE);
  static const Color pastelSkyText = Color(0xFF0284C7);

  static const Color pastelPeach = Color(0xFFFFEDD5);
  static const Color pastelPeachText = Color(0xFFEA580C);

  // Terminal & Monospace Console
  static const Color terminalCodeBg = Color(0xFF131B2E);
  static const Color terminalCodeText = Color(0xFFDAE2FD);

  // HITL Approval & Rejection Semantics
  static const Color approvalGreen = Color(0xFF059669);
  static const Color approvalGreenSubtle = Color(0xFFECFDF5);
  static const Color rejectionRed = Color(0xFFDC2626);
  static const Color rejectionRedSubtle = Color(0xFFFEF2F2);

  // Legacy Semantic Status Mapping (Maintained for full compatibility)
  static const Color statusActiveBg = Color(0xFFDCFCE7);
  static const Color statusActiveText = Color(0xFF15803D);

  static const Color statusInfoBg = Color(0xFFE0F2FE);
  static const Color statusInfoText = Color(0xFF0369A1);

  static const Color statusWarningBg = Color(0xFFFEF9C3);
  static const Color statusWarningText = Color(0xFF854D0E);

  static const Color statusDangerBg = Color(0xFFFEE2E2);
  static const Color statusDangerText = Color(0xFFB91C1C);

  static const Color statusMutedBg = Color(0xFFF1F5F9);
  static const Color statusMutedText = Color(0xFF475569);
}
