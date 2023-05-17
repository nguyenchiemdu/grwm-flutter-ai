import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/services/image_segmentation.dart';
import 'package:grwm_flutter_ai/services/pose_detection.dart';

class MainBloC {
  final ImageSegmentation _imageSegmentation = ImageSegmentation();
  final PoseDetection _poseDetection = PoseDetection();
  final StreamController<CustomPainter> _imageSegmentPaintStreamController =
      StreamController<CustomPainter>();
  final StreamController<CustomPainter> _poseDetectionPaintStreamController =
      StreamController<CustomPainter>();
  Stream<CustomPainter> get imageSegmentStream =>
      _imageSegmentPaintStreamController.stream;
  Stream<CustomPainter> get poseDetectionStream =>
      _poseDetectionPaintStreamController.stream;
  void segmentImage(File image) async {
    CustomPainter painter = await _imageSegmentation.imageSegmentation(image);
    _imageSegmentPaintStreamController.add(painter);
  }

  void poseDetection(File image) async {
    CustomPainter painter = await _poseDetection.imagePoseDetection(image);
    _poseDetectionPaintStreamController.add(painter);
  }

  void dispose() {
    _imageSegmentPaintStreamController.close();
    _poseDetectionPaintStreamController.close();
  }
}
