import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProgressGauge extends StatelessWidget {
  final double progress;
  final double size;

  const ProgressGauge({
    super.key,
    required this.progress,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fond
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 16,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withAlpha(38),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Progression
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 16,
              valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.accentColor),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Texte au centre
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chargement',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 