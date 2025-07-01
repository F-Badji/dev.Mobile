import 'package:flutter/material.dart';

class ARWeatherService {
  static final ARWeatherService _instance = ARWeatherService._internal();
  factory ARWeatherService() => _instance;
  ARWeatherService._internal();

  bool _isARSupported = false;

  Future<bool> checkARSupport() async {
    // TODO: Vérifier si ARCore (Android) ou ARKit (iOS) est disponible
    // Pour l'instant, on simule
    _isARSupported = true;
    return _isARSupported;
  }

  Future<void> startARWeatherMode() async {
    if (!_isARSupported) {
      throw Exception('AR non supporté sur cet appareil');
    }
    // TODO: Lancer la caméra AR et superposer les données météo
  }

  Future<void> stopARWeatherMode() async {
    // TODO: Arrêter le mode AR
  }

  bool get isARSupported => _isARSupported;
}

class ARWeatherWidget extends StatefulWidget {
  const ARWeatherWidget({super.key});

  @override
  State<ARWeatherWidget> createState() => _ARWeatherWidgetState();
}

class _ARWeatherWidgetState extends State<ARWeatherWidget> {
  final ARWeatherService _arService = ARWeatherService();
  bool _isARSupported = false;

  @override
  void initState() {
    super.initState();
    _checkARSupport();
  }

  Future<void> _checkARSupport() async {
    final supported = await _arService.checkARSupport();
    setState(() {
      _isARSupported = supported;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isARSupported) {
      return const Center(
        child: Text(
          'AR non supporté sur cet appareil',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return const Center(
      child: Text(
        'Mode AR Météo',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
} 