import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:grwm_flutter_ai/models/point.dart';

import 'coordinates_translator.dart';

class SectionPainter extends CustomPainter {
  SectionPainter(this.points, this.absoluteImageSize, this.rotation);

  final List<Point> points;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.purple;

    for (final point in points) {
      final tx =
          translateX(point.x.toDouble(), rotation, size, absoluteImageSize);
      final ty =
          translateY(point.y.toDouble(), rotation, size, absoluteImageSize);
      canvas.drawCircle(
          getOffset(
            tx,
            ty,
          ),
          1,
          paint);
    }
  }

  Offset getOffset(double dx, double dy) {
    if (rotation == InputImageRotation.rotation90deg) {
      return Offset(dy, dx);
    } else {
      return Offset(dx, dy);
    }
  }

  @override
  bool shouldRepaint(covariant SectionPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.points != points;
  }
}
