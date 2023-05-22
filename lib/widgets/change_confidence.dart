import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
import 'package:provider/provider.dart';

class ChangeConfidenceWidget extends StatefulWidget {
  const ChangeConfidenceWidget({super.key});

  @override
  State<ChangeConfidenceWidget> createState() => _ChangeConfidenceWidgetState();
}

class _ChangeConfidenceWidgetState extends State<ChangeConfidenceWidget> {
  @override
  Widget build(BuildContext context) {
    final bloC = context.read<MainBloC>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ElevatedButton(
        //     onPressed: () {
        //       bloC.changeConfidenceRange(-0.1);
        //     },
        //     child: const Text("-")),
        StreamBuilder<double>(
            stream: bloC.confidenceStream,
            builder: (_, snapshot) {
              double? confidence = snapshot.data;
              return Text("$confidence");
            }),
        // ElevatedButton(
        //     onPressed: () {
        //       bloC.changeConfidenceRange(0.1);
        //     },
        //     child: const Text("+"))
      ],
    );
  }
}
