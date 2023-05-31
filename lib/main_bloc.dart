import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:grwm_flutter_ai/painters/pose_painter.dart';
import 'package:grwm_flutter_ai/painters/section_painter.dart';
import 'package:grwm_flutter_ai/services/image_segmentation.dart';
import 'package:grwm_flutter_ai/services/pose_detection.dart';
import 'package:grwm_flutter_ai/painters/segmentation_painter.dart';
import 'package:grwm_flutter_ai/services/sections_detection.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' hide Size;
import 'package:rxdart/subjects.dart';

class MainBloC {
  final ImageSegmentation _imageSegmentation = ImageSegmentation();
  final PoseDetection _poseDetection = PoseDetection();
  final StreamController<CustomPainter> _imageSegmentPaintStreamController =
      StreamController<CustomPainter>();
  final StreamController<CustomPainter> _poseDetectionPaintStreamController =
      StreamController<CustomPainter>();
  final StreamController<CustomPainter> _sectionDetectionPaintStreamController =
      StreamController<CustomPainter>();
  final BehaviorSubject<double> _confidenceStreamController =
      BehaviorSubject<double>();
  final BehaviorSubject<bool> _devModeStreamController =
      BehaviorSubject<bool>();
  Stream<CustomPainter> get imageSegmentStream =>
      _imageSegmentPaintStreamController.stream;
  Stream<CustomPainter> get poseDetectionStream =>
      _poseDetectionPaintStreamController.stream;
  Stream<CustomPainter> get sectionDetectionStream =>
      _sectionDetectionPaintStreamController.stream;
  Stream<double> get confidenceStream => _confidenceStreamController.stream;
  Stream<bool> get devModeStream => _devModeStreamController.stream;
  SegmentationMask? mask;
  late List<Pose> poses;
  late File pickedImage;
  late SectionDetection _sectionDetection;
  MainBloC() {
    _confidenceStreamController.add(0.7);
    _devModeStreamController.add(false);
  }
  Future detectBody() async {
    await segmentImage();
    await poseDetection();
    await sectionDetection();
  }

  Future segmentImage() async {
    mask = await _imageSegmentation.imageSegmentation(pickedImage);
    double confidence = _confidenceStreamController.value;
    var painter = _drawPainter(mask!, pickedImage, confidence: confidence);
    _imageSegmentPaintStreamController.add(painter);
  }

  void changeConfidenceRange(double amount) {
    double newValue = amount;
    SegmentationPainter painter =
        _drawPainter(mask!, pickedImage, confidence: newValue);
    _confidenceStreamController.add(newValue);
    _imageSegmentPaintStreamController.add(painter);
    sectionDetection();
  }

  void changeDevMode() {
    bool devMode = _devModeStreamController.value;
    _devModeStreamController.add(!devMode);
  }

  SegmentationPainter _drawPainter(SegmentationMask mask, File image,
      {required double confidence}) {
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

  Future poseDetection() async {
    poses = await _poseDetection.imagePoseDetection(pickedImage);
    final size = ImageSizeGetter.getSize(FileInput(pickedImage));
    final painter = PosePainter(
        poses,
        Size(size.width.toDouble(), size.height.toDouble()),
        size.needRotate
            ? InputImageRotation.rotation90deg
            : InputImageRotation.rotation0deg);
    _poseDetectionPaintStreamController.add(painter);
  }

  Future sectionDetection() async {
    final size = ImageSizeGetter.getSize(FileInput(pickedImage));

    try {
      _sectionDetection = SectionDetection(
          mask: mask!,
          poses: poses,
          confidence: _confidenceStreamController.value);
      var sectionShoulder = _sectionDetection.shoulderDetection();
      var sectionHip = _sectionDetection.hipDetection();
      var sectionWaist = _sectionDetection.waistDetection();

      var listWaitsPoints = [];
      for (var section in sectionWaist) {
        listWaitsPoints.add(section.start);
        listWaitsPoints.add(section.end);
      }
      final SectionPainter sectionPainter = SectionPainter(
          [
            sectionShoulder.start,
            sectionShoulder.end,
            sectionHip.start,
            sectionHip.end,
            ...listWaitsPoints
          ],
          Size(size.width.toDouble(), size.height.toDouble()),
          size.needRotate
              ? InputImageRotation.rotation90deg
              : InputImageRotation.rotation0deg);
      _sectionDetectionPaintStreamController.add(sectionPainter);
    } catch (e) {
      final SectionPainter sectionPainter = SectionPainter(
          [],
          Size(size.width.toDouble(), size.height.toDouble()),
          size.needRotate
              ? InputImageRotation.rotation90deg
              : InputImageRotation.rotation0deg);
      _sectionDetectionPaintStreamController.add(sectionPainter);
      rethrow;
    }
  }

  void dispose() {
    _imageSegmentPaintStreamController.close();
    _poseDetectionPaintStreamController.close();
    _confidenceStreamController.close();
    _sectionDetectionPaintStreamController.close();
    _devModeStreamController.close();
  }
}
