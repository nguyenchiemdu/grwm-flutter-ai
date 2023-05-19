import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:grwm_flutter_ai/services/image_segmentation.dart';
import 'package:grwm_flutter_ai/services/pose_detection.dart';
import 'package:grwm_flutter_ai/painters/segmentation_painter.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' hide Size;

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

  SegmentationMask? mask;
  late File pickedImage;
  late double confidence;
  void segmentImage() async {
    mask = await _imageSegmentation.imageSegmentation(pickedImage);
    var painter = _drawPainter(mask!, pickedImage);
    _imageSegmentPaintStreamController.add(painter);
  }

  void onConfidenceChanged(double value) {
    confidence = value;
  }

  void changeConfidenceRange() {
    if (confidence > 1 || confidence < 0) {
      confidence = 0;
    }
    var painter = _drawPainter(mask!, pickedImage, confidence: confidence);
    _imageSegmentPaintStreamController.add(painter);
  }

  SegmentationPainter _drawPainter(SegmentationMask mask, File image,
      {double confidence = 0.7}) {
    final size = ImageSizeGetter.getSize(FileInput(image));
    final painter = SegmentationPainter(
        mask,
        Size(size.width.toDouble(), size.height.toDouble()),
        size.needRotate
            ? InputImageRotation.rotation90deg
            : InputImageRotation.rotation0deg,
        confidenceRange: confidence);
    return painter;
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
