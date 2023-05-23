import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import '../commons/algebra_helper.dart';

class SectionDetection {
  final SegmentationMask mask;
  final List<Pose> poses;
  final double confidence;
  SectionDetection(
      {required this.mask, required this.poses, this.confidence = 0.7});
  
  Section shoulderDetection() {
    Section section;
    Pose pose = poses.first;
    PoseLandmark leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    PoseLandmark rightShoulder =
        pose.landmarks[PoseLandmarkType.rightShoulder]!;
    Point left = Point(leftShoulder.x.toInt(), leftShoulder.y.toInt());
    Point right = Point(rightShoulder.x.toInt(), rightShoulder.y.toInt());

    final shoulderSlope = AlgebraHelper.findSlope(left, right);
    section = AlgebraHelper.breadthPoint(shoulderSlope, left, AlgebraHelper.to2Darray(mask, mask.confidences));

    return section;
  }

  Section hipDetection() {
    Section section;
    Pose pose = poses.first;
    PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
    PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;

    Point left = Point(leftHip.x.toInt(), leftHip.y.toInt());
    Point right = Point(rightHip.x.toInt(), rightHip.y.toInt());

    final hipSlope = AlgebraHelper.findSlope(left, right);
    section = AlgebraHelper.breadthPoint(hipSlope, left, AlgebraHelper.to2Darray(mask, mask.confidences));

    return section;
  }

  Section waistDetection() {
    Section section;
    Pose pose = poses.first;

    PoseLandmark leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    PoseLandmark rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
    PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
    PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;

    Point leftS = Point(leftShoulder.x.toInt(), leftShoulder.y.toInt());
    Point rightS = Point(rightShoulder.x.toInt(), rightShoulder.y.toInt());
    Point leftH = Point(leftHip.x.toInt(), leftHip.y.toInt());
    Point rightH = Point(rightHip.x.toInt(), rightHip.y.toInt());

    
    Point intersection = AlgebraHelper.findDiagonalIntersection(leftS, rightH, rightS, leftH);
    // final waistSlope = AlgebraHelper.findSlope(leftH, rightH);
    double shoulderSlope = AlgebraHelper.findSlope(leftS, rightS);
    double hipSlope = AlgebraHelper.findSlope(leftH, rightH);

    var shoulderAlpha = acos(sqrt(1 / (1 + shoulderSlope * shoulderSlope)));
    var hipAlpha = acos(sqrt(1 / (1 + hipSlope * hipSlope))); 
    var waistAlpha = (shoulderAlpha + hipAlpha) / 2; // average of two angles

    final waistSlope = sqrt((1 / (cos(waistAlpha) * cos(waistAlpha))) - 1); // corresponding slope with the waist angle
    section = AlgebraHelper.breadthPoint(waistSlope, intersection, AlgebraHelper.to2Darray(mask, mask.confidences));

    return section;
  }

}

class Point {
  int x, y;
  Point(this.x, this.y);
  @override
  String toString() {
    return "{$x, $y}";
  }
}

class Section {
  Point start;
  Point end;
  Section(this.start, this.end);
}
