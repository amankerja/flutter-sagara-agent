import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Reusable Perforated Boarding Pass Ticket Card
/// Built to replicate the Serene Transit / Pastel Mission Telemetry aesthetic.
class PerforatedTicketCard extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Color headerColor;
  final Color bodyColor;
  final Color borderColor;
  final Color notchColor;
  final double notchRadius;
  final double borderRadius;
  final VoidCallback? onTap;

  const PerforatedTicketCard({
    super.key,
    required this.header,
    required this.body,
    this.headerColor = AppColors.pastelLavender,
    this.bodyColor = AppColors.surface,
    this.borderColor = AppColors.borderDefault,
    this.notchColor = AppColors.canvasBg,
    this.notchRadius = 10.0,
    this.borderRadius = 18.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bodyColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.surfaceContainerLow,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Voucher Top Segment (Pastel Header)
              Container(
                color: headerColor,
                child: header,
              ),

              // 2. Perforated Tear Line with Semicircular Punch Cutouts
              Container(
                color: bodyColor,
                height: notchRadius * 2,
                child: Row(
                  children: [
                    CustomPaint(
                      size: Size(notchRadius, notchRadius * 2),
                      painter: _SemicircleNotchPainter(
                        isLeft: true,
                        fillColor: notchColor,
                        strokeColor: borderColor,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CustomPaint(
                          size: const Size(double.infinity, 2),
                          painter: DashedLinePainter(
                            color: AppColors.borderDashed,
                            dashWidth: 4,
                            dashSpace: 4,
                            strokeWidth: 1.5,
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: Size(notchRadius, notchRadius * 2),
                      painter: _SemicircleNotchPainter(
                        isLeft: false,
                        fillColor: notchColor,
                        strokeColor: borderColor,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Voucher Bottom Segment (Payload / Actions)
              Container(
                color: bodyColor,
                child: body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedLinePainter({
    this.color = const Color(0xFFCBD5E1),
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0, size.width), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      dashWidth != oldDelegate.dashWidth ||
      dashSpace != oldDelegate.dashSpace;
}

class _SemicircleNotchPainter extends CustomPainter {
  final bool isLeft;
  final Color fillColor;
  final Color strokeColor;

  _SemicircleNotchPainter({
    required this.isLeft,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isLeft) {
      // Left notch: inward arc into the card from top to bottom
      path.moveTo(0, 0);
      path.arcTo(
        Rect.fromCircle(center: Offset(0, radius), radius: radius),
        -math.pi / 2,
        math.pi,
        false,
      );
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, radius), radius: radius),
        -math.pi / 2,
        math.pi,
        false,
        strokePaint,
      );
    } else {
      // Right notch: inward arc into the card from right edge
      path.moveTo(size.width, 0);
      path.arcTo(
        Rect.fromCircle(center: Offset(size.width, radius), radius: radius),
        math.pi / 2,
        math.pi,
        false,
      );
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width, radius), radius: radius),
        math.pi / 2,
        math.pi,
        false,
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SemicircleNotchPainter oldDelegate) =>
      isLeft != oldDelegate.isLeft ||
      fillColor != oldDelegate.fillColor ||
      strokeColor != oldDelegate.strokeColor;
}
