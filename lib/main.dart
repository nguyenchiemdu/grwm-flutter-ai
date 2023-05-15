import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/image_segmentation.dart';
import 'package:image_picker/image_picker.dart';

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
  File? pickedFile;
  final ImagePicker _picker = ImagePicker();
  void onPickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    final File file = File(xFile!.path);
    pickedFile = file;
    setState(() {});
    imageSegmentation(pickedFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder<CustomPainter>(
                  stream: customPaintStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CustomPaint(
                        painter: snapshot.data!,
                        child: Container(
                          child: Image.file(
                            pickedFile!,
                            opacity: const AlwaysStoppedAnimation(.5),
                          ),
                        ),
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
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
  }
}
