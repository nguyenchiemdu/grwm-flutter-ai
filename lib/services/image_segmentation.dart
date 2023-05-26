import 'dart:async';
import 'dart:io';
// import 'dart:math';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

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

// Future<File> createFileFromUrl(String imageUrl) async {
//   // Get the temporary directory of the device.
//   Directory tempDir = await getTemporaryDirectory();

//   // Create a new file in the temporary directory with a random file name.
//   String tempPath = "${tempDir.path}${Random().nextInt(100)}.jpg";
//   File file = File(tempPath);

//   // Call the `http.get` method and pass the image URL into it to get the response.
//   final Uri uri = Uri.parse(imageUrl);
//   http.Response response = await http.get(uri);

//   // Write the bodyBytes received in the response to the file.
//   await file.writeAsBytes(response.bodyBytes);

//   // Return the file.
//   return file;
// }
