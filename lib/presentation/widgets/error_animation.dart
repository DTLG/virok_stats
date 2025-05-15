import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorAnimation extends StatefulWidget {
  final double width;
  final double height;

  const ErrorAnimation({
    Key? key,
    this.width = 200,
    this.height = 200,
  }) : super(key: key);

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasPlayedOnce = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_hasPlayedOnce) {
          setState(() {
            _hasPlayedOnce = true;
          });
        }
        _controller.forward(from: 0.0);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottiefiles/error.json',
      width: widget.width,
      height: widget.height,
      // controller: _controller,
      repeat: false,
    );
  }
}
