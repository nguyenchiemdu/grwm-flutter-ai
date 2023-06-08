import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:grwm_flutter_ai/commons/app_strings.dart';
import 'package:grwm_flutter_ai/models/body_recog_state.dart';
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

import 'commons/model_const.dart';

class MainBloC {
  final ImageSegmentation _imageSegmentation = ImageSegmentation();
  final PoseDetection _poseDetectionServices = PoseDetection();
  final BehaviorSubject<double> _confidenceStreamController =
      BehaviorSubject<double>();
  final BehaviorSubject<bool> _devModeStreamController =
      BehaviorSubject<bool>();
  final StreamController<String> _errorStreamController =
      StreamController<String>();
  final StreamController<BodyRecogState> _bodyRecogStreamController =
      StreamController<BodyRecogState>();
  Stream<double> get confidenceStream => _confidenceStreamController.stream;
  Stream<bool> get devModeStream => _devModeStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;
  Stream<BodyRecogState> get bodyRecogStream =>
      _bodyRecogStreamController.stream;
  SegmentationMask? mask;
  late List<Pose> poses;
  late File pickedImage;
  late SectionDetection _sectionDetectionService;
  MainBloC() {
    _confidenceStreamController.add(ModelConst.confidenceParameter);
    _devModeStreamController.add(false);
  }
  Future detectBody() async {
    _bodyRecogStreamController.add(BodyRecogState(isLoading: true));
    _errorStreamController.add("");
    BodyRecogState bodyRecogState = BodyRecogState();
    try {
      bodyRecogState.imageSegment = await _segmentImage();
      bodyRecogState.poseDetection = await _poseDetection();
      bodyRecogState.sectionDetection = await _sectionDetection();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      _errorStreamController.add(e.toString());
    }
    _bodyRecogStreamController.add(bodyRecogState);
  }

  void changeConfidenceRange(double amount) {
    // double newValue = amount;
    // SegmentationPainter painter =
    //     _drawPainter(mask!, pickedImage, confidence: newValue);
    // _confidenceStreamController.add(newValue);
    // _sectionDetection();
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

  Future<CustomPainter?> _segmentImage() async {
    log("segmentImage");
    mask = await _imageSegmentation.imageSegmentation(pickedImage);
    double confidence = _confidenceStreamController.value;
    var painter = _drawPainter(mask!, pickedImage, confidence: confidence);
    return painter;
  }

  Future<CustomPainter?> _poseDetection() async {
    log("poseDetection");
    poses = await _poseDetectionServices.imagePoseDetection(pickedImage);
    final size = ImageSizeGetter.getSize(FileInput(pickedImage));
    // if poses emtpy that means model can not detect the pose
    if (poses.isEmpty) {
      throw AppStrings.cannotDetectThePoses;
    }
    final painter = PosePainter(
        poses,
        Size(size.width.toDouble(), size.height.toDouble()),
        size.needRotate
            ? InputImageRotation.rotation90deg
            : InputImageRotation.rotation0deg);
    return painter;
  }

  Future<CustomPainter?> _sectionDetection() async {
    log("sectionDetection");
    final size = ImageSizeGetter.getSize(FileInput(pickedImage));

    try {
      _sectionDetectionService = SectionDetection(
          mask: mask!,
          poses: poses,
          confidence: _confidenceStreamController.value,
          isRotated: size.needRotate);
      var sectionShoulder = _sectionDetectionService.shoulderDetection();
      var sectionHip = _sectionDetectionService.hipDetection();
      var sectionWaist = _sectionDetectionService.waistDetection();
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
      return sectionPainter;
    } catch (e) {
      // final SectionPainter sectionPainter = SectionPainter(
      //     [],
      //     Size(size.width.toDouble(), size.height.toDouble()),
      //     size.needRotate
      //         ? InputImageRotation.rotation90deg
      //         : InputImageRotation.rotation0deg);
      // _sectionDetectionPaintStreamController.add(sectionPainter);
      rethrow;
    }
  }

  void _bodyShapeDetection(Section a1, Section a2, Section a3) {
    if (a2 > a1 && a2 > a3) {
      debugPrint("Diamond");
    }
    if (ModelConst.rectangleBottomRatio < a1 / a2 &&
        a1 / a2 <= ModelConst.rectangleTopRatio &&
        ModelConst.rectangleBottomRatio < a2 / a3 &&
        a2 / a3 <= ModelConst.rectangleTopRatio &&
        ModelConst.rectangleBottomRatio < a1 / a3 &&
        a1 / a3 <= ModelConst.rectangleTopRatio) {
      debugPrint("Rectangle");
    }
    if (ModelConst.hourglassA1A3Bot < a1 / a3 &&
        a1 / a3 <= ModelConst.hourglassA1A3Top &&
        a2 / a3 <= ModelConst.hourglassA2A3Top) {
      debugPrint("Hourglass");
    }
    if (a3 / a1 > ModelConst.triangleRatio &&
        a2 / a3 < ModelConst.triangleRatio) {
      if (a1 / a2 > 1) {
        debugPrint("Triangle A");
      } else {
        debugPrint("Triangle B");
      }
    }
    if (a1 / a3 > ModelConst.triangleRatio &&
        a2 / a1 < ModelConst.triangleRatio) {
      if (a2 / a3 < ModelConst.triangleRatio) {
        debugPrint("Inverted triangle X");
      } else {
        debugPrint("Inverted triangle Y");
      }
    }
  }

  void dispose() {
    _confidenceStreamController.close();
    _devModeStreamController.close();
    _errorStreamController.close();
    _bodyRecogStreamController.close();
  }
}
