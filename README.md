# Long Press Progress Button

A Flutter widget that requires a long press to complete an action. This button displays a circular progress indicator that fills up as the user holds down the button. If the user releases the button before the progress is complete, the action is canceled. If the user holds the button long enough, the action is completed and the button enters a cooldown period.

## Features

- Customizable color, durations, and callbacks.
- Circular progress indicator.
- Cooldown period after the action is completed.
- Callbacks for various states: completed, canceled, cooldown pressed, not held long enough, and released when completed.

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  long_press_progress_button:
      git:
        url: https://github.com/pavluke/long_press_progress_button.git
        ref: main
```

Then, run `flutter pub get` to install the package.

## Usage

Import the package in your Dart file:

```dart
import 'package:long_press_progress_button/long_press_progress_button.dart';
```
Use the `LongPressedProgressButton` widget in your Flutter app:

```dart
LongPressedProgressButton(
  color: Colors.blue,
  forwardDuration: Duration(seconds: 2),
  reverseDuration: Duration(seconds: 1),
  cooldownDuration: Duration(minutes: 1),
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
)
```