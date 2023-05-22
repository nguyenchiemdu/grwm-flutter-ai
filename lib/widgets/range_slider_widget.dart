import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
import 'package:provider/provider.dart';

class RangeSliderWidget extends StatefulWidget {
  const RangeSliderWidget({super.key});

  @override
  State<RangeSliderWidget> createState() => _RangeSliderWidgetState();
}

class _RangeSliderWidgetState extends State<RangeSliderWidget> {
  double _value = 0.7;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _value,
      divisions: 10,
      min: 0,
      max: 1,
      onChanged: (newValue) {
        setState(() {
          _value = newValue;
        });
      },
      onChangeEnd: (newValue) {
        context.read<MainBloC>().changeConfidenceRange(newValue);
      },
    );
  }
}
