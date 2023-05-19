import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  File? pickedFile;
  final ImagePicker _picker = ImagePicker();
  void onPickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    final File file = File(xFile!.path);
    pickedFile = file;
    setState(() {});
    bloC.pickedImage = pickedFile!;
    bloC.segmentImage();
    bloC.poseDetection(pickedFile!);
  }

  @override
  Widget build(BuildContext context) {
    print('build');
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
                    Flexible(
                      child: Stack(
                        children: <Widget>[
                          StreamBuilder<CustomPainter>(
                              stream: bloC.imageSegmentStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CustomPaint(
                                    painter: snapshot.data!,
                                    child: Image.file(
                                      pickedFile!,
                                      opacity: const AlwaysStoppedAnimation(.5),
                                    ),
                                  );
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              }),
                          StreamBuilder<CustomPainter>(
                              stream: bloC.poseDetectionStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CustomPaint(
                                    painter: snapshot.data!,
                                    child: Image.file(
                                      pickedFile!,
                                      opacity: const AlwaysStoppedAnimation(.5),
                                    ),
                                  );
                                }
                                return const CircularProgressIndicator();
                              }),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              bloC.changeConfidenceRange();
                            },
                            child: const Text("Change confidence")),
                        Expanded(
                            child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (double.tryParse(value) != null) {
                              bloC.onConfidenceChanged(double.parse(value));
                            }
                          },
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 100,
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
