import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:grwm_flutter_ai/models/section.dart';
import 'package:grwm_flutter_ai/painters/pose_painter.dart';
import 'package:grwm_flutter_ai/painters/section_painter.dart';
import 'package:grwm_flutter_ai/services/image_segmentation.dart';
import 'package:grwm_flutter_ai/services/pose_detection.dart';
import 'package:grwm_flutter_ai/painters/segmentation_painter.dart';
import 'package:grwm_flutter_ai/services/sections_detection.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' hide Size;
import 'package:rxdart/subjects.dart';

import 'commons/app_const.dart';

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
    _confidenceStreamController.add(AppConst.confidenceParameter);
    _devModeStreamController.add(false);
  }
  Future detectBody() async {
    await segmentImage();
    await poseDetection();
    await sectionDetection();
  }

  Future segmentImage() async {
    log("segmentImage");
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
    log("poseDetection");

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
    log("sectionDetection");
    final size = ImageSizeGetter.getSize(FileInput(pickedImage));

    try {
      _sectionDetection = SectionDetection(
          mask: mask!,
          poses: poses,
          confidence: _confidenceStreamController.value,
          isRotated: size.needRotate);
      var sectionShoulder = _sectionDetection.shoulderDetection();
      var sectionHip = _sectionDetection.hipDetection();
      var sectionWaist = _sectionDetection.waistDetection();
      _bodyShapeDetection(sectionShoulder, sectionWaist.first, sectionHip);
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

  void _bodyShapeDetection(Section a1, Section a2, Section a3) {
    if (a2 > a1 && a2 > a3) {
      debugPrint("Diamond");
    }
    if (AppConst.rectangleBottomRatio < a1 / a2 &&
        a1 / a2 <= AppConst.rectangleTopRatio &&
        AppConst.rectangleBottomRatio < a2 / a3 &&
        a2 / a3 <= AppConst.rectangleTopRatio &&
        AppConst.rectangleBottomRatio < a1 / a3 &&
        a1 / a3 <= AppConst.rectangleTopRatio) {
      debugPrint("Rectangle");
    }
    if (AppConst.hourglassA1A3Bot < a1 / a3 &&
        a1 / a3 <= AppConst.hourglassA1A3Top &&
        a2 / a3 <= AppConst.hourglassA2A3Top) {
      debugPrint("Hourglass");
    }
    if (a3 / a1 > AppConst.triangleRatio && a2 / a3 < AppConst.triangleRatio) {
      if (a1 / a2 > 1) {
        debugPrint("Triangle A");
      } else {
        debugPrint("Triangle B");
      }
    }
    if (a1 / a3 > AppConst.triangleRatio && a2 / a1 < AppConst.triangleRatio) {
      if (a2 / a3 < AppConst.triangleRatio) {
        debugPrint("Inverted triangle X");
      } else {
        debugPrint("Inverted triangle Y");
      }
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
