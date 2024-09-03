part of '../long_press_progress_button.dart';

enum _ButtonState { released, pressed }

/// A custom button that requires a long press to complete an action.
///
/// This button displays a circular progress indicator that fills up as the user holds down the button.
/// If the user releases the button before the progress is complete, the action is canceled.
/// If the user holds the button long enough, the action is completed and the button enters a cooldown period.
class LongPressedProgressButton extends StatefulWidget {
  const LongPressedProgressButton({
    super.key,
    this.color = Colors.green,
    this.forwardDuration = const Duration(milliseconds: 500),
    this.reverseDuration = const Duration(milliseconds: 250),
    this.cooldownDuration = const Duration(minutes: 1),
    this.onComplited,
    this.onCanceled,
    this.onChanged,
    this.onCooldownPressed,
    this.onNotHeldLongEnough,
    this.onReleasedWhenCompleted,
  });

  /// The color of the button.
  final Color color;

  /// The duration for the forward animation of the progress indicator.
  final Duration forwardDuration;

  /// The duration for the reverse animation of the progress indicator.
  final Duration reverseDuration;

  /// The duration for the cooldown period after the action is completed.
  final Duration cooldownDuration;

  /// Callback called when the action is completed.
  final void Function()? onComplited;

  /// Callback called when the action is canceled.
  final void Function()? onCanceled;

  /// Callback called when the progress value changes.
  final ValueChanged<double>? onChanged;

  /// Callback called when the button is pressed during the cooldown period.
  final void Function()? onCooldownPressed;

  /// Callback called when the button is not held long enough to complete the action.
  final void Function()? onNotHeldLongEnough;

  /// Callback called when the button is released after the progress indicator is completed.
  final void Function()? onReleasedWhenCompleted;

  @override
  State<LongPressedProgressButton> createState() =>
      _LongPressedProgressButtonState();
}

class _LongPressedProgressButtonState extends State<LongPressedProgressButton>
    with TickerProviderStateMixin {
  late AnimationController progressController;
  late AnimationController animationController;
  late CurvedAnimation animation;
  late double progress;
  late _ButtonState buttonState;
  final StreamController<double> progressValue = StreamController<double>();

  @override
  initState() {
    super.initState();
    progress = 0;
    buttonState = _ButtonState.released;
    progressController = AnimationController(
        vsync: this,
        duration: widget.forwardDuration,
        reverseDuration: widget.reverseDuration);
    progressController.addListener(() async {
      final value = progressController.value;
      if (!progressValue.isClosed) {
        setState(() => progressValue.sink.add(value));
        widget.onChanged?.call(double.parse(value.toStringAsFixed(3)));
      }
    });

    animationController = AnimationController(
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    animationController.addListener(() {
      setState(() {});
    });

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() async {
    animationController.removeListener(() {});
    progressController.removeListener(() {});
    await progressValue.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hold(),
      onTapUp: (TapUpDetails details) {
        _onComplited(context);
      },
      onTapCancel: () => _onCanceled(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeAlign: 4,
            strokeWidth: 25,
            backgroundColor: Colors.transparent,
            value: progressController.value,
            valueColor: AlwaysStoppedAnimation(
                buttonState == _ButtonState.pressed
                    ? widget.color
                    : widget.color.withOpacity(0.5)),
          ),
          StreamBuilder(
            stream: progressValue.stream,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              final progressValue = snapshot.data;
              if (progressValue == 0 && buttonState == _ButtonState.pressed) {
                buttonState = _ButtonState.released;
              }

              return ScaleTransition(
                scale: animation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: buttonState == _ButtonState.released
                          ? widget.color
                          : const Color(0xFF222222),
                      border: Border.all(
                          width: 10, color: Colors.black.withOpacity(0.5))),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _hold() {
    animationController.forward();
    if (progressController.status != AnimationStatus.completed) {
      if (buttonState == _ButtonState.released) {
        progressController.reverseDuration = widget.reverseDuration;
        progressController.forward();
      } else {
        Duration time = Duration(
            seconds: int.parse(
                (60 * progressController.value).toString().split('.').first));
        if (time != Duration.zero) {
          widget.onCooldownPressed?.call();
        }
      }
    }
  }

  void _onComplited(BuildContext context) {
    animationController.reverse();
    if (progressController.status == AnimationStatus.forward) {
      progressController.reverseDuration = widget.reverseDuration;
      progressController.reverse();
      widget.onNotHeldLongEnough?.call();
    } else if (progressController.status == AnimationStatus.completed) {
      setState(() => buttonState = _ButtonState.pressed);
      progressController.reverseDuration = widget.cooldownDuration;
      progressController.reverse();
      widget.onComplited?.call();
    } else if (progressController.status == AnimationStatus.dismissed) {
      setState(() => buttonState == _ButtonState.pressed
          ? buttonState = _ButtonState.released
          : buttonState = _ButtonState.pressed);
    }
  }

  void _onCanceled(BuildContext context) {
    animationController.reverse();
    if (progressController.status == AnimationStatus.forward ||
        progressController.status == AnimationStatus.completed) {
      progressController.reverseDuration = widget.reverseDuration;
      progressController.reverse();
      widget.onReleasedWhenCompleted?.call();
    } else if (progressController.status == AnimationStatus.dismissed) {
      setState(() => buttonState == _ButtonState.pressed
          ? buttonState = _ButtonState.released
          : buttonState = _ButtonState.pressed);
      widget.onCanceled?.call();
    }
  }
}
