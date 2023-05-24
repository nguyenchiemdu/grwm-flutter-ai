import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';

import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class ImageDetection extends StatefulWidget {
  const ImageDetection({required this.screenshotController, super.key});
  final ScreenshotController screenshotController;
  @override
  State<ImageDetection> createState() => _ImageDetectionState();
}

class _ImageDetectionState extends State<ImageDetection> {
  late MainBloC bloC;

  @override
  void initState() {
    bloC = context.read<MainBloC>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: widget.screenshotController,
      child: Stack(
        children: <Widget>[
          StreamBuilder<CustomPainter>(
              stream: bloC.imageSegmentStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomPaint(
                    painter: snapshot.data!,
                    child: Image.file(
                      bloC.pickedImage,
                      opacity: const AlwaysStoppedAnimation(0.0),
                    ),
                  );
                }
                return const Text("Loading");
              }),
          StreamBuilder<CustomPainter>(
              stream: bloC.poseDetectionStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomPaint(
                    painter: snapshot.data!,
                    child: Image.file(
                      bloC.pickedImage,
                      opacity: const AlwaysStoppedAnimation(0.5),
                    ),
                  );
                }
                return const Text("Loading");
              }),
          StreamBuilder<CustomPainter>(
              stream: bloC.sectionDetectionStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CustomPaint(
                    painter: snapshot.data!,
                    child: Image.file(
                      bloC.pickedImage,
                      opacity: const AlwaysStoppedAnimation(0.5),
                    ),
                  );
                }
                return const Text("Loading");
              }),
        ],
      ),
    );
  }
}
