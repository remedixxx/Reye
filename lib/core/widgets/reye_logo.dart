import 'dart:math' as math;

import 'package:flutter/material.dart';

class ReyeLogo extends StatelessWidget {
  const ReyeLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ReyeLogoPainter(colorScheme: Theme.of(context).colorScheme),
    );
  }
}

class _ReyeLogoPainter extends CustomPainter {
  const _ReyeLogoPainter({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.primary, colorScheme.tertiary],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.28)),
      background,
    );

    final eyePaint = Paint()
      ..color = colorScheme.onPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.13
      ..strokeCap = StrokeCap.round;

    final eyeRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.02),
      width: radius * 1.32,
      height: radius * 0.82,
    );
    canvas.drawArc(eyeRect, math.pi * 0.08, math.pi * 0.84, false, eyePaint);
    canvas.drawArc(eyeRect, math.pi * 1.08, math.pi * 0.84, false, eyePaint);

    final pupilPaint = Paint()..color = colorScheme.onPrimary;
    canvas.drawCircle(center, radius * 0.18, pupilPaint);

    final highlightPaint = Paint()
      ..color = colorScheme.primaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.58),
      math.pi * 1.14,
      math.pi * 0.34,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ReyeLogoPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
