import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';

import 'package:provider/provider.dart';

class ImageDetection extends StatefulWidget {
  const ImageDetection({super.key});

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
    return Expanded(
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
                      opacity: const AlwaysStoppedAnimation(.5),
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
                      opacity: const AlwaysStoppedAnimation(.5),
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
