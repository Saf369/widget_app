import 'dart:ui';
import 'package:flutter/material.dart';

class FourPointStarPainter extends CustomPainter {
  final Color color;
  final double pinch;

  const FourPointStarPainter({
    required this.color,
    this.pinch = 0.68,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    // Concave pinch control offsets
    final cpX = cx * (1.0 - pinch);
    final cpY = cy * (1.0 - pinch);

    final path = Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx + cpX, cy - cpY, w, cy)
      ..quadraticBezierTo(cx + cpX, cy + cpY, cx, h)
      ..quadraticBezierTo(cx - cpX, cy + cpY, 0, cy)
      ..quadraticBezierTo(cx - cpX, cy - cpY, cx, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FourPointStarPainter oldDelegate) =>
      color != oldDelegate.color || pinch != oldDelegate.pinch;
}

class FourPointStar extends StatelessWidget {
  final double size;
  final Color color;
  final double pinch;
  final bool hasGlow;
  final Color? glowColor;

  const FourPointStar({
    super.key,
    required this.size,
    this.color = Colors.white,
    this.pinch = 0.68,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final starWidget = CustomPaint(
      size: Size(size, size),
      painter: FourPointStarPainter(color: color, pinch: pinch),
    );

    if (!hasGlow) return starWidget;

    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: CustomPaint(
            size: Size(size * 1.1, size * 1.1),
            painter: FourPointStarPainter(
              color: (glowColor ?? color).withOpacity(0.65),
              pinch: pinch,
            ),
          ),
        ),
        starWidget,
      ],
    );
  }
}
