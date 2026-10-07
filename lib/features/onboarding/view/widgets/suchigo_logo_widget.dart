import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuchiGoLogoWidget extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool showText;

  const SuchiGoLogoWidget({
    super.key,
    this.size = 140,
    this.showTagline = true,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Vector Icon of the SuchiGo Bin
        SizedBox(
          width: size.w,
          height: (size * 0.72).w,
          child: CustomPaint(
            painter: _SuchiGoIconPainter(),
          ),
        ),
        if (showText) ...[
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Suchi',
                  style: TextStyle(
                    fontSize: (size * 0.22).sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF138848),
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'Go',
                  style: TextStyle(
                    fontSize: (size * 0.22).sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0288D1),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (showTagline) ...[
          SizedBox(height: 3.h),
          Text(
            'Schedule. Collect. Sustain',
            style: TextStyle(
              fontSize: (size * 0.082).sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF90A4AE),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ],
    );
  }
}

class _SuchiGoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Paint for speed lines
    final speedLinePaint = Paint()
      ..color = const Color(0xFF00C853)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.045
      ..style = PaintingStyle.stroke;

    // 3 Speed lines on the left
    // Top speed line
    canvas.drawLine(
      Offset(w * 0.36, h * 0.58),
      Offset(w * 0.44, h * 0.58),
      speedLinePaint,
    );
    // Middle speed line with circle dot
    final cyanSpeedPaint = Paint()
      ..color = const Color(0xFF00B0FF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.045
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(w * 0.32, h * 0.68),
      Offset(w * 0.50, h * 0.68),
      speedLinePaint,
    );
    // Bottom speed line leading into wheel
    canvas.drawLine(
      Offset(w * 0.35, h * 0.78),
      Offset(w * 0.52, h * 0.78),
      cyanSpeedPaint,
    );

    // Draw the rolling Wheel at bottom right/center
    final wheelCenter = Offset(w * 0.58, h * 0.76);
    final wheelRadius = h * 0.12;

    final wheelPaint = Paint()
      ..color = const Color(0xFF0288D1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.055;
    canvas.drawCircle(wheelCenter, wheelRadius, wheelPaint);

    final axlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(wheelCenter, wheelRadius * 0.4, axlePaint);

    // Bin Body (Tilted Trash Container with rounded corners)
    canvas.save();
    // Rotate canvas slightly for the dynamic speed tilt
    canvas.translate(w * 0.55, h * 0.45);
    canvas.rotate(-18 * math.pi / 180);

    final binRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(0, 0),
        width: w * 0.34,
        height: h * 0.56,
      ),
      const Radius.circular(8),
    );

    // Bin Gradient (Green to Teal)
    final binGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF26A69A),
        Color(0xFF00C853),
        Color(0xFF00897B),
      ],
    ).createShader(binRect.outerRect);

    final binPaint = Paint()
      ..shader = binGradient
      ..style = PaintingStyle.fill;

    canvas.drawRRect(binRect, binPaint);

    // Yellow / Lime rim of the bin lid
    final lidPath = Path();
    lidPath.moveTo(-w * 0.19, -h * 0.28);
    lidPath.lineTo(w * 0.19, -h * 0.28);
    lidPath.lineTo(w * 0.16, -h * 0.24);
    lidPath.lineTo(-w * 0.16, -h * 0.24);
    lidPath.close();

    final lidPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lidPath, lidPaint);

    // Bin handle at top
    final handlePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-w * 0.12, -h * 0.28),
      Offset(-w * 0.08, -h * 0.33),
      handlePaint,
    );
    canvas.drawLine(
      Offset(-w * 0.08, -h * 0.33),
      Offset(w * 0.08, -h * 0.33),
      handlePaint,
    );
    canvas.drawLine(
      Offset(w * 0.08, -h * 0.33),
      Offset(w * 0.12, -h * 0.28),
      handlePaint,
    );

    // Recycle 3 Leaves / Arrows Emblem inside bin
    _drawRecycleSymbol(canvas, Offset(0, h * 0.02), w * 0.12);

    canvas.restore();
  }

  void _drawRecycleSymbol(Canvas canvas, Offset center, double radius) {
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final angle = i * 2 * math.pi / 3;
      final p1 = Offset(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * 0.7 * math.cos(angle + 0.8),
        center.dy + radius * 0.7 * math.sin(angle + 0.8),
      );

      final arrowPath = Path();
      arrowPath.moveTo(p1.dx, p1.dy);
      arrowPath.quadraticBezierTo(
        center.dx + radius * 0.9 * math.cos(angle + 0.4),
        center.dy + radius * 0.9 * math.sin(angle + 0.4),
        p2.dx,
        p2.dy,
      );
      canvas.drawPath(arrowPath, whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
