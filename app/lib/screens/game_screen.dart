import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/tutorial_service.dart';
import '../data/sound_service.dart';
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
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<PlayerChoice> _choices = [];
  PlayerChoice? _selectedChoice;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Streak system
  int _currentStreak = 0;
  int _bestStreak = 0;
  bool _showStreakBanner = false;

  // Tutorial overlay
  bool _showTutorial = false;
  late AnimationController _tutPulseCtrl;
  late Animation<double> _tutPulseAnim;
  late AnimationController _tutBounceCtrl;
  late Animation<double> _tutBounceAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Tutorial setup
    _tutPulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000), vsync: this,
    )..repeat(reverse: true);
    _tutPulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _tutPulseCtrl, curve: Curves.easeInOut),
    );
    _tutBounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 600), vsync: this,
    );
    _tutBounceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tutBounceCtrl, curve: Curves.elasticOut),
    );

    if (TutorialService.isActive && TutorialService.currentStep == 3) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() => _showTutorial = true);
          _tutBounceCtrl.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tutPulseCtrl.dispose();
    _tutBounceCtrl.dispose();
    super.dispose();
  }

  void _dismissTutorial() {
    TutorialService.advanceTo(4); // Next: reveal screen
    setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.cards.length) {
      return const SizedBox.shrink();
    }

    final card = widget.cards[_currentIndex];

    return Scaffold(
      backgroundColor: colorBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Minimal top bar — just X and streak
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: colorTextTertiary, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  // Streak counter
                  if (_currentStreak >= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorAccentGold.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 3),
                          Text(
                            '$_currentStreak',
                            style: TextStyle(
                              color: colorAccentGold,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
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
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  child: SwipeCardWidget(
                    key: ValueKey(card.id),
                    card: card,
                    enableSwipe: _selectedChoice == null,
                    onSwipeChoice: (choice) => _onChoice(choice),
                    cardNumber: _currentIndex + 1,
                    totalCards: widget.cards.length,
                  ),
                ),
              ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: colorBgWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ← FLORO (big)
                  _labeledCircleButton(
                    PlayerChoice.puroFloro,
                    Icons.close_rounded,
                    colorAccentRed,
                    58,
                    '← FLORO',
                  ),
                  // 🚩 BANDERA ROJA (small)
                  _labeledCircleButton(
                    PlayerChoice.banderaRoja,
                    Icons.flag_rounded,
                    colorBanderaRoja,
                    44,
                    'BANDERA',
                  ),
                  // ❓ SOSPECHOSO (small)
                  _labeledCircleButton(
                    PlayerChoice.sospechoso,
                    Icons.help_outline_rounded,
                    colorMuchoFloro,
                    44,
                    'DUDOSO',
                  ),
                  // PASA → (big)
                  _labeledCircleButton(
                    PlayerChoice.pasaRaspando,
                    Icons.check_rounded,
                    colorPasaRaspando,
                    58,
                    'PASA →',
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
          // Tutorial overlay
          if (_showTutorial)
            _buildGameTutorialOverlay(),
        ],
      ),
    );
  }

  Widget _buildGameTutorialOverlay() {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: _dismissTutorial,
      child: Stack(
        children: [
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha(180)),
          ),

          // Swipe arrows on the card area
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: topPad + 60),
                // Swipe arrows over the card
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left arrow
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: AnimatedBuilder(
                          animation: _tutPulseAnim,
                          builder: (_, __) => Opacity(
                            opacity: _tutPulseAnim.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back_rounded,
                                  color: colorAccentRed, size: 48),
                                const SizedBox(height: 4),
                                Text('FLORO',
                                  style: TextStyle(color: colorAccentRed,
                                    fontSize: 14, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Right arrow
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: AnimatedBuilder(
                          animation: _tutPulseAnim,
                          builder: (_, __) => Opacity(
                            opacity: _tutPulseAnim.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_forward_rounded,
                                  color: colorPasaRaspando, size: 48),
                                const SizedBox(height: 4),
                                Text('PASA',
                                  style: TextStyle(color: colorPasaRaspando,
                                    fontSize: 14, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // space for bottom buttons
              ],
            ),
          ),

          // Don Radar + bubble at center-bottom
          Positioned(
            left: 0, right: 0,
            bottom: bottomPad + 130,
            child: ScaleTransition(
              scale: _tutBounceAnim,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Character
                  Image.asset('assets/don_radar/don_radar_10.webp',
                    width: 200, height: 200, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  // Bubble
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 20, bottom: 40),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD4C5A0), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(60),
                            blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorAccentRed,
                              borderRadius: BorderRadius.circular(3)),
                            child: const Text('DON RADAR',
                              style: TextStyle(color: Colors.white, fontSize: 9,
                                fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '¡Lee el expediente y decide!\nDesliza o usa los botones de abajo.',
                            style: TextStyle(color: Color(0xFF2A1A0A), fontSize: 14,
                              fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom buttons glow
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _tutPulseAnim,
                builder: (_, __) => Container(
                  height: 80 + bottomPad,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withAlpha((_tutPulseAnim.value * 180).toInt()),
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorAccentRed.withAlpha((_tutPulseAnim.value * 60).toInt()),
                        blurRadius: 16, spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // "TOCA PARA CONTINUAR" + dots
          Positioned(
            top: topPad + 10,
            left: 0, right: 0,
            child: Column(
              children: [
                Text('TOCA PARA JUGAR',
                  style: TextStyle(color: Colors.white.withAlpha(130),
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == 3 ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == 3 ? colorAccentRed : Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
              ],
            ),
          ),

          // SALTAR
          Positioned(
            top: topPad + 10,
            right: 16,
            child: GestureDetector(
              onTap: _dismissTutorial,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(80),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: const Text('SALTAR',
                  style: TextStyle(color: Colors.white60, fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledCircleButton(
      PlayerChoice choice, IconData icon, Color color, double size, String label) {
    final isSelected = _selectedChoice == choice;

    return GestureDetector(
      onTap: () => _onChoice(choice),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : color.withAlpha(18),
              border: Border.all(
                color: isSelected ? color : color.withAlpha(100),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withAlpha(80), blurRadius: 12, spreadRadius: 2)]
                  : [BoxShadow(color: color.withAlpha(20), blurRadius: 4)],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: size * 0.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : color.withAlpha(180),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _onChoice(PlayerChoice choice) {
    if (_selectedChoice != null) return; // Prevent double tap

    // Haptic + sound feedback
    HapticFeedback.mediumImpact();
    SoundService.playTap();

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

    Future.delayed(const Duration(milliseconds: 150), () {
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
            isTutorial: TutorialService.isActive && TutorialService.currentStep == 4,
            onContinue: () {
              Navigator.of(context).pop();
              _nextCard();
            },
          ),
        ),
      ).then((result) {
        if (result == 'tutorial_done') {
          // Tutorial flow: go back to home
          if (mounted) Navigator.of(context).pop();
          return;
        }
        // When user presses back from RevealScreen, advance to next card
        if (mounted && _selectedChoice != null) {
          _nextCard();
        }
      });
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
