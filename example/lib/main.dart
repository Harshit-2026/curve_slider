import 'package:curve_slider/curve_slider_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Curve Slider',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CurveSliderView(
          initialValue: 0.002,
          min: 0.001,
          max: 0.005,
          curvature: 120,
          totalTicks: 40,
          thumbImage: 'assets/images/fingerprint.png',
          tickSound: 'sounds/tick.mp3',
          onChanged: (value) {
            debugPrint("on change: $value");
          },
        ),
      ),
    );
  }
}
