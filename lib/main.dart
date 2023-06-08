import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grwm_flutter_ai/commons/app_assets.dart';
import 'package:grwm_flutter_ai/commons/app_colors.dart';
import 'package:grwm_flutter_ai/commons/app_strings.dart';
import 'package:grwm_flutter_ai/commons/model_const.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
import 'package:grwm_flutter_ai/widgets/material_color.dart';
// import 'package:grwm_flutter_ai/widgets/change_confidence.dart';
import 'package:grwm_flutter_ai/widgets/image_detection.dart';
import 'package:grwm_flutter_ai/widgets/switch_mode_button.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

// import 'widgets/range_slider_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
        primarySwatch: white,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MainBloC bloC;
  final ImagePicker _picker = ImagePicker();
  final ScreenshotController _screenshotController = ScreenshotController();
  void onPickImage() async {
    final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: ModelConst.maxWidth,
        maxHeight: ModelConst.maxHeight);
    final File file = File(xFile!.path);
    // setState(() {});
    bloC.pickedImage = file;
    try {
      await bloC.detectBody();
    } catch (e, s) {
      // debugPrint(e.toString());
      // debugPrintStack(stackTrace: s);
      // if (!mounted) return;
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Error'),
      //       content: Text('$e'),
      //       actions: <Widget>[
      //         TextButton(
      //           style: TextButton.styleFrom(
      //             textStyle: Theme.of(context).textTheme.labelLarge,
      //           ),
      //           child: const Text('Ok'),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //         TextButton(
      //           style: TextButton.styleFrom(
      //             textStyle: Theme.of(context).textTheme.labelLarge,
      //           ),
      //           child: const Text('Close'),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  void _onCapture() {
    _screenshotController.capture().then((data) async {
      await ImageGallerySaver.saveImage(data!, quality: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => MainBloC(),
        dispose: (context, bloc) => bloc.dispose,
        builder: (context, _) {
          bloC = context.read<MainBloC>();
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: StreamBuilder<bool>(
                          stream: bloC.devModeStream,
                          builder: (context, snapshot) {
                            bool isDevMode = snapshot.data ?? false;
                            return Text(
                              isDevMode
                                  ? AppStrings.devMode
                                  : AppStrings.demoMode,
                              style: const TextStyle(color: AppColors.white),
                            );
                          }),
                    ),
                    Expanded(
                      child: ImageDetection(
                        screenshotController: _screenshotController,
                      ),
                    ),
                    // const ChangeConfidenceWidget(),
                    // const RangeSliderWidget(),
                    SizedBox(
                      height: 100,
                      child: StreamBuilder<String>(
                        stream: bloC.errorStream,
                        builder: (context, snapshot) {
                          String errorMessage = snapshot.data ?? "";
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 34),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.red),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SwitchModeButton(),
                          Row(
                            children: [
                              IconButton(
                                icon: SvgPicture.asset(
                                  AppAssets.iconCapture,
                                  width: 24,
                                  height: 24,
                                ),
                                color: Colors.white,
                                onPressed: _onCapture,
                              ),
                              const Text(
                                AppStrings.capture,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: onPickImage,
              tooltip: 'Chooose the image',
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        });
  }
}
