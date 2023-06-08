import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/commons/app_colors.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
import 'package:grwm_flutter_ai/models/body_recog_state.dart';

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
      child: StreamBuilder<bool>(
          stream: bloC.devModeStream,
          builder: (context, snapshot) {
            bool isDevMode = snapshot.data ?? false;
            return StreamBuilder<BodyRecogState>(
                stream: bloC.bodyRecogStream,
                builder: (context, snapshot) {
                  BodyRecogState? bodyRecogState = snapshot.data;
                  if (bodyRecogState != null) {
                    if (bodyRecogState.isLoading) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 23),
                        decoration: BoxDecoration(
                          color: AppColors.gray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: const Center(
                          widthFactor: 57,
                          heightFactor: 57,
                          child: CircularProgressIndicator(
                            color: AppColors.black,
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 23),
                      decoration: BoxDecoration(
                        color: AppColors.gray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: <Widget>[
                            Visibility(
                              visible: isDevMode,
                              child: CustomPaint(
                                key: GlobalKey(),
                                painter: bodyRecogState.imageSegment,
                                child: Image.file(
                                  bloC.pickedImage,
                                  opacity: const AlwaysStoppedAnimation(0.0),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isDevMode,
                              child: CustomPaint(
                                painter: bodyRecogState.poseDetection,
                                child: Image.file(
                                  bloC.pickedImage,
                                  opacity: const AlwaysStoppedAnimation(0.5),
                                ),
                              ),
                            ),
                            CustomPaint(
                              painter: bodyRecogState.sectionDetection,
                              child: Image.file(
                                bloC.pickedImage,
                                opacity: AlwaysStoppedAnimation(
                                    isDevMode ? 0.5 : 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Image.asset("assets/images/guide.png");
                });
          }),
    );
  }
}
