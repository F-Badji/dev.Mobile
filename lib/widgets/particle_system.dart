import 'dart:math';
import 'package:flutter/material.dart';

class ParticleSystem extends StatefulWidget {
  final String weatherType;
  final bool isActive;

  const ParticleSystem({
    super.key,
    required this.weatherType,
    required this.isActive,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late List<Particle> _particles;
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _initializeParticles();
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  void _initializeParticles() {
    _particles = List.generate(50, (index) {
      return Particle(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 800,
        vx: (_random.nextDouble() - 0.5) * 2,
        vy: _random.nextDouble() * 2 + 1,
        size: _random.nextDouble() * 4 + 1,
        color: _getParticleColor(),
        life: _random.nextDouble() * 100 + 50,
      );
    });
  }

  Color _getParticleColor() {
    switch (widget.weatherType) {
      case 'rain':
        return Colors.blue.withAlpha(179);
      case 'snow':
        return Colors.white.withAlpha(230);
      case 'sunny':
        return Colors.yellow.withAlpha(204);
      case 'cloudy':
        return Colors.grey.withAlpha(153);
      default:
        return Colors.white.withAlpha(128);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: ParticlePainter(_particles),
          size: Size.infinite,
        );
      },
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.life--;

      // Réinitialiser les particules qui sortent de l'écran
      if (particle.y > 800 || particle.life <= 0) {
        particle.x = _random.nextDouble() * 400;
        particle.y = -10;
        particle.life = _random.nextDouble() * 100 + 50;
      }
    }
  }
}

class Particle {
  double x, y, vx, vy, size, life;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.life,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withAlpha((particle.life / 150 * 255).round())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 