import 'package:flutter/material.dart';

class BodyRecogState {
  late bool isLoading;

  CustomPainter? imageSegment;
  CustomPainter? poseDetection;
  CustomPainter? sectionDetection;
  BodyRecogState({this.isLoading = false});
}
