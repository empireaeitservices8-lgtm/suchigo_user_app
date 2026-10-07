import 'package:flutter/material.dart';

class LeafBackgroundPainter extends CustomPainter {
  final Color leafColor;

  LeafBackgroundPainter({
    this.leafColor = const Color(0xFFE8F6EF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = leafColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Top-left large organic leaf shape
    final path1 = Path();
    path1.moveTo(0, size.height * 0.35);
    path1.cubicTo(
      size.width * 0.1,
      size.height * 0.15,
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.35,
      0,
    );
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    // Central background soft leaf vein / shape
    final path2 = Path();
    path2.moveTo(size.width * 0.2, size.height * 0.22);
    path2.cubicTo(
      size.width * 0.22,
      size.height * 0.16,
      size.width * 0.32,
      size.height * 0.18,
      size.width * 0.36,
      size.height * 0.28,
    );
    path2.cubicTo(
      size.width * 0.42,
      size.height * 0.42,
      size.width * 0.18,
      size.height * 0.55,
      size.width * 0.15,
      size.height * 0.45,
    );
    path2.close();
    canvas.drawPath(
      path2,
      Paint()
        ..color = const Color(0xFFD4EEDB).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );

    // Right leaf shape
    final path3 = Path();
    path3.moveTo(size.width, size.height * 0.32);
    path3.cubicTo(
      size.width * 0.75,
      size.height * 0.35,
      size.width * 0.65,
      size.height * 0.52,
      size.width * 0.95,
      size.height * 0.6,
    );
    path3.lineTo(size.width, size.height * 0.6);
    path3.close();
    canvas.drawPath(
      path3,
      Paint()
        ..color = const Color(0xFFE2F4E9).withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // Bottom-left leaf shape
    final path4 = Path();
    path4.moveTo(0, size.height * 0.78);
    path4.cubicTo(
      size.width * 0.25,
      size.height * 0.82,
      size.width * 0.65,
      size.height * 0.92,
      size.width * 0.5,
      size.height,
    );
    path4.lineTo(0, size.height);
    path4.close();
    canvas.drawPath(
      path4,
      Paint()
        ..color = const Color(0xFFDCF3E4).withValues(alpha: 0.45)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
