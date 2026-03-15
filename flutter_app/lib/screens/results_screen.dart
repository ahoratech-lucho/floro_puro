import 'package:flutter/material.dart';
import '../utils/scoring.dart';
import '../utils/constants.dart';

class ResultsScreen extends StatefulWidget {
  final RoundResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.result.percentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Emoji
              Text(
                result.emoji,
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 16),

              // Rating
              Text(
                result.rating,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Animated score
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, _) {
                  final pct = (_scoreAnimation.value * 100).toInt();
                  return Column(
                    children: [
                      Text(
                        '$pct%',
                        style: TextStyle(
                          color: _colorForPercent(_scoreAnimation.value),
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${result.totalScore} / ${result.maxScore} puntos',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Breakdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(result.cards.length, (i) {
                      final card = result.cards[i];
                      final choice = result.choices[i];
                      final score = scoreSwipe(card, choice);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            _scoreIcon(score),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                card.nombre,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              swipeLabel(choice),
                              style: TextStyle(
                                color: _colorForChoice(choice),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+$score',
                              style: TextStyle(
                                color: _colorForScore(score),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Play again button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '🔍 JUGAR OTRA RONDA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Share text
              Text(
                'Radar del Floro - Elecciones Perú 2026',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreIcon(int score) {
    if (score == 3) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 18);
    }
    if (score == 2) {
      return const Icon(Icons.remove_circle, color: Colors.amber, size: 18);
    }
    if (score == 1) {
      return const Icon(Icons.help, color: Colors.orange, size: 18);
    }
    return const Icon(Icons.cancel, color: Colors.red, size: 18);
  }

  Color _colorForPercent(double pct) {
    if (pct >= 0.7) return Colors.green;
    if (pct >= 0.5) return Colors.amber;
    if (pct >= 0.3) return Colors.orange;
    return Colors.red;
  }

  Color _colorForChoice(SwipeDirection choice) {
    switch (choice) {
      case SwipeDirection.left:
        return Colors.red[300]!;
      case SwipeDirection.right:
        return Colors.green[300]!;
      case SwipeDirection.up:
        return Colors.amber[300]!;
    }
  }

  Color _colorForScore(int score) {
    if (score == 3) return Colors.green;
    if (score == 2) return Colors.amber;
    if (score == 1) return Colors.orange;
    return Colors.red;
  }
}
