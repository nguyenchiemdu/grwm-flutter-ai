import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.absoluteImageSize, this.rotation);

  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final List<PoseLandmarkType> pointLandmarksFilters = [
    PoseLandmarkType.leftFootIndex,
    PoseLandmarkType.rightFootIndex,
    PoseLandmarkType.rightAnkle,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.leftHeel,
    PoseLandmarkType.rightHeel,
  ];
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        if (pointLandmarksFilters.contains(landmark.type)) {
          return;
        }
        final tx = translateX(landmark.x, rotation, size, absoluteImageSize);
        final ty = translateY(landmark.y, rotation, size, absoluteImageSize);
        canvas.drawCircle(
            getOffset(
              tx,
              ty,
            ),
            1,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        final tx = getOffset(
            translateX(joint1.x, rotation, size, absoluteImageSize),
            translateY(joint1.y, rotation, size, absoluteImageSize));
        final ty = getOffset(
            translateX(joint2.x, rotation, size, absoluteImageSize),
            translateY(joint2.y, rotation, size, absoluteImageSize));
        canvas.drawLine(tx, ty, paintType);
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      // //Draw legs
      // paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      // paintLine(
      //     PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      // paintLine(
      //     PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      // paintLine(
      //     PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
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
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
