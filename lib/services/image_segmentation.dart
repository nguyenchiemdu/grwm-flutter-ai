import 'dart:async';
import 'dart:io';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

class ImageSegmentation {
  Future<SegmentationMask?> imageSegmentation(File file) async {
    final InputImage inputImage = InputImage.fromFile(file);

    final segmenter = SelfieSegmenter(
      mode: SegmenterMode.stream,
    );
    var mask = await segmenter.processImage(inputImage);
    segmenter.close();

    return mask;
  }
}
