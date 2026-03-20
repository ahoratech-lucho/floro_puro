import 'package:flutter/material.dart';
import '../data/card_repository.dart';
import '../data/score_service.dart';
import '../data/badge_service.dart';
import '../data/theme_service.dart';
import '../data/sound_service.dart';
import '../main.dart' show themeService, routeObserver;
import '../utils/constants.dart';
import '../data/image_service.dart';
import 'instruction_screen.dart';
import 'game_screen.dart';
import 'about_screen.dart';
import 'explore_screen.dart';
import 'ranking_screen.dart';
import 'stats_screen.dart';
import 'badges_screen.dart';
import 'compare_screen.dart';
import 'parties_screen.dart';
import 'tutorial_screen.dart';
import '../data/tutorial_service.dart';
import '../widgets/tutorial_overlay.dart';

const int cardsQuickMode = 5;

class HomeScreen extends StatefulWidget {
  final CardRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, RouteAware {
  int _currentTab = 0;

  // Tab fade animation
  double _tabOpacity = 1.0;

  // Tutorial overlay
  bool _showTutorialOverlay = false;
  final GlobalKey _playButtonKey = GlobalKey();
  final GlobalKey<TutorialOverlayState> _tutorialOverlayKey = GlobalKey<TutorialOverlayState>();

  // Game filters
  String? _selectedCargo = 'PRESIDENTE';
  String? _selectedRegion;
  bool _onlyInteresting = false;
  bool _filtersExpanded = false;

  // Animations
  AnimationController? _stampController;
  Animation<double>? _stampScale;

  // Nav tutorial animation
  AnimationController? _navTutPulseCtrl;
  Animation<double>? _navTutPulseAnim;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _stampScale = Tween<double>(begin: 1.8, end: 1.0).animate(
      CurvedAnimation(parent: _stampController!, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _stampController?.forward();
    });

    _navTutPulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000), vsync: this,
    )..repeat(reverse: true);
    _navTutPulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _navTutPulseCtrl!, curve: Curves.easeInOut),
    );

    // Check if should show tutorial overlay
    _checkTutorial();
  }

  void _checkTutorial() {
    if (TutorialService.isActive && TutorialService.currentStep <= 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showTutorialOverlay = true);
      });
    }
  }

  bool _showNavTutorial = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when a route popped and this route becomes visible again
    if (TutorialService.isActive && TutorialService.currentStep == 5) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted && !_showNavTutorial) {
          setState(() => _showNavTutorial = true);
        }
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _stampController?.dispose();
    _navTutPulseCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _tabOpacity = 0.0;
          });
          Future.delayed(const Duration(milliseconds: 80), () {
            if (mounted) {
              setState(() {
                _currentTab = 0;
                _tabOpacity = 1.0;
              });
            }
          });
        }
      },
      child: Stack(
        children: [
          Scaffold(
        backgroundColor: colorBg,
        body: Stack(
          children: [
            SafeArea(
              child: AnimatedOpacity(
                opacity: _tabOpacity,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: IndexedStack(
                  index: _currentTab,
                  children: [
                    _buildJugarTab(),
                    ExploreScreen(repository: widget.repository),
                    StatsScreen(repository: widget.repository),
                    RankingScreen(repository: widget.repository),
                    _buildMasTab(),
                  ],
                ),
              ),
            ),
            // Tutorial overlay on top of everything (steps 0-1)
            if (_showTutorialOverlay)
              TutorialOverlay(
                key: _tutorialOverlayKey,
                playButtonKey: _playButtonKey,
                onComplete: () {
                  if (mounted) setState(() => _showTutorialOverlay = false);
                },
              ),
          ],
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorBgWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) {
            if (i == _currentTab) return;
            setState(() {
              _tabOpacity = 0.0;
            });
            Future.delayed(const Duration(milliseconds: 80), () {
              if (mounted) {
                setState(() {
                  _currentTab = i;
                  _tabOpacity = 1.0;
                });
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: colorAccentRed,
          unselectedItemColor: colorTextMuted,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline_rounded),
              activeIcon: Icon(Icons.play_circle_rounded),
              label: 'Jugar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Explorar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events_rounded),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              activeIcon: Icon(Icons.more_horiz_rounded),
              label: 'Más',
            ),
          ],
        ),
      ),
    ),  // close Scaffold
          // Nav tutorial overlay (step 5) — covers EVERYTHING including bottom nav
          if (_showNavTutorial)
            Positioned.fill(child: _buildNavTutorial()),
        ],
      ),  // close outer Stack
    );  // close PopScope
  }

  // ===== NAV TUTORIAL (step 5) =====
  Widget _buildNavTutorial() {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        TutorialService.complete();
        setState(() => _showNavTutorial = false);
      },
      child: Material(
        color: Colors.black.withAlpha(210),
        child: SizedBox(
          width: screenW,
          height: screenH,
          child: Stack(
            children: [
              // Don Radar grande abajo a la derecha
              Positioned(
                right: -20,
                bottom: bottomPad + 50,
                child: IgnorePointer(
                  child: Image.asset('assets/don_radar/don_radar_7.webp',
                    width: 280, height: 280, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ),

              // Speech bubble centrado
              Positioned(
                left: 16, right: 16,
                bottom: bottomPad + 280,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4C5A0), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(60),
                        blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '¡Último tip! Estas son tus herramientas:',
                        style: TextStyle(color: Color(0xFF2A1A0A), fontSize: 15,
                          fontWeight: FontWeight.w700, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      _navItem(Icons.play_circle_rounded, 'Jugar', 'Investiga candidatos y gana puntos', colorAccentRed),
                      const SizedBox(height: 10),
                      _navItem(Icons.search_rounded, 'Explorar', 'Busca y filtra todos los candidatos', colorAccentInk),
                      const SizedBox(height: 10),
                      _navItem(Icons.bar_chart_rounded, 'Stats', 'Tu progreso y estadísticas', colorMuchoFloro),
                      const SizedBox(height: 10),
                      _navItem(Icons.emoji_events_rounded, 'Ranking', 'Compite con otros investigadores', const Color(0xFFD4A854)),
                      const SizedBox(height: 10),
                      _navItem(Icons.more_horiz_rounded, 'Más', 'Ajustes, tutorial y más opciones', colorTextTertiary),
                    ],
                  ),
                ),
              ),

              // Bottom nav glow
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _navTutPulseAnim!,
                    builder: (_, __) => Container(
                      height: 60 + bottomPad,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withAlpha((_navTutPulseAnim!.value * 220).toInt()),
                            width: 3,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorAccentRed.withAlpha((_navTutPulseAnim!.value * 100).toInt()),
                            blurRadius: 20, spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // SALTAR
              Positioned(
                top: topPad + 10,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    TutorialService.complete();
                    setState(() => _showNavTutorial = false);
                  },
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

              // Hint
              Positioned(
                top: topPad + 10,
                left: 0, right: 80,
                child: Center(
                  child: Text('TOCA PARA FINALIZAR',
                    style: TextStyle(color: Colors.white.withAlpha(130),
                      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String title, String desc, Color color) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: TextStyle(color: const Color(0xFF2A1A0A), fontSize: 13,
                  fontWeight: FontWeight.w800)),
              Text(desc,
                style: const TextStyle(color: Color(0xFF8A7A5A), fontSize: 11,
                  height: 1.2)),
            ],
          ),
        ),
      ],
    );
  }

  // ===== TAB: JUGAR =====
  Widget _buildJugarTab() {
    final repo = widget.repository;
    final totalCards = repo.totalCards;
    final interestingCount = repo.interestingCards.length;

    return Column(
      children: [
        // ===== TABLOID HEADER =====
        _buildTabloidHeader(),

        // ===== SCROLLABLE CONTENT =====
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ===== HERO CTA — RECORTE DE PERIÓDICO =====
                _buildHeroCTA(totalCards, interestingCount),
                const SizedBox(height: 14),

                // ===== FILTROS COLAPSABLES =====
                _buildFiltersSection(repo),
                const SizedBox(height: 14),

                // ===== CÓMO FUNCIONA (mini tutorial) =====
                _buildHowItWorks(),
                const SizedBox(height: 14),

                // ===== BARRA DE PROGRESO =====
                _buildProgressBar(totalCards),
                const SizedBox(height: 14),

                // ===== DATO CURIOSO =====
                _buildDatoCurioso(totalCards, interestingCount, repo),
                const SizedBox(height: 14),

                // ===== CANDIDATO DESTACADO (teaser) =====
                _buildCandidatoDestacado(repo),
                const SizedBox(height: 14),

                // ===== PLAYER STATS (if played) =====
                if (ScoreService.hasPlayed) ...[
                  _buildPlayerStats(),
                  const SizedBox(height: 14),
                ],

                // ===== FOOTER EDITORIAL =====
                _buildFooter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== TABLOID HEADER =====
  Widget _buildTabloidHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorBgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Red top bar
          Container(height: 4, color: colorAccentRed),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo mark — red circle with "R" cut out
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorAccentRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title stack
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RADAR DEL FLORO',
                        style: TextStyle(
                          color: colorTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(height: 1.5, color: colorAccentRed),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'EDICIÓN ESPECIAL',
                            style: TextStyle(
                              color: colorTextTertiary,
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          Text(
                            'PERÚ 2026',
                            style: TextStyle(
                              color: colorAccentRed,
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
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
        ],
      ),
    );
  }

  // ===== HERO CTA =====
  Widget _buildHeroCTA(int totalCards, int interestingCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main card with clipped corner
        ClipPath(
          clipper: _CornerCutClipper(cutSize: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: colorAccentRed,
            ),
            child: CustomPaint(
              painter: _DiagonalLinesPainter(
                color: Colors.white.withAlpha(12),
                spacing: 8,
                strokeWidth: 1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline — mixed weights
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '¿Puedes\ndetectar ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'el floro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: '\npolítico?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Stats line with dot separator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '$totalCards investigados',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withAlpha(30),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '⚠ $interestingCount con alertas',
                          style: TextStyle(
                            color: Colors.yellow.shade100,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // PLAY BUTTONS — newspaper ad style
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          key: _playButtonKey,
                          child: _buildPlayButton(
                            label: 'DETECTAR FLORO',
                            icon: Icons.play_arrow_rounded,
                            count: cardsPerRound,
                            filled: true,
                            onTap: () {
                              if (_showTutorialOverlay) {
                                // Tutorial active: advance to step 2 (instruction screen)
                                _tutorialOverlayKey.currentState?.onPlayButtonPressed();
                                _startGame(cardsPerRound);
                              } else {
                                _startGame(cardsPerRound);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildPlayButton(
                          label: 'RÁPIDO',
                          icon: Icons.bolt_rounded,
                          count: cardsQuickMode,
                          filled: false,
                          onTap: () => _startGame(cardsQuickMode),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // STAMP — rotated seal
        if (_stampScale != null)
          Positioned(
            top: 12,
            right: 12,
            child: AnimatedBuilder(
              animation: _stampScale!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _stampScale!.value,
                  child: Transform.rotate(
                    angle: 0.18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'EXCLUSIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Decorative tape effect on top-left
        Positioned(
          top: -3,
          left: 20,
          child: Transform.rotate(
            angle: -0.05,
            child: Container(
              width: 50,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.yellow.shade600.withAlpha(180),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton({
    required String label,
    required IconData icon,
    required int count,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          border: Border.all(
            color: filled ? Colors.white : Colors.white.withAlpha(120),
            width: filled ? 0 : 1.5,
          ),
          // Asymmetric border radius — one corner sharper
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: filled ? colorAccentRed : Colors.white),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: filled ? colorAccentRed : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$count cartas',
              style: TextStyle(
                color: filled ? colorAccentRed.withAlpha(140) : Colors.white.withAlpha(140),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== FILTERS SECTION =====
  Widget _buildFiltersSection(CardRepository repo) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorBgWhite,
        border: Border.all(color: colorCardBorder.withAlpha(100)),
        // Asymmetric corners
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(2),
        ),
      ),
      child: Column(
        children: [
          // Header — always visible
          GestureDetector(
            onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _filtersExpanded ? colorBg : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorAccentRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FILTRAR POR CARGO',
                    style: TextStyle(
                      color: colorTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCargo != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorAccentRed.withAlpha(15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        _selectedCargo!,
                        style: const TextStyle(
                          color: colorAccentRed,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  AnimatedRotation(
                    turns: _filtersExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorTextTertiary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _cargoChip('Todos', null),
                      ...repo.cargoTypes.map((c) => _cargoChip(c, c)),
                    ],
                  ),
                  if ((_selectedCargo == 'DIPUTADO' || _selectedCargo == 'SENADOR') &&
                      repo.regionTypesForCargo(_selectedCargo).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(height: 0.5, color: colorCardBorder),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _regionChip('Todas', null),
                        ...repo.regionTypesForCargo(_selectedCargo).map((r) => _regionChip(r, r)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Sospechosos toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _onlyInteresting ? colorAccentRed.withAlpha(10) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _onlyInteresting ? colorAccentRed.withAlpha(60) : colorCardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gpp_maybe_outlined,
                          color: _onlyInteresting ? colorAccentRed : colorTextTertiary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Solo sospechosos',
                            style: TextStyle(
                              color: _onlyInteresting ? colorAccentRed : colorTextSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                          child: Switch(
                            value: _onlyInteresting,
                            onChanged: (v) => setState(() => _onlyInteresting = v),
                            activeColor: colorAccentRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                _filtersExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ===== CÓMO FUNCIONA =====
  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: colorCardBorder.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: colorAccentInk,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '¿CÓMO FUNCIONA?',
                style: TextStyle(
                  color: colorTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _howStep(
                Icons.close_rounded,
                'Floro',
                colorAccentRed,
              ),
              const SizedBox(width: 4),
              _howStep(
                Icons.check_rounded,
                'Pasa',
                colorPasaRaspando,
              ),
              const SizedBox(width: 4),
              _howStep(
                Icons.help_outline_rounded,
                'Dudoso',
                colorMuchoFloro,
              ),
              const SizedBox(width: 4),
              _howStep(
                Icons.flag_rounded,
                'Bandera\nRoja',
                colorBanderaRoja,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: colorBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Desliza o usa los botones · Gana puntos por acertar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorTextTertiary,
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _howStep(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BARRA DE PROGRESO =====
  Widget _buildProgressBar(int totalCards) {
    final evaluated = ScoreService.totalCardsPlayed;
    final percent = totalCards > 0 ? (evaluated / totalCards).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(2),
        ),
        border: Border.all(color: colorCardBorder.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: colorAccentRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TU PROGRESO',
                style: TextStyle(
                  color: colorTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                '$evaluated / $totalCards candidatos',
                style: const TextStyle(
                  color: colorTextTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: colorBg,
                ),
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [colorAccentRed, Color(0xFFE53935)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            evaluated == 0
                ? '¡Empieza a evaluar candidatos!'
                : '${(percent * 100).toStringAsFixed(1)}% completado — ¡sigue investigando!',
            style: const TextStyle(
              color: colorTextTertiary,
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ===== DATO CURIOSO =====
  Widget _buildDatoCurioso(int totalCards, int interestingCount, CardRepository repo) {
    // Calculate some fun stats
    final percentSospechosos = totalCards > 0
        ? (interestingCount / totalCards * 100).toStringAsFixed(0)
        : '0';
    final presidentes = repo.cardsByCargo('PRESIDENTE').length;

    // Rotate between different facts
    final facts = [
      '🔍 El $percentSospechosos% de candidatos tiene alguna alerta o controversia',
      '🏛️ Hay $presidentes candidatos a la presidencia registrados',
      '⚠️ $interestingCount candidatos tienen señales de alerta',
      '📊 Evalúa candidatos para desbloquear logros secretos',
    ];
    // Pick based on current minute for rotation
    final fact = facts[DateTime.now().minute % facts.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorAccentInk.withAlpha(8),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: colorAccentInk, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              fact,
              style: const TextStyle(
                color: colorTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CANDIDATO DESTACADO — RECORTE DE PERIÓDICO =====
  Widget _buildCandidatoDestacado(CardRepository repo) {
    final interesting = repo.interestingCards;
    if (interesting.isEmpty) return const SizedBox.shrink();

    final candidate = interesting[DateTime.now().second % interesting.length];
    final nivelColor = colorForNivel(candidate.nivel);
    final slug = candidate.caricatureWebpId;

    return GestureDetector(
      onTap: () => _startGame(cardsPerRound),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main "newspaper clipping" container
          Transform.rotate(
            angle: -0.008, // Slight tilt like a pasted clipping
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7), // Yellowish old paper
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                  // Inner shadow effect via border
                ],
                border: Border.all(color: const Color(0xFFD4C9A8), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar — like newspaper section header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    color: colorTextPrimary,
                    child: Row(
                      children: const [
                        Text(
                          '▌INVESTIGACIÓN ESPECIAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Caricature image — like newspaper photo
                        Container(
                          width: 64,
                          height: 78,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFBBB49E), width: 1),
                          ),
                          child: ClipRect(
                            child: ImageService.caricature(
                              slug,
                              width: 64,
                              height: 78,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Text content — headline style
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name as headline
                              Text(
                                candidate.nombre.toUpperCase(),
                                style: const TextStyle(
                                  color: colorTextPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  height: 1.15,
                                  fontFamily: 'Georgia',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Partido + cargo like byline
                              Text(
                                '${candidate.partido ?? "Sin partido"} · ${candidate.cargo ?? ""}',
                                style: const TextStyle(
                                  color: colorTextTertiary,
                                  fontSize: 9,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (candidate.controversias.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                // Controversy as "article excerpt"
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: nivelColor.withAlpha(10),
                                    border: Border(
                                      left: BorderSide(color: nivelColor, width: 2),
                                    ),
                                  ),
                                  child: Text(
                                    candidate.controversias.first,
                                    style: TextStyle(
                                      color: nivelColor.withAlpha(200),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom bar — CTA
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFD4C9A8), width: 0.5),
                      ),
                    ),
                    child: const Text(
                      '¿Puro floro o pasa raspando? Toca para investigar →',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorTextTertiary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Red "ALERTA" stamp — rotated on top
          Positioned(
            top: -4,
            right: 12,
            child: Transform.rotate(
              angle: 0.15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: nivelColor, width: 1.5),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  candidate.nivel.toUpperCase(),
                  style: TextStyle(
                    color: nivelColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

          // Pin/tape on top-left
          Positioned(
            top: -5,
            left: 14,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colorAccentRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PLAYER STATS =====
  Widget _buildPlayerStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: colorCardBorder.withAlpha(100)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: colorAccentGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'TUS ESTADÍSTICAS',
                style: TextStyle(
                  color: colorTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('${ScoreService.bestPercent}%', 'Mejor score', colorPasaRaspando),
              const SizedBox(width: 6),
              _statCard('🔥 ${ScoreService.bestStreak}', 'Mejor racha', colorAccentGold),
              const SizedBox(width: 6),
              _statCard('${ScoreService.totalGames}', 'Partidas', colorAccentInk),
            ],
          ),
          if (ScoreService.bestTitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colorCardBorder.withAlpha(80)),
                ),
              ),
              child: Text(
                'Mejor rango: "${ScoreService.bestTitle}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: colorTextTertiary,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== FOOTER =====
  Widget _buildFooter() {
    return Column(
      children: [
        // Decorative newspaper rule
        Row(
          children: [
            Expanded(child: Container(height: 0.5, color: colorDivider)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '◆',
                style: TextStyle(color: colorDivider, fontSize: 6),
              ),
            ),
            Expanded(child: Container(height: 0.5, color: colorDivider)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Datos: JNE Voto Informado + fuentes periodísticas',
          style: TextStyle(
            color: colorTextTertiary,
            fontSize: 8,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Proyecto satírico e informativo · No somos medio de comunicación',
          style: TextStyle(color: colorTextMuted, fontSize: 7),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ===== TAB: MÁS =====
  Widget _buildMasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: colorAccentRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'MÁS',
                style: TextStyle(
                  color: colorTextPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _navButton(
            icon: Icons.school_outlined,
            label: 'Como jugar',
            subtitle: 'Don Radar te ensena paso a paso',
            color: colorAccentRed,
            onTap: () async {
              await TutorialService.reset();
              setState(() {
                _currentTab = 0;
                _showTutorialOverlay = true;
              });
            },
          ),
          const SizedBox(height: 10),
          _navButton(
            icon: Icons.account_balance_outlined,
            label: 'Partidos Políticos',
            subtitle: 'Análisis de todos los partidos',
            color: colorAccentInk,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PartiesScreen(repository: widget.repository)),
            ),
          ),
          const SizedBox(height: 10),
          _navButton(
            icon: Icons.compare_arrows_outlined,
            label: 'Comparador',
            subtitle: 'Cara a cara entre candidatos',
            color: const Color(0xFF6C5CE7),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CompareScreen(repository: widget.repository)),
            ),
          ),
          const SizedBox(height: 10),
          _navButton(
            icon: Icons.military_tech_outlined,
            label: 'Logros',
            subtitle: '${BadgeService.totalUnlocked}/${BadgeService.totalBadges} desbloqueados',
            color: colorAccentGold,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BadgesScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _navButton(
            icon: Icons.info_outline,
            label: 'Acerca de',
            subtitle: 'Términos y condiciones',
            color: colorTextSecondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          const SizedBox(height: 20),

          // Settings
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colorTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AJUSTES',
                style: TextStyle(
                  color: colorTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    themeService.toggle();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorBgWhite,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(2),
                      ),
                      border: Border.all(color: colorCardBorder.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          themeService.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: colorTextTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          themeService.isDark ? 'Modo claro' : 'Modo oscuro',
                          style: const TextStyle(
                            color: colorTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    SoundService.toggle();
                    if (SoundService.enabled) SoundService.playTap();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorBgWhite,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(2),
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(8),
                      ),
                      border: Border.all(color: colorCardBorder.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          SoundService.enabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                          color: colorTextTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SoundService.enabled ? 'Sonido ON' : 'Sonido OFF',
                          style: const TextStyle(
                            color: colorTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== WIDGET HELPERS =====

  Widget _cargoChip(String label, String? cargo) {
    final selected = _selectedCargo == cargo;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCargo = cargo;
        if (cargo != 'DIPUTADO' && cargo != 'SENADOR') _selectedRegion = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colorTextPrimary : colorBgWhite,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? colorTextPrimary : colorCardBorder,
            width: 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 3, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: selected ? Colors.white : colorTextSecondary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _regionChip(String label, String? region) {
    final selected = _selectedRegion == region;
    return GestureDetector(
      onTap: () => setState(() => _selectedRegion = region),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colorAccentRed : colorBgWhite,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? colorAccentRed : colorCardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : colorTextSecondary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(8),
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(color: color, width: 3),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
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

  Widget _navButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(2),
          ),
          border: Border.all(color: color.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: colorTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: colorTextTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withAlpha(100), size: 18),
          ],
        ),
      ),
    );
  }

  void _startGame(int count) {
    final cards = widget.repository.selectRound(
      count: count,
      cargoFilter: _selectedCargo,
      regionFilter: _selectedRegion,
      onlyInteresting: _onlyInteresting,
    );

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('No hay cartas con ese filtro'),
            ],
          ),
          backgroundColor: colorAccentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InstructionScreen(
          onStart: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(cards: cards),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===== CUSTOM CLIPPERS & PAINTERS =====

/// Clips the top-right corner diagonally
class _CornerCutClipper extends CustomClipper<Path> {
  final double cutSize;
  _CornerCutClipper({this.cutSize = 24});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, cutSize);
    path.lineTo(size.width, size.height);
    // Bottom-left rounded
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Paints subtle diagonal lines for texture
class _DiagonalLinesPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;

  _DiagonalLinesPainter({
    required this.color,
    this.spacing = 10,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
