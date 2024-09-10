import 'package:flutter/material.dart';

class NetBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    const double spacing = 20;

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

