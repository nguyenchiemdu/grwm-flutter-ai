import 'dart:io';

import 'package:flutter/material.dart';

class ImageDetectionCapture extends StatefulWidget {
  const ImageDetectionCapture(
      {required this.poseDetection,
      required this.sectionDetection,
      required this.imageSegment,
      required this.pickedImage,
      this.isDevMode = false,
      this.errorMessage,
      super.key});
  final bool isDevMode;
  final CustomPainter? poseDetection;
  final CustomPainter? imageSegment;
  final CustomPainter? sectionDetection;
  final File pickedImage;
  final String? errorMessage;
  @override
  State<ImageDetectionCapture> createState() => _ImageDetectionCaptureState();
}

class _ImageDetectionCaptureState extends State<ImageDetectionCapture> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.red,
      width: 370,
      height: 800,
      child: Stack(
        children: <Widget>[
          Visibility(
            visible: widget.isDevMode,
            child: CustomPaint(
              painter: widget.imageSegment,
              child: Image.file(
                widget.pickedImage,
                opacity: const AlwaysStoppedAnimation(0.0),
              ),
            ),
          ),
          Visibility(
            visible: widget.isDevMode,
            child: CustomPaint(
              painter: widget.poseDetection,
              child: Image.file(
                widget.pickedImage,
                opacity: const AlwaysStoppedAnimation(0.5),
              ),
            ),
          ),
          CustomPaint(
            painter: widget.sectionDetection,
            child: Image.file(
              widget.pickedImage,
              opacity: AlwaysStoppedAnimation(widget.isDevMode ? 0.5 : 0.7),
            ),
          ),
          if (widget.errorMessage != null)
            Positioned.fill(
                top: 50,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.errorMessage!,
                    style: const TextStyle(
                        color: Colors.black, backgroundColor: Colors.white),
                  ),
                ))
        ],
      ),
    );
  }
}

const loading = Text("Loading");
