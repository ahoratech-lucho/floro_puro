import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../utils/constants.dart';

/// Horizontal bar breakdown of floro dimensions
class DimensionBars extends StatefulWidget {
  final CandidateCard card;

  const DimensionBars({super.key, required this.card});

  @override
  State<DimensionBars> createState() => _DimensionBarsState();
}

class _DimensionBarsState extends State<DimensionBars>
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

    final bars = [
      _BarData('Incoherencia', p['incoherencia'] ?? 0, Icons.shuffle_rounded),
      _BarData('Promesas Inviables', p['promesasInviables'] ?? 0, Icons.cloud_outlined),
      _BarData('Opacidad', p['opacidad'] ?? 0, Icons.visibility_off_outlined),
      _BarData('Populismo', p['populismo'] ?? 0, Icons.record_voice_over_outlined),
      _BarData('Victimismo', p['victimismoEstrategico'] ?? 0, Icons.sentiment_dissatisfied_outlined),
      _BarData('Reciclaje Político', p['reciclajePolitico'] ?? 0, Icons.recycling_outlined),
    ];

    final hasData = bars.any((b) => b.value > 0);
    if (!hasData) return const SizedBox.shrink();

    // Sort by value descending
    bars.sort((a, b) => b.value.compareTo(a.value));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bars.map((bar) {
            final pct = (bar.value / 20).clamp(0.0, 1.0);
            final animatedPct = pct * _animation.value;
            final barColor = _colorForValue(bar.value);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(bar.icon, color: barColor, size: 16),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: Text(
                      bar.label,
                      style: const TextStyle(
                        color: colorTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorCardBorder.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: animatedPct,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [barColor.withAlpha(100), barColor],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${bar.value}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: barColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _colorForValue(int value) {
    if (value >= 15) return colorAccentRed;
    if (value >= 10) return colorMuchoFloro;
    if (value >= 5) return colorDudoso;
    return colorPasaRaspando;
  }
}

class _BarData {
  final String label;
  final int value;
  final IconData icon;
  _BarData(this.label, this.value, this.icon);
}
