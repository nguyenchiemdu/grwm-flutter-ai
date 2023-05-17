import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:grwm_flutter_ai/painters/pose_painter.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' hide Size;

class PoseDetection {
  Future<PosePainter> imagePoseDetection(File file) async {
    final InputImage inputImage = InputImage.fromFile(file);

    final PoseDetector poseDetector =
        PoseDetector(options: PoseDetectorOptions());
    final poses = await poseDetector.processImage(inputImage);

    final size = ImageSizeGetter.getSize(FileInput(file));
    final painter = PosePainter(
        poses,
        Size(size.width.toDouble(), size.height.toDouble()),
        size.needRotate
            ? InputImageRotation.rotation90deg
            : InputImageRotation.rotation0deg);
    poseDetector.close();
    return painter;
  }
}
