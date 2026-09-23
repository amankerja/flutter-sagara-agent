import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusPill extends StatelessWidget {
  final String text;
  final String statusType; // ACTIVE, IDLE, DEGRADED, OFFLINE, CRITICAL, HIGH, MEDIUM, LOW, PENDING
  final bool showDot;

  const StatusPill({
    super.key,
    required this.text,
    this.statusType = 'ACTIVE',
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Color dotColor;

    switch (statusType.toUpperCase()) {
      case 'ACTIVE':
      case 'HEALTHY':
      case 'RUNNING':
      case 'APPROVED':
      case 'COMPLETED':
        bg = AppColors.pastelMint;
        textColor = AppColors.pastelMintText;
        dotColor = AppColors.approvalGreen;
        break;
      case 'CRITICAL':
      case 'FAILED':
      case 'REJECTED':
      case 'ERROR':
        bg = AppColors.rejectionRedSubtle;
        textColor = AppColors.rejectionRed;
        dotColor = AppColors.rejectionRed;
        break;
      case 'HIGH':
      case 'WARNING':
      case 'AWAITING_APPROVAL':
      case 'DEGRADED':
        bg = AppColors.pastelPeach;
        textColor = AppColors.pastelPeachText;
        dotColor = AppColors.pastelPeachText;
        break;
      case 'MEDIUM':
      case 'INFO':
      case 'READY':
      case 'SCHEDULED':
        bg = AppColors.pastelSky;
        textColor = AppColors.pastelSkyText;
        dotColor = AppColors.pastelSkyText;
        break;
      case 'IDLE':
      case 'OFFLINE':
      case 'QUEUED':
      case 'LOW':
      default:
        bg = AppColors.surfaceContainerLow;
        textColor = AppColors.textSecondary;
        dotColor = AppColors.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
