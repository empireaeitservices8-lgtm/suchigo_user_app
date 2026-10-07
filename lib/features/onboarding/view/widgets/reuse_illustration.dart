import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReuseIllustration extends StatelessWidget {
  final double size;

  const ReuseIllustration({super.key, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: CustomPaint(
        painter: _ReusePainter(),
      ),
    );
  }
}

class _ReusePainter extends CustomPainter {
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

    // Bench / Sitting Ledge Baseline
    canvas.drawLine(
      Offset(w * 0.24, h * 0.58),
      Offset(w * 0.72, h * 0.58),
      blackStroke,
    );

    // 1. Person sitting on bench
    // Head
    canvas.drawCircle(
      Offset(w * 0.31, h * 0.49),
      w * 0.03,
      Paint()..color = const Color(0xFF1E293B),
    );

    // Torso (Dark)
    final torso = Path();
    torso.moveTo(w * 0.28, h * 0.52);
    torso.lineTo(w * 0.34, h * 0.52);
    torso.lineTo(w * 0.33, h * 0.58);
    torso.lineTo(w * 0.27, h * 0.58);
    torso.close();
    canvas.drawPath(torso, Paint()..color = const Color(0xFF1E293B));

    // Legs hanging down from bench
    final leftLeg = Path();
    leftLeg.moveTo(w * 0.30, h * 0.58);
    leftLeg.lineTo(w * 0.33, h * 0.58);
    leftLeg.lineTo(w * 0.34, h * 0.64);
    leftLeg.lineTo(w * 0.37, h * 0.64);
    leftLeg.lineTo(w * 0.37, h * 0.655);
    leftLeg.lineTo(w * 0.32, h * 0.655);
    leftLeg.lineTo(w * 0.30, h * 0.60);
    leftLeg.close();
    canvas.drawPath(leftLeg, fillWhite);
    canvas.drawPath(leftLeg, blackStroke);

