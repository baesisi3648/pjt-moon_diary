import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StarBackground extends StatelessWidget {
  final Widget child;
  final bool showMoon;

  const StarBackground({
    super.key,
    required this.child,
    this.showMoon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.nightGradient,
      ),
      child: Stack(
        children: [
          // Stars
          const Positioned.fill(
            child: StarField(),
          ),
          // Moon
          if (showMoon)
            Positioned(
              top: 60,
              right: 30,
              child: _buildMoon(),
            ),
          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildMoon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.moonGlow,
            AppTheme.moonGlow.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.3, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.moonGlow.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.moonGlow,
          ),
        ),
      ),
    );
  }
}

class StarField extends StatelessWidget {
  const StarField({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random(42); // Fixed seed for consistent stars
    final size = MediaQuery.of(context).size;

    return CustomPaint(
      size: size,
      painter: StarPainter(random: random),
    );
  }
}

class StarPainter extends CustomPainter {
  final Random random;
  final int starCount;

  StarPainter({
    required this.random,
    this.starCount = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      final opacity = random.nextDouble() * 0.5 + 0.3;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
