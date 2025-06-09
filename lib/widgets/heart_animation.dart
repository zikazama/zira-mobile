import 'dart:math';
import 'package:flutter/material.dart';

class HeartAnimation extends StatefulWidget {
  final AnimationController controller;

  const HeartAnimation({Key? key, required this.controller}) : super(key: key);

  @override
  _HeartAnimationState createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation> {
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  final Random _random = Random();
  final List<HeartParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _sizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeOutQuad,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Create heart particles
    for (int i = 0; i < 20; i++) {
      _particles.add(HeartParticle(
        initialPosition: Offset(_random.nextDouble(), _random.nextDouble()),
        size: _random.nextDouble() * 20 + 10,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 2,
          -_random.nextDouble() * 3 - 1,
        ),
      ));
    }
    
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          // Update particles
          for (var particle in _particles) {
            particle.update(widget.controller.value);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: HeartPainter(
              particles: _particles,
              progress: widget.controller.value,
              opacity: _opacityAnimation.value,
            ),
            child: Center(
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _sizeAnimation.value * 2,
                  child: Icon(
                    Icons.favorite,
                    size: size.width * 0.4,
                    color: Colors.red[400],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HeartParticle {
  Offset initialPosition;
  Offset position;
  Offset velocity;
  double size;
  double opacity = 1.0;
  
  HeartParticle({
    required this.initialPosition,
    required this.size,
    required this.velocity,
  }) : position = initialPosition;
  
  void update(double progress) {
    // Update position based on velocity and progress
    position = Offset(
      initialPosition.dx + velocity.dx * progress * 100,
      initialPosition.dy + velocity.dy * progress * 100 - 2 * progress * progress * 50,
    );
    
    // Fade out as the animation progresses
    opacity = 1.0 - progress;
  }
}

class HeartPainter extends CustomPainter {
  final List<HeartParticle> particles;
  final double progress;
  final double opacity;
  
  HeartPainter({
    required this.particles,
    required this.progress,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red[400]!.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    for (var particle in particles) {
      final particleOpacity = particle.opacity * opacity;
      if (particleOpacity <= 0) continue;
      
      paint.color = Colors.red[400]!.withOpacity(particleOpacity);
      
      final x = particle.position.dx * size.width;
      final y = particle.position.dy * size.height;
      
      // Draw heart shape
      final path = Path();
      final double heartSize = particle.size * progress;
      
      path.moveTo(x, y + heartSize / 4);
      path.quadraticBezierTo(x, y, x + heartSize / 4, y);
      path.quadraticBezierTo(x + heartSize / 2, y, x + heartSize / 2, y + heartSize / 4);
      path.quadraticBezierTo(x + heartSize / 2, y, x + 3 * heartSize / 4, y);
      path.quadraticBezierTo(x + heartSize, y, x + heartSize, y + heartSize / 4);
      path.quadraticBezierTo(x + heartSize, y + heartSize / 2, x + heartSize / 2, y + 3 * heartSize / 4);
      path.quadraticBezierTo(x, y + heartSize / 2, x, y + heartSize / 4);
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(HeartPainter oldDelegate) => 
      oldDelegate.progress != progress || oldDelegate.opacity != opacity;
}