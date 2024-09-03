import 'package:flutter/material.dart';
import 'package:long_press_progress_button/long_press_progress_button.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: LongPressedProgressButton(
          color: Colors.blue,
          forwardDuration: const Duration(seconds: 2),
          reverseDuration: const Duration(seconds: 1),
          cooldownDuration: const Duration(minutes: 1),
          onComplited: () {
            print('Completed!');
          },
          onCanceled: () {
            print('Canceled!');
          },
          onChanged: (value) {
            print('Progress value: $value');
          },
          onCooldownPressed: () {
            print('Button pressed during cooldown!');
          },
          onNotHeldLongEnough: () {
            print('Button not held long enough!');
          },
          onReleasedWhenCompleted: () {
            print('Button released when completed!');
          },
        )),
      ),
    );
  }
}
