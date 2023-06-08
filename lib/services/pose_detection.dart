import 'dart:io';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetection {
  Future<List<Pose>> imagePoseDetection(File file) async {
    final InputImage inputImage = InputImage.fromFile(file);
    final PoseDetector poseDetector =
        PoseDetector(options: PoseDetectorOptions());
    final poses = await poseDetector.processImage(inputImage);
    poseDetector.close();
    return poses;
  }
}
