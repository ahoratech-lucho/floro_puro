import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FloroMeter extends StatefulWidget {
  final int score;
  final int maxScore;
  final String nivel;

  const FloroMeter({
    super.key,
    required this.score,
    this.maxScore = 100,
    required this.nivel,
  });

  @override
  State<FloroMeter> createState() => _FloroMeterState();
}

class _FloroMeterState extends State<FloroMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.score / widget.maxScore,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(FloroMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score / widget.maxScore,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForNivel(widget.nivel);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              height: 100,
              child: CustomPaint(
                painter: _GaugePainter(
                  progress: _animation.value,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.score}',
              style: TextStyle(
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(60)),
              ),
              child: Text(
                widget.nivel.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 4);
    final radius = size.width / 2 - 12;

    // Background arc — full semicircle with color zones
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Draw colored zone segments (green → yellow → orange → red)
    final zones = [
      (colorPasaRaspando.withAlpha(50), 0.0, 0.25),
      (colorDudoso.withAlpha(50), 0.25, 0.50),
      (colorMuchoFloro.withAlpha(50), 0.50, 0.75),
      (colorAccentRed.withAlpha(50), 0.75, 1.0),
    ];

    for (final zone in zones) {
      bgPaint.color = zone.$1;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi + math.pi * zone.$2,
        math.pi * (zone.$3 - zone.$2),
        false,
        bgPaint,
      );
    }

    // Progress arc (main color)
    if (progress > 0.01) {
      final fgPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi * progress,
        false,
        fgPaint,
      );
    }

    // Needle
    final angle = math.pi + math.pi * progress;
    final needleLen = radius - 6;
    final needleEnd = Offset(
      center.dx + needleLen * math.cos(angle),
      center.dy + needleLen * math.sin(angle),
    );

    // Needle line
    final needlePaint = Paint()
      ..color = colorTextPrimary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center circle
    canvas.drawCircle(center, 6, Paint()..color = colorTextPrimary);
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);

    // Tip dot
    canvas.drawCircle(needleEnd, 4, Paint()..color = colorTextPrimary);
    canvas.drawCircle(needleEnd, 2, Paint()..color = Colors.white);

    // Scale labels
    final labelStyle = TextPainter(textDirection: TextDirection.ltr);

    void drawLabel(String text, double pct) {
      final a = math.pi + math.pi * pct;
      final labelRadius = radius + 14;
      final pos = Offset(
        center.dx + labelRadius * math.cos(a),
        center.dy + labelRadius * math.sin(a),
      );
      labelStyle
        ..text = TextSpan(
          text: text,
          style: const TextStyle(
            color: colorTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        )
        ..layout();
      labelStyle.paint(
        canvas,
        Offset(pos.dx - labelStyle.width / 2, pos.dy - labelStyle.height / 2),
      );
    }

    drawLabel('0', 0.0);
    drawLabel('25', 0.25);
    drawLabel('50', 0.5);
    drawLabel('75', 0.75);
    drawLabel('100', 1.0);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
