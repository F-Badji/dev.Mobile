import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveWeatherAnimation extends StatelessWidget {
  final String riveFile;
  final String artboard;
  final String animation;
  final double size;

  const RiveWeatherAnimation({
    super.key,
    required this.riveFile,
    this.artboard = 'Main',
    this.animation = 'idle',
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RiveAnimation.asset(
        riveFile,
        artboard: artboard,
        animations: [animation],
        fit: BoxFit.contain,
      ),
    );
  }
} 