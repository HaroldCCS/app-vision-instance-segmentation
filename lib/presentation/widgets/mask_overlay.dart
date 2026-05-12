import 'package:flutter/material.dart';
import '../../domain/models/polygon_mask.dart';

class MaskPainter extends CustomPainter {
  final List<PolygonMask> masks;

  MaskPainter(this.masks);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var mask in masks) {
      if (mask.points.isEmpty) continue;

      Path path = Path();
      path.moveTo(mask.points[0].dx, mask.points[0].dy);
      for (int i = 1; i < mask.points.length; i++) {
        path.lineTo(mask.points[i].dx, mask.points[i].dy);
      }
      path.close();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
