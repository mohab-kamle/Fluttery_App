import 'package:flutter/material.dart';

class SwitchMode extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  const SwitchMode({super.key,required this.isDarkMode,
    required this.onThemeChanged,});

  @override
  State<SwitchMode> createState() => _SwitchModeState();
}

class _SwitchModeState extends State<SwitchMode> {
  Icon switchModeIcon = const Icon(Icons.brightness_4);
  void switchMode(bool b){
    setState(() {
      if(b) {
        switchModeIcon = const Icon(Icons.brightness_3_sharp,color: Colors.white,);
      } else {
        switchModeIcon = const Icon(Icons.brightness_4);
      }
      widget.onThemeChanged(!widget.isDarkMode);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Switch(
            thumbIcon: WidgetStatePropertyAll(switchModeIcon),
            value: widget.isDarkMode,
            onChanged: (b) { 
              switchMode(b);
            },
          );
  }
}