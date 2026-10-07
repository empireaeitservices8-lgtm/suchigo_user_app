import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecycleIllustration extends StatelessWidget {
  final double size;

  const RecycleIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _RecyclePainter(),
      ),
    );
  }
}

class _RecyclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft Green Leaf / Aura Backdrop
    final auraPaint = Paint()
      ..color = const Color(0xFFD5F3E4).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.48),
        width: w * 0.88,
        height: h * 0.82,
      ),
      auraPaint,
    );

    final blackStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final greenFill = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;

    // Ground Baseline
    canvas.drawLine(
      Offset(w * 0.22, h * 0.72),
      Offset(w * 0.78, h * 0.72),
      blackStroke,
    );

    // Left Small Bin
    final leftBinRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.52, w * 0.17, h * 0.18),
      const Radius.circular(5),
    );
    canvas.drawRRect(leftBinRect, fillWhite);
    canvas.drawRRect(leftBinRect, blackStroke);

    // Left Bin Lid (mint green)
    final leftLidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.50, w * 0.19, h * 0.035),
      const Radius.circular(3),
    );
    canvas.drawRRect(leftLidRect, Paint()..color = const Color(0xFF26A69A));
    canvas.drawRRect(leftLidRect, blackStroke);

    // Left Bin Wheel
    _drawWheel(canvas, Offset(w * 0.28, h * 0.71), w * 0.026, blackStroke);

    // Left Bin Recycle Icon
    _drawRecycleTriangle(canvas, Offset(w * 0.335, h * 0.61), w * 0.038, blackStroke);

    // Right Big Bin
    final rightBinRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.49, h * 0.46, w * 0.19, h * 0.24),
      const Radius.circular(6),
    );
    canvas.drawRRect(rightBinRect, fillWhite);
    canvas.drawRRect(rightBinRect, blackStroke);

    // Right Big Bin Top Green Section / Open Lid
    final rightTopRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.53, h * 0.42, w * 0.19, h * 0.06),
      const Radius.circular(6),
    );
    canvas.drawRRect(rightTopRect, greenFill);
    canvas.drawRRect(rightTopRect, blackStroke);

    // Right Bin Wheel
    _drawWheel(canvas, Offset(w * 0.52, h * 0.71), w * 0.026, blackStroke);

    // Right Bin Recycle Icon
    _drawRecycleTriangle(canvas, Offset(w * 0.585, h * 0.58), w * 0.045, blackStroke);

    // Character (Young person with dark shirt & bottle)
    // Head
    final headCenter = Offset(w * 0.42, h * 0.43);
    canvas.drawCircle(headCenter, w * 0.032, Paint()..color = const Color(0xFF1E293B));

    // Torso (Dark Shirt)
    final torsoPath = Path();
    torsoPath.moveTo(w * 0.385, h * 0.47);
    torsoPath.lineTo(w * 0.46, h * 0.47);
    torsoPath.lineTo(w * 0.45, h * 0.58);
    torsoPath.lineTo(w * 0.365, h * 0.58);
    torsoPath.close();
    canvas.drawPath(torsoPath, Paint()..color = const Color(0xFF1E293B));

    // Arms holding bottle
    final armPath = Path();
    armPath.moveTo(w * 0.44, h * 0.48);
    armPath.lineTo(w * 0.49, h * 0.45);
    armPath.lineTo(w * 0.51, h * 0.44);
    canvas.drawPath(armPath, blackStroke);

    // Bottle in hand (White with black stroke)
    final bottlePath = Path();
    bottlePath.moveTo(w * 0.475, h * 0.445);
    bottlePath.lineTo(w * 0.52, h * 0.415);
    bottlePath.lineTo(w * 0.54, h * 0.435);
    bottlePath.lineTo(w * 0.495, h * 0.465);
    bottlePath.close();
    canvas.drawPath(bottlePath, fillWhite);
    canvas.drawPath(bottlePath, blackStroke);

    // Legs
    final leftLeg = Path();
    leftLeg.moveTo(w * 0.38, h * 0.58);
    leftLeg.lineTo(w * 0.38, h * 0.72);
    leftLeg.lineTo(w * 0.36, h * 0.72);
    canvas.drawPath(leftLeg, blackStroke);

    final rightLeg = Path();
    rightLeg.moveTo(w * 0.43, h * 0.58);
    rightLeg.lineTo(w * 0.43, h * 0.72);
    rightLeg.lineTo(w * 0.46, h * 0.72);
    canvas.drawPath(rightLeg, blackStroke);

    // Floating Recycle Symbol (Top Left)
    _drawRecycleTriangle(canvas, Offset(w * 0.27, h * 0.39), w * 0.05, blackStroke);

    // Sparkling Elements (+) and circular arcs
    _drawSpark(canvas, Offset(w * 0.36, h * 0.38), 5, blackStroke);
    _drawSpark(canvas, Offset(w * 0.74, h * 0.59), 5, blackStroke);

    // Top Arc
    final arcPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.40, h * 0.42), radius: 60),
      -math.pi * 0.95,
      math.pi * 0.55,
      false,
      arcPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.51, h * 0.36),
      3,
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, Paint stroke) {
    final wheelPaint = Paint()
      ..color = const Color(0xFF26A69A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, wheelPaint);
    canvas.drawCircle(center, radius, stroke);
    canvas.drawCircle(center, radius * 0.35, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.35, stroke);
  }

  void _drawRecycleTriangle(
      Canvas canvas, Offset center, double size, Paint stroke) {
    final p1 = Offset(center.dx, center.dy - size);
    final p2 = Offset(center.dx + size * 0.866, center.dy + size * 0.5);
    final p3 = Offset(center.dx - size * 0.866, center.dy + size * 0.5);

    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();
    canvas.drawPath(path, stroke);
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
