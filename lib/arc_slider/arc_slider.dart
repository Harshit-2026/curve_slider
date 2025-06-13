import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ArcSliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final double curvature;
  final ui.Image? image;

  ArcSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.curvature,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.9;
    final arcWidth = size.width * 0.8;

    final startX = centerX - arcWidth / 2;
    final endX = centerX + arcWidth / 2;
    final controlPoint = Offset(centerX, baseY - curvature);

    final path = Path()
      ..moveTo(startX, baseY)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endX, baseY);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.grey.shade800;

    final tickPaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1;

    canvas.drawPath(path, trackPaint);

    // Draw ticks
    const tickCount = 30;
    for (int i = 0; i <= tickCount; i++) {
      double t = i / tickCount;
      final pos = _quadraticBezier(startX, baseY, controlPoint, endX, baseY, t);
      final tickEnd = Offset(pos.dx, pos.dy + (i % 5 == 0 ? 12 : 6));
      canvas.drawLine(pos, tickEnd, tickPaint);
    }

    // ✅ Draw min and max text
    final textStyle = TextStyle(color: Colors.white, fontSize: 14);
    final textPainterMin = TextPainter(
      text: TextSpan(text: min.toStringAsFixed(2), style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainterMax = TextPainter(
      text: TextSpan(text: max.toStringAsFixed(6), style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final minOffset = Offset(startX - textPainterMin.width / 2, baseY + 26);
    final maxOffset = Offset(endX - textPainterMax.width / 2, baseY + 26);

    textPainterMin.paint(canvas, minOffset);
    textPainterMax.paint(canvas, maxOffset);

    // Thumb
    double t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final thumbOffset = _quadraticBezier(
      startX,
      baseY,
      controlPoint,
      endX,
      baseY,
      t,
    );

    // Draw image if provided
    if (image != null) {
      const double imageSize = 50;
      final imageOffset = Offset(
        thumbOffset.dx - imageSize * 0.5,
        thumbOffset.dy - imageSize * 0.5,
      );
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(imageOffset.dx, imageOffset.dy, imageSize, imageSize),
        Paint(),
      );
    }
  }

  Offset _quadraticBezier(
    double x0,
    double y0,
    Offset control,
    double x2,
    double y2,
    double t,
  ) {
    final x =
        pow(1 - t, 2) * x0 + 2 * (1 - t) * t * control.dx + pow(t, 2) * x2;
    final y =
        pow(1 - t, 2) * y0 + 2 * (1 - t) * t * control.dy + pow(t, 2) * y2;
    return Offset(x.toDouble(), y.toDouble());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
