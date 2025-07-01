import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class ConfettiSuccess extends StatefulWidget {
  final Widget child;
  
  const ConfettiSuccess({super.key, required this.child});

  @override
  State<ConfettiSuccess> createState() => _ConfettiSuccessState();
}

class _ConfettiSuccessState extends State<ConfettiSuccess> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void triggerConfetti() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenu principal
        widget.child,
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
} 