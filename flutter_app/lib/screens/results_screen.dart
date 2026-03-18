import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confetti/confetti.dart';
import '../models/candidate_card.dart';
import '../data/score_service.dart';
import '../utils/scoring.dart';
import '../utils/constants.dart';

class ResultsScreen extends StatefulWidget {
  final RoundResult result;
  final int bestStreak;

  const ResultsScreen({
    super.key,
    required this.result,
    this.bestStreak = 0,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late ConfettiController _confettiController;
  bool _isNewBest = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
    // Fire confetti if good score
    if (widget.result.percentage >= 0.5) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _confettiController.play();
      });
    }
    _saveScore();
  }

  Future<void> _saveScore() async {
    final result = widget.result;
    final pct = (result.percentage * 100).round();
    final isNew = await ScoreService.saveRound(
      score: result.totalScore,
      maxScore: result.maxScore,
      percent: pct,
      streak: widget.bestStreak,
      cardsPlayed: result.cards.length,
      title: result.title,
    );
    if (mounted) {
      setState(() {
        _isNewBest = isNew;
        _saved = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final perfectCount = _countByScore(result, 3);
    final goodCount = _countByScore(result, 2);
    final missCount = _countByScore(result, 0);

    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
          children: [
            // Fixed top bar
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    'RESULTADOS',
                    style: TextStyle(
                      color: colorTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  if (_isNewBest && _saved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorAccentGold.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorAccentGold.withAlpha(80)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🏆', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text(
                            'NUEVO RÉCORD',
                            style: TextStyle(
                              color: colorAccentGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ===== MAIN SCORE CARD =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: colorBgWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorCardBorder, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Text(result.emoji, style: const TextStyle(fontSize: 56)),
                          const SizedBox(height: 12),
                          Text(
                            result.title,
                            style: const TextStyle(
                              color: colorAccentRed,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              result.rating,
                              style: const TextStyle(
                                color: colorTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),

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
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${result.totalScore} / ${result.maxScore} puntos',
                                    style: const TextStyle(
                                      color: colorTextTertiary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== QUICK STATS ROW =====
                    Row(
                      children: [
                        _miniStat('✅', '$perfectCount', 'Exactos', colorPasaRaspando),
                        const SizedBox(width: 8),
                        _miniStat('🔥', '${widget.bestStreak}', 'Mejor racha', colorAccentGold),
                        const SizedBox(width: 8),
                        _miniStat('❌', '$missCount', 'Fallados', colorAccentRed),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ===== CANDIDATE BREAKDOWN =====
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorBgWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorCardBorder, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                            child: Text(
                              'RESUMEN DE LA RONDA',
                              style: TextStyle(
                                color: colorTextSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Container(height: 0.5, color: colorDivider),
                          ...List.generate(result.cards.length, (i) {
                            final card = result.cards[i];
                            final choice = result.choices[i];
                            final score = scoreChoice(card, choice);
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Row(
                                    children: [
                                      _scoreIcon(score),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          card.nombre,
                                          style: const TextStyle(
                                            color: colorTextPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _colorForChoice(choice)
                                              .withAlpha(25),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          choiceLabel(choice),
                                          style: TextStyle(
                                            color: _colorForChoice(choice),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '+$score',
                                        style: TextStyle(
                                          color: _colorForScore(score),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < result.cards.length - 1)
                                  Container(
                                      height: 0.5,
                                      color: colorDivider.withAlpha(128)),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Party stats
                    _partyStats(result),
                    const SizedBox(height: 16),

                    // ===== SHARE WHATSAPP =====
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _shareWhatsApp(result),
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: const Text(
                          'COMPARTIR POR WHATSAPP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ===== COPY TO CLIPBOARD =====
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _copyResult(result),
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        label: const Text(
                          'COPIAR RESULTADO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorAccentRed,
                          side: const BorderSide(color: colorAccentRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ===== PLAY AGAIN =====
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccentRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'JUGAR OTRA RONDA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Container(height: 0.5, color: colorDivider),
                          const SizedBox(height: 8),
                          const Text(
                            'Radar del Floro · Elecciones Perú 2026',
                            style: TextStyle(
                              color: colorTextMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2, // downward
                maxBlastForce: 15,
                minBlastForce: 5,
                emissionFrequency: 0.06,
                numberOfParticles: 20,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  colorAccentRed,
                  colorAccentGold,
                  colorPasaRaspando,
                  colorDudoso,
                  colorBanderaRoja,
                  Color(0xFF6C5CE7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MINI STAT CARD =====
  Widget _miniStat(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: colorTextTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== PARTY STATS =====
  Widget _partyStats(RoundResult result) {
    final Map<String, List<int>> partyFloro = {};
    for (final card in result.cards) {
      final party = card.partido ?? 'Independiente';
      partyFloro.putIfAbsent(party, () => []);
      partyFloro[party]!.add(card.indiceFloro);
    }

    if (partyFloro.isEmpty) return const SizedBox.shrink();

    final sortedParties = partyFloro.entries.toList()
      ..sort((a, b) {
        final avgA = a.value.reduce((x, y) => x + y) / a.value.length;
        final avgB = b.value.reduce((x, y) => x + y) / b.value.length;
        return avgB.compareTo(avgA);
      });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorCardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined,
                    color: colorTextSecondary, size: 16),
                SizedBox(width: 6),
                Text(
                  'PARTIDOS EN ESTA RONDA',
                  style: TextStyle(
                    color: colorTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: colorDivider),
          ...sortedParties.map((entry) {
            final party = entry.key;
            final scores = entry.value;
            final avg = scores.reduce((a, b) => a + b) / scores.length;
            final barWidth = avg / 100;
            final barColor = avg >= 50
                ? colorAccentRed
                : avg >= 25
                    ? colorMuchoFloro
                    : colorPasaRaspando;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          party,
                          style: const TextStyle(
                            color: colorTextPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${scores.length} candidato${scores.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: colorTextMuted,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'IF ${avg.round()}',
                        style: TextStyle(
                          color: barColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: barWidth,
                      backgroundColor: colorCardBorder.withAlpha(60),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ===== HELPERS =====
  int _countByScore(RoundResult result, int targetScore) {
    int count = 0;
    for (int i = 0; i < result.cards.length; i++) {
      if (scoreChoice(result.cards[i], result.choices[i]) == targetScore) {
        count++;
      }
    }
    return count;
  }

  Widget _scoreIcon(int score) {
    if (score == 3) {
      return const Icon(Icons.check_circle_outline,
          color: colorPasaRaspando, size: 18);
    }
    if (score == 2) {
      return const Icon(Icons.remove_circle_outline,
          color: colorDudoso, size: 18);
    }
    if (score == 1) {
      return const Icon(Icons.help_outline, color: colorMuchoFloro, size: 18);
    }
    return const Icon(Icons.cancel_outlined, color: colorAccentRed, size: 18);
  }

  Color _colorForPercent(double pct) {
    if (pct >= 0.7) return colorPasaRaspando;
    if (pct >= 0.5) return colorDudoso;
    if (pct >= 0.3) return colorMuchoFloro;
    return colorAccentRed;
  }

  Color _colorForChoice(PlayerChoice choice) {
    switch (choice) {
      case PlayerChoice.puroFloro:
        return colorAccentRed;
      case PlayerChoice.banderaRoja:
        return colorBanderaRoja;
      case PlayerChoice.sospechoso:
        return colorMuchoFloro;
      case PlayerChoice.pasaRaspando:
        return colorPasaRaspando;
    }
  }

  Color _colorForScore(int score) {
    if (score == 3) return colorPasaRaspando;
    if (score == 2) return colorDudoso;
    if (score == 1) return colorMuchoFloro;
    return colorAccentRed;
  }

  String _shareText(RoundResult result) {
    final pct = (result.percentage * 100).round();
    return '${result.emoji} Soy "${result.title}" en Radar del Floro!\n'
        'Obtuve $pct% (${result.totalScore}/${result.maxScore} puntos)\n'
        '${result.rating}\n'
        '${widget.bestStreak >= 3 ? '🔥 Mejor racha: ${widget.bestStreak}\n' : ''}\n'
        '¿Puedes detectar el floro político? 🇵🇪\n'
        '#RadarDelFloro #Elecciones2026';
  }

  void _shareWhatsApp(RoundResult result) async {
    final text = _shareText(result);
    final encoded = Uri.encodeComponent(text);
    final url = 'https://wa.me/?text=$encoded';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyResult(RoundResult result) {
    final text = _shareText(result);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Resultado copiado al portapapeles')),
          ],
        ),
        backgroundColor: colorPasaRaspando,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
