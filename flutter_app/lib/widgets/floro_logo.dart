import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/constants.dart';

/// Editorial-style logo: a clean red circle with "?!"
/// and a subtle newspaper stamp aesthetic
class FloroLogo extends StatelessWidget {
  final double size;

  const FloroLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FloroLogoPainter(),
        child: Center(
          child: Text(
            '?!',
            style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloroLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Main red circle
    final mainPaint = Paint()..color = colorAccentRed;
    canvas.drawCircle(center, radius * 0.88, mainPaint);

    // White ring border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;
    canvas.drawCircle(center, radius * 0.78, borderPaint);

    // Outer thin dark ring (stamp look)
    final outerRing = Paint()
      ..color = colorTextPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;
    canvas.drawCircle(center, radius * 0.95, outerRing);

    // Small decorative dots around the edge (like a stamp)
    final dotPaint = Paint()..color = colorTextPrimary;
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * pi / 180;
      final dotCenter = Offset(
        center.dx + cos(angle) * radius * 0.88,
        center.dy + sin(angle) * radius * 0.88,
      );
      canvas.drawCircle(dotCenter, size.width * 0.012, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedFloroLogo extends StatefulWidget {
  final double size;

  const AnimatedFloroLogo({super.key, this.size = 120});

  @override
  State<AnimatedFloroLogo> createState() => _AnimatedFloroLogoState();
}

class _AnimatedFloroLogoState extends State<AnimatedFloroLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FloroLogo(size: widget.size),
        );
      },
    );
  }
}
