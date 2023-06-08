import 'package:flutter/material.dart';
import 'package:grwm_flutter_ai/main_bloc.dart';
import 'package:provider/provider.dart';

class SwitchModeButton extends StatefulWidget {
  const SwitchModeButton({super.key});

  @override
  State<SwitchModeButton> createState() => _SwitchModeButtonState();
}

class _SwitchModeButtonState extends State<SwitchModeButton> {
  bool isSwitched = false;

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
    context.read<MainBloC>().changeDevMode();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
        scale: 1.2,
        child: Switch(
          onChanged: toggleSwitch,
          value: isSwitched,
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey,
        ));
  }
}
