import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../data/models/system_pulse_model.dart';
import 'status_pill.dart';

class AttentionCard extends StatelessWidget {
  final AttentionItem item;
  final VoidCallback? onTap;

  const AttentionCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCrit = item.severity == 'CRITICAL';
    final isWarn = item.severity == 'WARNING';

    Color cardBg = isCrit ? AppColors.rejectionRedSubtle : (isWarn ? AppColors.pastelPeach.withValues(alpha: 0.5) : Colors.white);
    Color borderColor = isCrit ? const Color(0xFFFECACA) : (isWarn ? const Color(0xFFFED7AA) : AppColors.borderDefault);
    Color iconColor = isCrit ? AppColors.rejectionRed : (isWarn ? AppColors.pastelPeachText : AppColors.pastelSkyText);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                isCrit
                    ? Icons.crisis_alert_rounded
                    : (isWarn ? Icons.warning_amber_rounded : Icons.info_outline_rounded),
                color: iconColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.carbon,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(text: item.severity, statusType: item.severity),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timestamp,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontFamily: 'monospace',
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
