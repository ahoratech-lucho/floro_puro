import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/candidate_card.dart';

class FloroRadarChart extends StatelessWidget {
  final CandidateCard card;
  final double size;

  const FloroRadarChart({
    super.key,
    required this.card,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final p = card.puntajes;
    if (p.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Text('Sin datos', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    final axes = [
      _Axis('Incoherencia', p['incoherencia'] ?? 0),
      _Axis('Promesas\nInviables', p['promesasInviables'] ?? 0),
      _Axis('Opacidad', p['opacidad'] ?? 0),
      _Axis('Populismo', p['populismo'] ?? 0),
      _Axis('Victimismo', p['victimismoEstrategico'] ?? 0),
      _Axis('Reciclaje', p['reciclajePolitico'] ?? 0),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          titlePositionPercentageOffset: 0.2,
          dataSets: [
            RadarDataSet(
              dataEntries: axes
                  .map((a) => RadarEntry(value: a.value.toDouble()))
                  .toList(),
              fillColor: Colors.red.withOpacity(0.2),
              borderColor: Colors.red[400]!,
              borderWidth: 2,
              entryRadius: 3,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          tickBorderData: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          gridBorderData: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          ticksTextStyle: const TextStyle(fontSize: 0), // Hide tick labels
          tickCount: 4,
          titleTextStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 9,
          ),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: axes[index].label,
            );
          },
        ),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
      ),
    );
  }
}

class _Axis {
  final String label;
  final int value;
  _Axis(this.label, this.value);
}
