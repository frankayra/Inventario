import 'package:flutter/material.dart';

class CountdownCircle extends StatefulWidget {
  final Duration duration;
  final void Function()? onEnd;
  const CountdownCircle({super.key, this.onEnd, required this.duration});

  @override
  State<CountdownCircle> createState() => _CountdownCircleState();
}

class _CountdownCircleState extends State<CountdownCircle> {
  late Duration duration;

  @override
  void initState() {
    super.initState();
    duration = widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: duration,
      onEnd: () {
        // Acción al finalizar el tiempo
        widget.onEnd?.call();
      },
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 4,
                backgroundColor: Theme.of(context).disabledColor,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
            Text(
              "${(value * duration.inSeconds).ceil()}",
              style: TextStyle(fontSize: 12),
            ),
          ],
        );
      },
    );
  }
}
