import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class AnimatedWeatherBackground extends StatefulWidget {
  final String weatherCondition;
  final bool isDarkMode;

  const AnimatedWeatherBackground({
    super.key,
    required this.weatherCondition,
    required this.isDarkMode,
  });

  @override
  State<AnimatedWeatherBackground> createState() => _AnimatedWeatherBackgroundState();
}

class _AnimatedWeatherBackgroundState extends State<AnimatedWeatherBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _particleControllers;
  late List<Animation<double>> _particleAnimations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    _particleControllers = List.generate(20, (index) {
      return AnimationController(
        duration: Duration(seconds: _random.nextInt(5) + 3),
        vsync: this,
      );
    });

    _particleAnimations = _particleControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    // Démarrer les animations
    for (var controller in _particleControllers) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (var controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond dégradé animé
        Container(
          decoration: BoxDecoration(
            gradient: _getWeatherGradient(),
          ),
        ),
        
        // Particules météo
        ...List.generate(20, (index) {
          return Positioned(
            left: _random.nextDouble() * MediaQuery.of(context).size.width,
            top: _random.nextDouble() * MediaQuery.of(context).size.height,
            child: _buildParticle(index),
          );
        }),
        
        // Effets spéciaux selon la météo
        _buildWeatherEffects(),
      ],
    );
  }

  LinearGradient _getWeatherGradient() {
    switch (widget.weatherCondition.toLowerCase()) {
      case 'clear':
        return widget.isDarkMode
            ? const LinearGradient(
                colors: [Color(0xFF1a237e), Color(0xFF0d47a1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFF64b5f6), Color(0xFF42a5f5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              );
      case 'clouds':
        return widget.isDarkMode
            ? const LinearGradient(
                colors: [Color(0xFF424242), Color(0xFF616161)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFF90a4ae), Color(0xFF78909c)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              );
      case 'rain':
        return widget.isDarkMode
            ? const LinearGradient(
                colors: [Color(0xFF263238), Color(0xFF37474f)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [Color(0xFF546e7a), Color(0xFF455a64)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              );
      default:
        return widget.isDarkMode ? AppConstants.darkGradient : AppConstants.primaryGradient;
    }
  }

  Widget _buildParticle(int index) {
    final size = _random.nextDouble() * 8 + 2;
    final opacity = _random.nextDouble() * 0.5 + 0.1;
    
    return AnimatedBuilder(
      animation: _particleAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -_particleAnimations[index].value * MediaQuery.of(context).size.height,
          ),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(77),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha(77),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherEffects() {
    switch (widget.weatherCondition.toLowerCase()) {
      case 'rain':
        return _buildRainEffect();
      case 'snow':
        return _buildSnowEffect();
      case 'thunderstorm':
        return _buildLightningEffect();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRainEffect() {
    return Stack(
      children: List.generate(50, (index) {
        return Positioned(
          left: _random.nextDouble() * MediaQuery.of(context).size.width,
          top: -20,
          child: Container(
            width: 1,
            height: 20,
            color: Colors.blue.withAlpha(153),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).moveY(
            begin: 0,
            end: MediaQuery.of(context).size.height + 20,
            duration: Duration(milliseconds: _random.nextInt(1000) + 500),
            curve: Curves.linear,
          ),
        );
      }),
    );
  }

  Widget _buildSnowEffect() {
    return Stack(
      children: List.generate(30, (index) {
        return Positioned(
          left: _random.nextDouble() * MediaQuery.of(context).size.width,
          top: -10,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).moveY(
            begin: 0,
            end: MediaQuery.of(context).size.height + 10,
            duration: Duration(seconds: _random.nextInt(5) + 3),
            curve: Curves.easeInOut,
          ).moveX(
            begin: 0,
            end: _random.nextDouble() * 50 - 25,
            duration: Duration(seconds: _random.nextInt(3) + 2),
            curve: Curves.easeInOut,
          ),
        );
      }),
    );
  }

  Widget _buildLightningEffect() {
    return Container(
      color: Colors.yellow.withAlpha(77),
    );
  }
} 