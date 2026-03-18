import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/candidate_card.dart';
import '../utils/constants.dart';
import '../utils/scoring.dart';
import '../widgets/swipe_card.dart';
import 'reveal_screen.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  final List<CandidateCard> cards;

  const GameScreen({super.key, required this.cards});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final List<PlayerChoice> _choices = [];
  PlayerChoice? _selectedChoice;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  // Streak system
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _showStreakBanner = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.cards.length) {
      return const SizedBox.shrink();
    }

    final card = widget.cards[_currentIndex];

    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: colorTextTertiary, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_currentIndex + 1} de ${widget.cards.length}',
                          style: const TextStyle(
                            color: colorTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _currentIndex / widget.cards.length,
                            backgroundColor: colorCardBorder.withAlpha(80),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                colorAccentRed),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak counter
                  SizedBox(
                    width: 48,
                    child: _currentStreak >= 2
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🔥', style: TextStyle(fontSize: 14)),
                              Text(
                                '$_currentStreak',
                                style: TextStyle(
                                  color: colorAccentGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Swipe hint (shown first 3 cards only)
            if (_currentIndex < 3)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: colorBg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swipe, color: colorTextMuted, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '← Puro floro  ·  ↑ Sospechoso  ·  → Pasa raspando  ·  ↓ Bandera roja',
                      style: TextStyle(
                        color: colorTextMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Streak banner
            if (_currentStreak >= 3 || _showStreakBanner)
              AnimatedOpacity(
                opacity: _showStreakBanner ? 1.0 : 0.7,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: colorAccentGold.withAlpha(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        _currentStreak >= 5
                            ? '¡RACHA IMPARABLE! x$_currentStreak'
                            : '¡RACHA DETECTORA! x$_currentStreak',
                        style: TextStyle(
                          color: colorAccentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('🔥', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

            // Card area — swipeable
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SwipeCardWidget(
                    key: ValueKey(card.id),
                    card: card,
                    enableSwipe: _selectedChoice == null,
                    onSwipeChoice: (choice) => _onChoice(choice),
                  ),
                ),
              ),
            ),

            // 4 choice buttons — still available as fallback
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: [
                  const Text(
                    '¿Qué detecta tu radar?',
                    style: TextStyle(
                      color: colorTextTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _choiceButton(
                          PlayerChoice.puroFloro,
                          'PURO\nFLORO',
                          colorAccentRed,
                          Icons.close_rounded,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _choiceButton(
                          PlayerChoice.banderaRoja,
                          'BANDERA\nROJA',
                          colorBanderaRoja,
                          Icons.flag_rounded,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _choiceButton(
                          PlayerChoice.sospechoso,
                          'SOSPE-\nCHOSO',
                          colorMuchoFloro,
                          Icons.help_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _choiceButton(
                          PlayerChoice.pasaRaspando,
                          'PASA\nRASPANDO',
                          colorPasaRaspando,
                          Icons.check_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceButton(
      PlayerChoice choice, String label, Color color, IconData icon) {
    final isSelected = _selectedChoice == choice;

    return GestureDetector(
      onTap: () => _onChoice(choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(80),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onChoice(PlayerChoice choice) {
    if (_selectedChoice != null) return; // Prevent double tap

    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() => _selectedChoice = choice);
    _choices.add(choice);

    // Track streak
    final card = widget.cards[_currentIndex];
    final score = scoreChoice(card, choice);
    if (score >= 2) {
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
      if (_currentStreak >= 3) {
        setState(() => _showStreakBanner = true);
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _showStreakBanner = false);
        });
      }
    } else {
      _currentStreak = 0;
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      final cardIndex = _currentIndex;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RevealScreen(
            card: widget.cards[cardIndex],
            playerChoice: choice,
            cardNumber: cardIndex + 1,
            totalCards: widget.cards.length,
            streak: _currentStreak,
            onContinue: () {
              Navigator.of(context).pop();
              _nextCard();
            },
          ),
        ),
      );
    });
  }

  void _nextCard() {
    final nextIndex = _currentIndex + 1;

    if (nextIndex >= widget.cards.length) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            result: RoundResult(
              cards: widget.cards,
              choices: _choices,
            ),
            bestStreak: _bestStreak,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex = nextIndex;
      _selectedChoice = null;
    });

    _fadeController.reset();
    _fadeController.forward();
  }
}
