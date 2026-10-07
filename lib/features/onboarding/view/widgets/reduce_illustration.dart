import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReduceIllustration extends StatelessWidget {
  final double size;

  const ReduceIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _ReducePainter(),
      ),
    );
  }
}

class _ReducePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft Mint/Cyan Backdrop Aura
    final auraPaint = Paint()
      ..color = const Color(0xFFD5F3E4).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final auraPath = Path();
    auraPath.addOval(Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.5),
      width: w * 0.85,
      height: h * 0.85,
    ));
    canvas.drawPath(auraPath, auraPaint);

    final blackStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thinBlack = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final fillWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Ground baseline
    canvas.drawLine(
      Offset(w * 0.16, h * 0.72),
      Offset(w * 0.84, h * 0.72),
      blackStroke,
    );

    // 1. Factory Chimney / Stack (Left side)
    final chimneyRect = Rect.fromLTRB(w * 0.22, h * 0.38, w * 0.31, h * 0.72);
    canvas.drawRect(chimneyRect, fillWhite);
    canvas.drawRect(chimneyRect, blackStroke);

    // Chimney Rim
    final rimRect = Rect.fromLTRB(w * 0.205, h * 0.36, w * 0.325, h * 0.38);
    canvas.drawRect(rimRect, fillWhite);
    canvas.drawRect(rimRect, blackStroke);

    // Chimney Horizontal stripes
    for (int i = 1; i <= 6; i++) {
      final y = h * 0.38 + i * (h * 0.34 / 7);
      canvas.drawLine(
        Offset(w * 0.22, y),
        Offset(w * 0.31, y),
        thinBlack,
      );
    }

    // Smoke Clouds puffing from chimney
    final cloudPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Cloud 1
    final cloud1 = Path();
    cloud1.moveTo(w * 0.27, h * 0.35);
    cloud1.quadraticBezierTo(w * 0.24, h * 0.31, w * 0.27, h * 0.28);
    cloud1.quadraticBezierTo(w * 0.30, h * 0.22, w * 0.36, h * 0.26);
    cloud1.quadraticBezierTo(w * 0.42, h * 0.27, w * 0.41, h * 0.32);
    cloud1.quadraticBezierTo(w * 0.43, h * 0.37, w * 0.36, h * 0.38);
    cloud1.quadraticBezierTo(w * 0.29, h * 0.40, w * 0.27, h * 0.35);
    cloud1.close();
    canvas.drawPath(cloud1, cloudPaint);
    canvas.drawPath(cloud1, blackStroke);

    // Cloud 2 (higher)
    final cloud2 = Path();
    cloud2.moveTo(w * 0.39, h * 0.30);
    cloud2.quadraticBezierTo(w * 0.40, h * 0.23, w * 0.47, h * 0.23);
    cloud2.quadraticBezierTo(w * 0.54, h * 0.21, w * 0.58, h * 0.27);
    cloud2.quadraticBezierTo(w * 0.62, h * 0.32, w * 0.56, h * 0.36);
    cloud2.quadraticBezierTo(w * 0.46, h * 0.38, w * 0.39, h * 0.30);
    cloud2.close();
    canvas.drawPath(cloud2, cloudPaint);
    canvas.drawPath(cloud2, blackStroke);

    // 2. Nuclear Reactor / Cooling Tower (Center)
    final towerPath = Path();
    towerPath.moveTo(w * 0.38, h * 0.42);
    // Left hyperbolic curve
    towerPath.quadraticBezierTo(w * 0.36, h * 0.55, w * 0.34, h * 0.72);
    towerPath.lineTo(w * 0.58, h * 0.72);
    // Right hyperbolic curve
    towerPath.quadraticBezierTo(w * 0.56, h * 0.55, w * 0.54, h * 0.42);
    towerPath.close();

    canvas.drawPath(towerPath, fillWhite);
    canvas.drawPath(towerPath, blackStroke);

    // Tower horizontal base line
    canvas.drawLine(
      Offset(w * 0.345, h * 0.69),
      Offset(w * 0.575, h * 0.69),
      thinBlack,
    );

    // Radiation / Biohazard Warning symbol on tower front
    final triCenter = Offset(w * 0.46, h * 0.56);
    _drawRadiationSymbol(canvas, triCenter, w * 0.045, blackStroke);

    // 3. Big Vivid Green Down Arrow (pointing to hazard circle)
    final greenArrowPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(w * 0.61, h * 0.38);
    arrowPath.lineTo(w * 0.70, h * 0.38);
    arrowPath.lineTo(w * 0.70, h * 0.48);
    arrowPath.lineTo(w * 0.75, h * 0.48);
    arrowPath.lineTo(w * 0.655, h * 0.60);
    arrowPath.lineTo(w * 0.56, h * 0.48);
    arrowPath.lineTo(w * 0.61, h * 0.48);
    arrowPath.close();

    canvas.drawPath(arrowPath, greenArrowPaint);
    canvas.drawPath(arrowPath, blackStroke);

    // 4. Biohazard / Green Circle Badge with radiation symbol at bottom right
    final badgeCenter = Offset(w * 0.69, h * 0.70);
    final badgeRadius = w * 0.085;

    final greenBadgePaint = Paint()
      ..color = const Color(0xFF26A69A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(badgeCenter, badgeRadius, greenBadgePaint);
    canvas.drawCircle(badgeCenter, badgeRadius, blackStroke);

    // Radioactive symbol inside badge
    _drawHazardTrefoil(canvas, badgeCenter, badgeRadius * 0.65, blackStroke);

    // 5. Surrounding Dotted Spark Accents (+) and circles
    _drawSpark(canvas, Offset(w * 0.18, h * 0.44), 6, blackStroke);
    _drawSpark(canvas, Offset(w * 0.63, h * 0.30), 6, blackStroke);
    _drawSpark(canvas, Offset(w * 0.74, h * 0.48), 5, blackStroke);

    canvas.drawCircle(
      Offset(w * 0.23, h * 0.34),
      4.5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    canvas.drawCircle(
      Offset(w * 0.67, h * 0.35),
      4.5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Green dot
    canvas.drawCircle(
      Offset(w * 0.73, h * 0.46),
      4,
      Paint()
        ..color = const Color(0xFF00C853)
        ..style = PaintingStyle.fill,
    );

    // Arc on right
    final arcPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.78, h * 0.58), radius: 18),
      -math.pi / 2,
      math.pi,
      false,
      arcPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.58 - 18),
      2.5,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawRadiationSymbol(
      Canvas canvas, Offset center, double size, Paint stroke) {
    // 3 triangles around small center circle
    final cPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 2.5, cPaint);

    for (int i = 0; i < 3; i++) {
      final angle = (i * 120 - 90) * math.pi / 180;
      final p = Offset(center.dx + size * math.cos(angle),
          center.dy + size * math.sin(angle));
      final triPath = Path();
      triPath.moveTo(p.dx, p.dy - 3);
      triPath.lineTo(p.dx + 4, p.dy + 4);
      triPath.lineTo(p.dx - 4, p.dy + 4);
      triPath.close();
      canvas.drawPath(triPath, stroke);
    }
  }

  void _drawHazardTrefoil(
      Canvas canvas, Offset center, double radius, Paint stroke) {
    // Center black dot
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill,
    );

    // 3 trefoil fan blades
    for (int i = 0; i < 3; i++) {
      final startAngle = (i * 120 - 30) * math.pi / 180;
      final sweepAngle = 60 * math.pi / 180;

      final bladePath = Path();
      bladePath.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      );
      bladePath.arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.35),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      bladePath.close();

      canvas.drawPath(
        bladePath,
        Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawSpark(Canvas canvas, Offset center, double size, Paint stroke) {
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      stroke,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