    // Shoes (Black)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.655),
        width: 14,
        height: 7,
      ),
      Paint()..color = const Color(0xFF1E293B),
    );

    // 2. ECO Tote Bag on bench
    final bagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.41, h * 0.53, w * 0.085, h * 0.05),
      const Radius.circular(4),
    );
    canvas.drawRRect(bagRect, fillWhite);
    canvas.drawRRect(bagRect, blackStroke);

    // Bag Handle
    final handlePath = Path();
    handlePath.moveTo(w * 0.435, h * 0.53);
    handlePath.quadraticBezierTo(w * 0.452, h * 0.50, w * 0.47, h * 0.53);
    canvas.drawPath(handlePath, blackStroke);

    // "ECO" Text on bag
    final tp = TextPainter(
      text: const TextSpan(
        text: 'ECO',
        style: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(w * 0.425, h * 0.545));

    // 3. Planet Earth with sprouting green leaves
    final globeCenter = Offset(w * 0.62, h * 0.50);
    final globeRadius = w * 0.105;

    // Earth Sphere (White with green continents)
    canvas.drawCircle(globeCenter, globeRadius, fillWhite);

    // Continents
    final continent1 = Path();
    continent1.addOval(Rect.fromCenter(
      center: Offset(globeCenter.dx - 8, globeCenter.dy - 6),
      width: 18,
      height: 14,
    ));
    continent1.addOval(Rect.fromCenter(
      center: Offset(globeCenter.dx + 10, globeCenter.dy + 8),
      width: 16,
      height: 20,
    ));
    canvas.drawPath(continent1, greenFill);
    canvas.drawCircle(globeCenter, globeRadius, blackStroke);

    // Sprout on top of Earth
    final sproutPath = Path();
    sproutPath.moveTo(globeCenter.dx, globeCenter.dy - globeRadius);
    // Left leaf
    sproutPath.quadraticBezierTo(
      globeCenter.dx - 18,
      globeCenter.dy - globeRadius - 20,
      globeCenter.dx - 2,
      globeCenter.dy - globeRadius - 22,
    );
    sproutPath.quadraticBezierTo(
      globeCenter.dx - 4,
      globeCenter.dy - globeRadius - 10,
      globeCenter.dx,
      globeCenter.dy - globeRadius,
    );
    // Right leaf
    sproutPath.quadraticBezierTo(
      globeCenter.dx + 4,
      globeCenter.dy - globeRadius - 10,
      globeCenter.dx + 2,
      globeCenter.dy - globeRadius - 22,
    );
    sproutPath.quadraticBezierTo(
      globeCenter.dx + 18,
      globeCenter.dy - globeRadius - 20,
      globeCenter.dx,
      globeCenter.dy - globeRadius,
    );
    sproutPath.close();
    canvas.drawPath(sproutPath, greenFill);
    canvas.drawPath(sproutPath, blackStroke);

    // Center stem
    canvas.drawLine(
      Offset(globeCenter.dx, globeCenter.dy - globeRadius),
      Offset(globeCenter.dx, globeCenter.dy - globeRadius - 14),
      blackStroke,
    );

    // Dashed Circular Orbit Arrow around Earth
    _drawDashedOrbit(canvas, globeCenter, globeRadius + 14, blackStroke);

    // 4. Water Droplet Recycle Icon (Top Left)
    final dropCenter = Offset(w * 0.27, h * 0.44);
    _drawWaterDrop(canvas, dropCenter, w * 0.045, blackStroke);

    // 5. Floating Leaf Particles & Plus Accents
    _drawSpark(canvas, Offset(w * 0.23, h * 0.58), 5, blackStroke);
    _drawSpark(canvas, Offset(w * 0.51, h * 0.42), 4, blackStroke);

    // Leaf 1
    _drawLeaf(canvas, Offset(w * 0.38, h * 0.50), 10, -0.4, blackStroke);
    // Leaf 2
    _drawLeaf(canvas, Offset(w * 0.47, h * 0.50), 10, 0.5, blackStroke);

    // Arcs
    final arcPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.45, h * 0.45), radius: 48),
      -math.pi * 0.85,
      math.pi * 0.45,
      false,
      arcPaint,
    );
  }

  void _drawDashedOrbit(
      Canvas canvas, Offset center, double radius, Paint stroke) {
    const dashCount = 14;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (2 * math.pi / dashCount);
      final sweepAngle = (2 * math.pi / dashCount) * 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        stroke,
      );
    }
  }

  void _drawWaterDrop(
      Canvas canvas, Offset center, double size, Paint stroke) {
    final dropPath = Path();
    dropPath.moveTo(center.dx, center.dy - size);
    dropPath.quadraticBezierTo(
      center.dx + size,
      center.dy + size * 0.2,
      center.dx,
      center.dy + size,
    );
    dropPath.quadraticBezierTo(
      center.dx - size,
      center.dy + size * 0.2,
      center.dx,
      center.dy - size,
    );
    dropPath.close();

    canvas.drawPath(dropPath, Paint()..color = Colors.white);
    canvas.drawPath(dropPath, stroke);

    // 2 circling arrows inside drop
    final innerStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 1), radius: size * 0.4),
      0,
      math.pi * 1.5,
      false,
      innerStroke,
    );
  }

  void _drawLeaf(
      Canvas canvas, Offset center, double length, double angle, Paint stroke) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final leafPath = Path();
    leafPath.moveTo(0, -length);
    leafPath.quadraticBezierTo(length * 0.4, 0, 0, length);
    leafPath.quadraticBezierTo(-length * 0.4, 0, 0, -length);
    leafPath.close();

    canvas.drawPath(leafPath, Paint()..color = Colors.white);
    canvas.drawPath(leafPath, stroke);
    canvas.drawLine(Offset(0, -length * 0.7), Offset(0, length * 0.7), stroke);

    canvas.restore();
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
