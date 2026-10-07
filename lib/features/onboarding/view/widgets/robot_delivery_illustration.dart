import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RobotDeliveryIllustration extends StatelessWidget {
  final double size;

  const RobotDeliveryIllustration({super.key, this.size = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: (size * 0.95).w,
      child: CustomPaint(
        painter: _RobotDeliveryPainter(),
      ),
    );
  }
}

class _RobotDeliveryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. City Skyline Silhouette in background
    final cityPaint = Paint()
      ..color = const Color(0xFFE2EBF0).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Skyscraper 1
    canvas.drawRect(
      Rect.fromLTWH(w * 0.16, h * 0.28, w * 0.15, h * 0.35),
      cityPaint,
    );
    // Skyscraper 1 Windows
    final windowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 2; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.19 + c * (w * 0.05),
            h * 0.31 + r * (h * 0.055),
            w * 0.03,
            h * 0.03,
          ),
          windowPaint,
        );
      }
    }

    // Skyscraper 2
    canvas.drawRect(
      Rect.fromLTWH(w * 0.62, h * 0.32, w * 0.18, h * 0.32),
      cityPaint,
    );
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 2; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            w * 0.66 + c * (w * 0.06),
            h * 0.35 + r * (h * 0.06),
            w * 0.035,
            h * 0.035,
          ),
          windowPaint,
        );
      }
    }

    // Road speed motion lines
    final roadPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.08, h * 0.72), Offset(w * 0.32, h * 0.72), roadPaint);
    canvas.drawLine(Offset(w * 0.68, h * 0.72), Offset(w * 0.92, h * 0.72), roadPaint);
    canvas.drawLine(Offset(w * 0.12, h * 0.76), Offset(w * 0.28, h * 0.76), roadPaint);

    final blackStroke = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thinBlack = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final oliveGreen = Paint()
      ..color = const Color(0xFF6B8E4E)
      ..style = PaintingStyle.fill;

    final darkOlive = Paint()
      ..color = const Color(0xFF55733E)
      ..style = PaintingStyle.fill;

    final robotTeal = Paint()
      ..color = const Color(0xFF2CB88F)
      ..style = PaintingStyle.fill;

    final deliveryBoxGreen = Paint()
      ..color = const Color(0xFF1E8A63)
      ..style = PaintingStyle.fill;

    // 2. Delivery Trunk Box on rear rack
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.38, w * 0.26, h * 0.20),
      const Radius.circular(10),
    );
    canvas.drawRRect(boxRect, deliveryBoxGreen);
    canvas.drawRRect(boxRect, blackStroke);

    // Box Lid Rim
    final boxLid = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.19, h * 0.37, w * 0.28, h * 0.05),
      const Radius.circular(6),
    );
    canvas.drawRRect(boxLid, Paint()..color = const Color(0xFF176F50));
    canvas.drawRRect(boxLid, blackStroke);

    // "SuchiGo" logo text on box
    final boxLogoTp = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'SuchiGo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    boxLogoTp.layout();
    boxLogoTp.paint(canvas, Offset(w * 0.25, h * 0.46));

    // 3. Robot Driver (Mascot)
    // Robot Body / Torso
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.41, h * 0.39, w * 0.18, h * 0.18),
      const Radius.circular(16),
    );
    canvas.drawRRect(torsoRect, robotTeal);
    canvas.drawRRect(torsoRect, blackStroke);

    // Torso Recycle Circle Badge
    final torsoBadge = Offset(w * 0.50, h * 0.46);
    canvas.drawCircle(torsoBadge, 14, Paint()..color = Colors.white.withValues(alpha: 0.9));
    _drawRecycleSymbol(canvas, torsoBadge, 9);

    // Robot Head (Monitor / Screen Face)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.27, w * 0.16, h * 0.13),
      const Radius.circular(12),
    );
    canvas.drawRRect(headRect, robotTeal);
    canvas.drawRRect(headRect, blackStroke);

    // Head Screen (Teal / Blue tinted visor screen)
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.29, w * 0.12, h * 0.09),
      const Radius.circular(6),
    );
    canvas.drawRRect(screenRect, Paint()..color = const Color(0xFF4DD0E1));

    // Happy Robot Eyes & Smile
    canvas.drawCircle(Offset(w * 0.47, h * 0.33), 2.5, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(w * 0.53, h * 0.33), 2.5, Paint()..color = const Color(0xFF1E293B));

    // Robot Smile Arc
    final smilePath = Path();
    smilePath.arcTo(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.34), radius: 5),
      0.2,
      math.pi * 0.8,
      false,
    );
    canvas.drawPath(smilePath, thinBlack);

    // Leaf Sprout Antenna on top of head
    final sprout = Path();
    sprout.moveTo(w * 0.50, h * 0.27);
    // Left leaf
    sprout.quadraticBezierTo(w * 0.44, h * 0.21, w * 0.49, h * 0.22);
    // Right leaf
    sprout.quadraticBezierTo(w * 0.56, h * 0.21, w * 0.50, h * 0.27);
    sprout.close();
    canvas.drawPath(sprout, Paint()..color = const Color(0xFF7CB342));
    canvas.drawPath(sprout, blackStroke);

    // Robot Arms holding handlebars
    final robotArm = Path();
    robotArm.moveTo(w * 0.44, h * 0.44);
    robotArm.quadraticBezierTo(w * 0.52, h * 0.49, w * 0.58, h * 0.48);
    canvas.drawPath(robotArm, Paint()..color = const Color(0xFF26A69A));
    canvas.drawPath(robotArm, blackStroke);

    // Robot Hands / Grippers
    canvas.drawCircle(Offset(w * 0.58, h * 0.48), 4.5, Paint()..color = const Color(0xFF1E293B));

    // 4. Olive Green Scooter
    // Rear Wheel
    _drawScooterWheel(canvas, Offset(w * 0.38, h * 0.65), w * 0.08, blackStroke);

    // Front Wheel
    _drawScooterWheel(canvas, Offset(w * 0.72, h * 0.65), w * 0.08, blackStroke);

    // Scooter Body / Cowl (Retro curved shape)
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.30, h * 0.58);
    bodyPath.quadraticBezierTo(w * 0.34, h * 0.52, w * 0.46, h * 0.54);
    bodyPath.lineTo(w * 0.54, h * 0.60);
    bodyPath.lineTo(w * 0.62, h * 0.60);
    bodyPath.quadraticBezierTo(w * 0.67, h * 0.48, w * 0.65, h * 0.45);
    bodyPath.lineTo(w * 0.62, h * 0.45);
    bodyPath.quadraticBezierTo(w * 0.60, h * 0.63, w * 0.42, h * 0.63);
    bodyPath.quadraticBezierTo(w * 0.32, h * 0.64, w * 0.30, h * 0.58);
    bodyPath.close();

    canvas.drawPath(bodyPath, oliveGreen);
    canvas.drawPath(bodyPath, blackStroke);

    // Scooter Side Cowl Vents
    canvas.drawLine(Offset(w * 0.34, h * 0.58), Offset(w * 0.38, h * 0.58), thinBlack);
    canvas.drawLine(Offset(w * 0.34, h * 0.60), Offset(w * 0.39, h * 0.60), thinBlack);

    // Front Fork / Legshield
    final frontFork = Path();
    frontFork.moveTo(w * 0.64, h * 0.45);
    frontFork.lineTo(w * 0.70, h * 0.62);
    frontFork.lineTo(w * 0.73, h * 0.62);
    frontFork.lineTo(w * 0.66, h * 0.45);
    frontFork.close();
    canvas.drawPath(frontFork, darkOlive);
    canvas.drawPath(frontFork, blackStroke);

    // Headlight (Round vintage chrome)
    final headlightCenter = Offset(w * 0.67, h * 0.46);
    canvas.drawCircle(headlightCenter, 8, Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawCircle(headlightCenter, 8, blackStroke);

    // Handlebars & Mirrors
    canvas.drawLine(Offset(w * 0.65, h * 0.44), Offset(w * 0.59, h * 0.47), blackStroke);
    // Mirror
    canvas.drawLine(Offset(w * 0.66, h * 0.44), Offset(w * 0.70, h * 0.40), thinBlack);
    canvas.drawCircle(Offset(w * 0.71, h * 0.39), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.71, h * 0.39), 4, thinBlack);

    // Seat
    final seatRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.52, w * 0.14, h * 0.04),
      const Radius.circular(5),
    );
    canvas.drawRRect(seatRect, Paint()..color = const Color(0xFF2C3E50));

    // Robot Legs & Shoes
    final legPath = Path();
    legPath.moveTo(w * 0.48, h * 0.53);
    legPath.lineTo(w * 0.51, h * 0.59);
    legPath.lineTo(w * 0.54, h * 0.59);
    canvas.drawPath(legPath, blackStroke);
    // Shoe
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.54, h * 0.59), width: 14, height: 7),
      Paint()..color = const Color(0xFF1E293B),
    );
  }

  void _drawScooterWheel(
      Canvas canvas, Offset center, double radius, Paint stroke) {
    // Outer Tire (Dark Grey)
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF37474F),
    );
    canvas.drawCircle(center, radius, stroke);

    // Inner Rim (Silver/White)
    canvas.drawCircle(
      center,
      radius * 0.65,
      Paint()..color = const Color(0xFFCFD8DC),
    );
    canvas.drawCircle(center, radius * 0.65, stroke);

    // Axle Nut
    canvas.drawCircle(
      center,
      radius * 0.25,
      Paint()..color = const Color(0xFF455A64),
    );
    canvas.drawCircle(center, radius * 0.25, stroke);
  }

  void _drawRecycleSymbol(Canvas canvas, Offset center, double radius) {
    final greenStroke = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
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
      canvas.drawPath(arrowPath, greenStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
