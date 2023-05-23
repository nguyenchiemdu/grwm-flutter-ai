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
    //section = Section(left, right);
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
