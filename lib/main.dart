import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
// import 'package:grwm_flutter_ai/widgets/change_confidence.dart';
import 'package:grwm_flutter_ai/widgets/image_detection.dart';
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
        primarySwatch: Colors.blue,
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
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    final File file = File(xFile!.path);
    setState(() {});
    bloC.pickedImage = file;
    try {
      await bloC.detectBody();
    } catch (e) {
      // print(e);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('$e'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
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
                    Expanded(
                      child: ImageDetection(
                        screenshotController: _screenshotController,
                      ),
                    ),
                    // const ChangeConfidenceWidget(),
                    // const RangeSliderWidget(),
                    SizedBox(
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              child: StreamBuilder<bool>(
                                  stream: bloC.devModeStream,
                                  builder: (context, snapshot) {
                                    return Text(snapshot.data ?? false
                                        ? 'Dev mode'
                                        : 'Demo mode');
                                  }),
                              onPressed: () {
                                // _screenshotController.capture().then((data) async {
                                //   await ImageGallerySaver.saveImage(data!,
                                //       quality: 60, name: "hello");
                                // });
                                bloC.changeDevMode();
                              },
                            ),
                            ElevatedButton(
                              child: const Text('Capture'),
                              onPressed: () {
                                _screenshotController
                                    .capture()
                                    .then((data) async {
                                  await ImageGallerySaver.saveImage(data!,
                                      quality: 60, name: "hello");
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: onPickImage,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          );
        });
  }
}
