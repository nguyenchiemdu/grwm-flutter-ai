import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:grwm_flutter_ai/commons/app_const.dart';
import 'package:grwm_flutter_ai/models/point.dart';
import 'package:grwm_flutter_ai/models/section.dart';

import '../commons/algebra_helper.dart';

class SectionDetection {
  final SegmentationMask mask;
  final List<Pose> poses;
  final double confidence;
  final bool isRotated;
  SectionDetection(
      {required this.mask,
      required this.poses,
      required this.confidence,
      this.isRotated = false});

  Section shoulderDetection() {
    Section section;
    Pose pose = poses.first;
    PoseLandmark leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    PoseLandmark rightShoulder =
        pose.landmarks[PoseLandmarkType.rightShoulder]!;
    Point left = Point(leftShoulder.x.toInt(), leftShoulder.y.toInt());
    Point right = Point(rightShoulder.x.toInt(), rightShoulder.y.toInt());
    // swap the left and right if image is rotated
    if (isRotated) {
      var tmp = left;
      left = right;
      right = tmp;
    }
    final shoulderSlope = AlgebraHelper.findSlope(left, right);
    section = AlgebraHelper.breadthPoint(
        shoulderSlope, left, right, AlgebraHelper.to2Darray(mask),
        confidence: confidence);

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
    section = AlgebraHelper.breadthPoint(
        hipSlope, left, right, AlgebraHelper.to2Darray(mask),
        confidence: confidence);

    return section;
  }

  List<Section> waistDetection() {
    Section section;
    Pose pose = poses.first;

    PoseLandmark leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    PoseLandmark rightShoulder =
        pose.landmarks[PoseLandmarkType.rightShoulder]!;
    PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
    PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;

    Point leftS = Point(leftShoulder.x.toInt(), leftShoulder.y.toInt());
    Point rightS = Point(rightShoulder.x.toInt(), rightShoulder.y.toInt());
    Point leftH = Point(leftHip.x.toInt(), leftHip.y.toInt());
    Point rightH = Point(rightHip.x.toInt(), rightHip.y.toInt());

    Point intersection =
        AlgebraHelper.findDiagonalIntersection(leftS, rightH, rightS, leftH);
    var hipSlope = AlgebraHelper.findSlope(leftH, rightH);
    // find the expand distance to move the intersection vertically

    var listParams = AlgebraHelper.linearEquation(hipSlope, leftH);
    double A = listParams[0];
    double B = listParams[1];
    double C = listParams[2];
    double distanceA1A3 = AlgebraHelper.distancePointToLine(leftS, A, B, C);
    int expandDistance =
        (distanceA1A3 * AppConst.midsectionExpandPercent ~/ 2).toInt();

    final waistSlope = hipSlope;
    List<Section> sections = [];
    var midPoint = intersection;
    var jumpStep = expandDistance ~/ 5;
    for (int i = jumpStep; i < expandDistance; i += jumpStep) {
      midPoint = AlgebraHelper.pointUp(A, B, C, jumpStep, midPoint);
      section = AlgebraHelper.waistBreadthPoint(
          waistSlope, midPoint, AlgebraHelper.to2Darray(mask),
          confidence: confidence);
      if (sections.isNotEmpty && !_shouldExpand(sections.last, section)) {
        break;
      }
      if (!_isEqualDistance(section)) {
        break;
      }
      sections.add(section);
    }

    // for (section in sections) {
    //   print(section.getDistanceToMid());
    // }
    midPoint = intersection;
    for (int i = jumpStep; i < expandDistance; i += jumpStep) {
      midPoint = AlgebraHelper.pointDown(A, B, C, jumpStep, midPoint);
      section = AlgebraHelper.waistBreadthPoint(
          waistSlope, midPoint, AlgebraHelper.to2Darray(mask),
          confidence: confidence);
      if (sections.isNotEmpty && !_shouldExpand(sections.last, section)) {
        break;
      }
      if (!_isEqualDistance(section)) {
        break;
      }
      sections.add(section);
    }
    debugPrint('${sections.length}');
    if (sections.length >= AppConst.midsectionMinNoOfLines) {
      // sections is all the founded sections in the waist area
      // find out the actual mid section
      Section maxSection = sections.first;
      Section minSection = sections.first;
      for (var section in sections) {
        if (maxSection.length < section.length) {
          maxSection = section;
        }
        if (minSection.length > section.length) {
          minSection = section;
        }
      }
      if (maxSection == sections.first || maxSection == sections.last) {
        return [minSection];
      }
      return [maxSection];
      // return sections;
    } else {
      throw ('Cannot detect midsection. Please take another photo following the instructions.');
    }
  }

  bool _shouldExpand(Section oldSection, Section newSection) {
    var leftRatio = _getRatio(oldSection.getMiddleDistanceToLeft(),
        newSection.getMiddleDistanceToLeft());
    var rightRatio = _getRatio(oldSection.getMiddleDistanceToRight(),
        newSection.getMiddleDistanceToRight());
    if (leftRatio > AppConst.midsectionExpandRatio ||
        rightRatio > AppConst.midsectionExpandRatio) {
      return false;
    }
    return true;
  }

  bool _isEqualDistance(Section section) {
    var leftDist = section.getMiddleDistanceToLeft();
    var rightDist = section.getMiddleDistanceToRight();

    var ratio = leftDist / rightDist;
    if (rightDist < leftDist) ratio = rightDist / leftDist;
    if (ratio < AppConst.midsectionDeltaRatio) return false;
    return true;
  }

  double _getRatio(double a, double b) {
    if (a > b) return a / b;
    return b / a;
  }
}
