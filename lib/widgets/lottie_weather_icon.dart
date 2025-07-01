import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWeatherIcon extends StatelessWidget {
  final String weatherDescription;
  final double size;

  const LottieWeatherIcon({
    super.key,
    required this.weatherDescription,
    this.size = 80,
  });

  String _getLottieAsset() {
    final desc = weatherDescription.toLowerCase();
    if (desc.contains('pluie')) return 'assets/animations/rain.json';
    if (desc.contains('neige')) return 'assets/animations/snow.json';
    if (desc.contains('orage')) return 'assets/animations/thunder.json';
    if (desc.contains('nuage')) return 'assets/animations/cloud.json';
    if (desc.contains('soleil') || desc.contains('clair')) return 'assets/animations/sun.json';
    return 'assets/animations/sun.json';
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _getLottieAsset(),
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: true,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.wb_sunny_rounded, size: size, color: Colors.white),
    );
  }
} 