import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../utils/constants.dart';

/// Custom hexagonal radar chart — bigger, clearer labels, colored vertices
class FloroRadarChart extends StatefulWidget {
  final CandidateCard card;
  final double size;

  const FloroRadarChart({
    super.key,
    required this.card,
    this.size = 220,
  });

  @override
  State<FloroRadarChart> createState() => _FloroRadarChartState();
}

class _FloroRadarChartState extends State<FloroRadarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.card.puntajes;

    final axes = [
      _Axis('Incoherencia', p['incoherencia'] ?? 0),
      _Axis('Promesas\nInviables', p['promesasInviables'] ?? 0),
      _Axis('Opacidad', p['opacidad'] ?? 0),
      _Axis('Populismo', p['populismo'] ?? 0),
      _Axis('Victimismo', p['victimismoEstrategico'] ?? 0),
      _Axis('Reciclaje\nPolítico', p['reciclajePolitico'] ?? 0),
    ];

    final hasData = axes.any((a) => a.value > 0);

    if (!hasData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Center(
          child: Text(
            'Sin desglose detallado para este candidato',
            style: TextStyle(color: colorTextMuted, fontSize: 12),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          width: widget.size + 80, // extra space for labels
          height: widget.size + 60,
          child: CustomPaint(
            size: Size(widget.size + 80, widget.size + 60),
            painter: _RadarPainter(
              axes: axes,
              progress: _animation.value,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

class _Axis {
  final String label;
  final int value;
  _Axis(this.label, this.value);
}

class _RadarPainter extends CustomPainter {
  final List<_Axis> axes;
  final double progress;
  final double size;

  _RadarPainter({
    required this.axes,
    required this.progress,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2 - 10;
    final n = axes.length;
    final maxValue = 20.0; // max per axis

    // ===== GRID (3 levels) =====
    for (int level = 1; level <= 3; level++) {
      final r = radius * level / 3;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * i / n);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = colorDivider.withAlpha(level == 3 ? 100 : 50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = level == 3 ? 1.0 : 0.5,
      );
    }

    // ===== AXIS LINES =====
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(
        center,
        Offset(x, y),
        Paint()
          ..color = colorDivider.withAlpha(60)
          ..strokeWidth = 0.5,
      );
    }

    // ===== DATA POLYGON =====
    final dataPath = Path();
    final dataPoints = <Offset>[];
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final value = (axes[i].value / maxValue).clamp(0.0, 1.0) * progress;
      final r = radius * value;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      dataPoints.add(Offset(x, y));
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Fill
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = colorAccentRed.withAlpha(30)
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = colorAccentRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // ===== DATA POINTS (dots with value) =====
    for (int i = 0; i < n; i++) {
      final pt = dataPoints[i];
      final value = axes[i].value;
      final dotColor = _colorForValue(value);

      // Outer circle
      canvas.drawCircle(pt, 6, Paint()..color = dotColor);
      // Inner circle
      canvas.drawCircle(pt, 3.5, Paint()..color = Colors.white);

      // Value label near the dot (offset outward a bit)
      if (value > 0) {
        final angle = -math.pi / 2 + (2 * math.pi * i / n);
        final labelOffset = Offset(
          pt.dx + 12 * math.cos(angle),
          pt.dy + 12 * math.sin(angle),
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '$value',
            style: TextStyle(
              color: dotColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(labelOffset.dx - tp.width / 2, labelOffset.dy - tp.height / 2));
      }
    }

    // ===== AXIS LABELS =====
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final labelRadius = radius + 28;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: axes[i].label,
          style: const TextStyle(
            color: colorTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 70);

      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  Color _colorForValue(int value) {
    if (value >= 15) return colorAccentRed;
    if (value >= 10) return colorBanderaRoja;
    if (value >= 5) return colorMuchoFloro;
    return colorPasaRaspando;
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
