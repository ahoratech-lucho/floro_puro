import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:confetti/confetti.dart';
import '../models/candidate_card.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import '../utils/scoring.dart';
import '../widgets/radar_chart.dart';
import '../widgets/floro_meter.dart';
import '../widgets/dimension_bars.dart';
import '../widgets/source_link.dart';
import '../data/tutorial_service.dart';
import '../data/sound_service.dart';

class RevealScreen extends StatefulWidget {
  final CandidateCard card;
  final PlayerChoice playerChoice;
  final int cardNumber;
  final int totalCards;
  final int streak;
  final VoidCallback onContinue;
  final bool isTutorial;

  const RevealScreen({
    super.key,
    required this.card,
    required this.playerChoice,
    required this.cardNumber,
    required this.totalCards,
    this.streak = 0,
    required this.onContinue,
    this.isTutorial = false,
  });

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Accordion state for expediente
  final Set<String> _expandedSections = {};

  // Tutorial
  bool _showTutorial = false;
  int _tutStep = 0; // 0=Veredicto, 1=Índice, 2=Expediente, 3=Fuentes
  late AnimationController _tutPulseCtrl;
  late Animation<double> _tutPulseAnim;
  late AnimationController _tutBounceCtrl;
  late Animation<double> _tutBounceAnim;

  // Stamp animation
  late AnimationController _stampController;
  late Animation<double> _stampScaleAnim;
  late Animation<double> _stampRotationAnim;

  // Confetti
  late ConfettiController _confettiController;

  List<String> get _tabLabels {
    final labels = ['Veredicto', 'Índice'];
    if (_hasExpedienteData) labels.add('Expediente');
    if (_hasSourcesData) labels.add('Fuentes');
    return labels;
  }

  int get _totalPages => _tabLabels.length;

  bool get _hasExpedienteData =>
      widget.card.hasRealPatron ||
      (widget.card.hasRealFrase && widget.card.frase.trim() != widget.card.fraseNarrador.trim() && widget.card.frase.trim().length > 10) ||
      widget.card.fraseNarrador.trim().length > 10 ||
      widget.card.pensionAlimenticia == 'sí' ||
      widget.card.cambiosPartido.isNotEmpty ||
      widget.card.controversias.isNotEmpty ||
      widget.card.antecedentes.isNotEmpty ||
      widget.card.procesosJudiciales.isNotEmpty ||
      widget.card.senales.isNotEmpty;

  bool get _hasSourcesData =>
      widget.card.fuentes.isNotEmpty ||
      (widget.card.linkJNE != null && widget.card.linkJNE!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    // Stamp slam animation
    _stampController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _stampScaleAnim = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOutBack),
    );
    _stampRotationAnim = Tween<double>(begin: 0.3, end: -0.15).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOutBack),
    );

    // Confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Tutorial animations
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

    // Start animations after build
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _stampController.forward();
        final score = scoreChoice(widget.card, widget.playerChoice);
        if (score >= 2) {
          _confettiController.play();
          SoundService.playCorrect();
          if (score == 3) {
            Future.delayed(const Duration(milliseconds: 300), () {
              SoundService.playCelebration();
            });
          }
        } else {
          SoundService.playWrong();
        }
      }
    });

    // Tutorial check
    if (TutorialService.isActive && TutorialService.currentStep == 4) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _showTutorial = true);
          _tutBounceCtrl.forward();
        }
      });
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleSection(String key) {
    setState(() {
      if (_expandedSections.contains(key)) {
        _expandedSections.remove(key);
      } else {
        _expandedSections.add(key);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stampController.dispose();
    _confettiController.dispose();
    _tutPulseCtrl.dispose();
    _tutBounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = scoreChoice(widget.card, widget.playerChoice);

    return Scaffold(
      backgroundColor: colorBg,
      body: Stack(
        children: [
          SafeArea(
        child: Column(
          children: [
            // ===== TOP BAR =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _scorePill(score),
                  if (widget.streak >= 3) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorAccentGold.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🔥 x${widget.streak}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${widget.cardNumber} de ${widget.totalCards}',
                    style: const TextStyle(
                      color: colorTextTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ===== TAB BAR =====
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorCardBorder.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: _tabLabels.asMap().entries.map((entry) {
                  final i = entry.key;
                  final label = entry.value;
                  final isActive = i == _currentPage;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _goToPage(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isActive ? colorBgWhite : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isActive
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isActive ? colorAccentRed : colorTextTertiary,
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // ===== PAGE VIEW =====
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1Veredicto(),
                  _buildPage2Indice(),
                  if (_hasExpedienteData) _buildPage3Expediente(),
                  if (_hasSourcesData) _buildPage4Fuentes(),
                ],
              ),
            ),

            // ===== BOTTOM: Continue Button =====
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: colorBgWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    if (widget.isTutorial) {
                      // During tutorial: pop back, game screen will handle going home
                      TutorialService.advanceTo(5);
                      Navigator.of(context).pop('tutorial_done');
                    } else {
                      widget.onContinue();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: colorAccentRed, width: 2.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: Text(
                        widget.isTutorial
                            ? 'VOLVER AL INICIO →'
                            : widget.cardNumber < widget.totalCards
                                ? 'SIGUIENTE CANDIDATO →'
                                : 'VER RESULTADOS FINALES',
                        style: const TextStyle(
                          color: colorAccentRed,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFD4A854),
                Color(0xFFE8C547),
                colorAccentRed,
                colorPasaRaspando,
                Color(0xFF6C5CE7),
                Color(0xFF00B894),
              ],
              numberOfParticles: 25,
              gravity: 0.2,
            ),
          ),
          // Tutorial overlay
          if (_showTutorial)
            _buildRevealTutorial(),
        ],
      ),
    );
  }

  // Tutorial data for each sub-step
  static const _tutData = [
    {
      'tab': 'Veredicto',
      'image': 'assets/don_radar/don_radar_9.webp',
      'msg': 'Aquí comparas tu decisión con el resultado real.\n¿Acertaste o te vendieron floro?',
    },
    {
      'tab': 'Índice',
      'image': 'assets/don_radar/don_radar_4.webp',
      'msg': 'El Índice de Floro te dice qué tan turbio es el candidato, con su radar completo.',
    },
    {
      'tab': 'Expediente',
      'image': 'assets/don_radar/don_radar_6.webp',
      'msg': 'El expediente completo: controversias, cambios de partido, antecedentes y más.',
    },
    {
      'tab': 'Fuentes',
      'image': 'assets/don_radar/don_radar_8.webp',
      'msg': 'Toda la información viene de fuentes verificadas.\n¡Nada de floro aquí!',
    },
  ];

  void _nextTutStep() {
    // Only show steps for tabs that exist
    final availableTabs = _tabLabels;
    int nextStep = _tutStep + 1;

    // Skip steps for tabs that don't exist
    while (nextStep < 4) {
      final tabName = _tutData[nextStep]['tab'] as String;
      if (availableTabs.contains(tabName)) break;
      nextStep++;
    }

    if (nextStep >= 4) {
      // Sub-steps done — don't complete yet, step 5 (nav tutorial on home) pending
      setState(() => _showTutorial = false);
      return;
    }

    _tutBounceCtrl.reset();
    setState(() => _tutStep = nextStep);
    _tutBounceCtrl.forward();

    // Navigate to the corresponding tab
    final tabName = _tutData[nextStep]['tab'] as String;
    final tabIndex = _tabLabels.indexOf(tabName);
    if (tabIndex >= 0) {
      _goToPage(tabIndex);
    }
  }

  void _skipTutorial() {
    TutorialService.complete();
    setState(() => _showTutorial = false);
  }

  Widget _buildRevealTutorial() {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final data = _tutData[_tutStep];
    final availableTabs = _tabLabels;

    // Count how many tutorial steps are available
    int totalAvailable = 0;
    int currentAvailableIndex = 0;
    for (int i = 0; i < 4; i++) {
      if (availableTabs.contains(_tutData[i]['tab'])) {
        if (i == _tutStep) currentAvailableIndex = totalAvailable;
        totalAvailable++;
      }
    }

    return GestureDetector(
      onTap: _nextTutStep,
      child: Stack(
        children: [
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha(190)),
          ),

          // Highlight the current tab
          Positioned(
            top: topPad + 44,
            left: 12, right: 12,
            child: IgnorePointer(
              child: Container(
                height: 36,
                child: Row(
                  children: _tabLabels.asMap().entries.map((entry) {
                    final i = entry.key;
                    final label = entry.value;
                    final isHighlighted = label == data['tab'];
                    return Expanded(
                      child: AnimatedBuilder(
                        animation: _tutPulseAnim,
                        builder: (_, __) => Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? colorAccentRed.withAlpha((_tutPulseAnim.value * 80).toInt())
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: isHighlighted
                                ? Border.all(
                                    color: Colors.white.withAlpha((_tutPulseAnim.value * 255).toInt()),
                                    width: 2)
                                : null,
                            boxShadow: isHighlighted
                                ? [BoxShadow(
                                    color: colorAccentRed.withAlpha((_tutPulseAnim.value * 100).toInt()),
                                    blurRadius: 12, spreadRadius: 2)]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isHighlighted ? Colors.white : Colors.white38,
                                fontSize: 11,
                                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Don Radar + bubble
          Positioned.fill(
            child: ScaleTransition(
              scale: _tutBounceAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bubble
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorAccentRed,
                            borderRadius: BorderRadius.circular(4)),
                          child: const Text('DON RADAR',
                            style: TextStyle(color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 8),
                        Text(data['msg']!,
                          style: const TextStyle(color: Color(0xFF2A1A0A), fontSize: 15,
                            fontWeight: FontWeight.w500, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Character
                  Image.asset(data['image']!,
                    width: 280, height: 280, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ],
              ),
            ),
          ),

          // SALTAR
          Positioned(
            top: topPad + 10,
            right: 16,
            child: GestureDetector(
              onTap: _skipTutorial,
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

          // Step dots
          Positioned(
            bottom: bottomPad + 70,
            left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOCA PARA CONTINUAR',
                  style: TextStyle(color: Colors.white.withAlpha(110),
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalAvailable, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentAvailableIndex ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == currentAvailableIndex ? colorAccentRed : Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Photo expansion state
  bool _photoExpanded = false;

  // ============================
  // PAGE 1: EL VEREDICTO — "CASO RESUELTO"
  // ============================
  Widget _buildPage1Veredicto() {
    final card = widget.card;
    final nivelColor = colorForNivel(card.nivel);
    final ideal = idealChoice(card.respuestaIdeal);
    final isCorrect = ideal == widget.playerChoice;
    final score = scoreChoice(card, widget.playerChoice);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          const SizedBox(height: 6),

          // === MAIN CASE FILE CARD ===
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F0), // Paper color
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD0C8B8), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                // Case header bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open, color: Color(0xFFD4A854), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'CASO RESUELTO',
                        style: TextStyle(
                          color: Color(0xFFD4A854),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#${widget.cardNumber.toString().padLeft(3, '0')}',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                // Caricature area — BIG
                Stack(
                  children: [
                    // Caricature
                    SizedBox(
                      width: double.infinity,
                      height: 320,
                      child: ImageService.caricature(
                        card.caricatureWebpId,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Dark gradient at bottom for name
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 110,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Nivel STAMP — big, rotated, like stamped on the file
                    Positioned(
                      top: 16,
                      right: 12,
                      child: AnimatedBuilder(
                        animation: _stampController,
                        builder: (context, child) => Transform.scale(
                          scale: _stampScaleAnim.value,
                          child: Opacity(
                            opacity: _stampController.value.clamp(0.0, 1.0),
                            child: Transform.rotate(
                              angle: _stampRotationAnim.value,
                              child: child,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: nivelColor.withOpacity(0.12),
                            border: Border.all(color: nivelColor, width: 3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              // Double border effect
                              Positioned.fill(
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: nivelColor.withAlpha(60), width: 1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  card.nivel.toUpperCase(),
                                  style: TextStyle(
                                    color: nivelColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Cargo badge top-left
                    if (card.cargo != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                          ),
                          child: Text(
                            card.cargo!.toUpperCase(),
                            style: const TextStyle(
                              color: colorAccentInk,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                    // Name + party over image
                    Positioned(
                      bottom: 12,
                      left: 14,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (card.partido != null)
                            Row(
                              children: [
                                ImageService.partyLogo(card.partido, size: 16),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    card.partido!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // Real photo — tappable to expand
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _photoExpanded = !_photoExpanded),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          width: _photoExpanded ? 140 : 52,
                          height: _photoExpanded ? 140 : 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _photoExpanded ? const Color(0xFFD4A854) : Colors.white,
                              width: _photoExpanded ? 3 : 2.5,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                          ),
                          child: ClipOval(
                            child: ImageService.photo(
                              card.photoWebpId,
                              width: _photoExpanded ? 140 : 52,
                              height: _photoExpanded ? 140 : 52,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // === VEREDICTO SECTION ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFD0C8B8), width: 1)),
                  ),
                  child: Column(
                    children: [
                      // Dossier-style result header
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.verified : Icons.error_outline,
                            color: isCorrect ? colorPasaRaspando : colorAccentRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? 'INVESTIGACIÓN ACERTADA' : 'INVESTIGACIÓN FALLIDA',
                            style: TextStyle(
                              color: isCorrect ? colorPasaRaspando : colorAccentRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Choice comparison — side by side cards
                      Row(
                        children: [
                          Expanded(
                            child: _verdictCard(
                              'SEGÚN TÚ:',
                              choiceLabel(widget.playerChoice),
                              _colorFor(widget.playerChoice),
                              _iconFor(widget.playerChoice),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _verdictCard(
                              'RESULTADO REAL',
                              card.respuestaIdeal,
                              ideal != null ? _colorFor(ideal) : colorTextTertiary,
                              ideal != null ? _iconFor(ideal) : Icons.help_outline,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Teaser — mini fact to invite exploring expediente
                      if (_hasExpedienteData)
                        GestureDetector(
                          onTap: () => _goToPage(2),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E8),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE8D8B0)),
                            ),
                            child: Row(
                              children: [
                                const Text('🔍', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getTeaserFact(card),
                                    style: const TextStyle(
                                      color: colorTextPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: colorTextTertiary),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Verdict card for comparison
  Widget _verdictCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: colorTextTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // Icon for each choice
  IconData _iconFor(PlayerChoice choice) {
    switch (choice) {
      case PlayerChoice.puroFloro:
        return Icons.close;
      case PlayerChoice.banderaRoja:
        return Icons.flag;
      case PlayerChoice.sospechoso:
        return Icons.help_outline;
      case PlayerChoice.pasaRaspando:
        return Icons.check;
    }
  }

  // Teaser fact for the expediente preview
  String _getTeaserFact(CandidateCard card) {
    if (card.procesosJudiciales.isNotEmpty) {
      return 'Tiene ${card.procesosJudiciales.length} proceso(s) judicial(es). Ver expediente →';
    }
    if (card.controversias.isNotEmpty) {
      return '${card.controversias.length} controversia(s) documentada(s). Ver expediente →';
    }
    if (card.cambiosPartido.isNotEmpty) {
      return 'Ha cambiado de partido ${card.cambiosPartido.length} vez/veces. Ver expediente →';
    }
    if (card.pensionAlimenticia == 'sí') {
      return 'Registrado en REDAM por deuda de pensión. Ver expediente →';
    }
    if (card.antecedentes.isNotEmpty) {
      return 'Tiene antecedentes registrados. Ver expediente →';
    }
    if (card.hasRealPatron) {
      return 'Patrón detectado: ${card.patronDominante}. Ver expediente →';
    }
    return 'Revisa el expediente completo del candidato →';
  }

  // ============================
  // PAGE 2: ÍNDICE DE FLORO
  // ============================
  bool get _hasPuntajesData {
    final p = widget.card.puntajes;
    return p.isNotEmpty && p.values.any((v) => v > 0);
  }

  Widget _buildPage2Indice() {
    final card = widget.card;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Floro Meter — always shows (uses indiceFloro which always exists)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _pageCardDecoration(),
            child: Column(
              children: [
                _sectionHeader('ÍNDICE DE FLORO', colorAccentRed),
                const SizedBox(height: 12),
                FloroMeter(score: card.indiceFloro, nivel: card.nivel),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Radar + Bars — only if real puntajes data exists
          if (_hasPuntajesData) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _pageCardDecoration(),
              child: Column(
                children: [
                  _sectionHeader('RADAR DE DIMENSIONES', colorMuchoFloro),
                  const SizedBox(height: 12),
                  Center(child: FloroRadarChart(card: card, size: 190)),
                  const SizedBox(height: 14),
                  Container(height: 0.5, color: colorDivider),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('DESGLOSE',
                        style: TextStyle(color: colorTextTertiary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 8),
                  DimensionBars(card: card),
                ],
              ),
            ),
          ] else ...[
            // No puntajes — show explanation instead of empty chart
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD8D0C0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.analytics_outlined, color: colorTextMuted, size: 36),
                  const SizedBox(height: 10),
                  const Text(
                    'ANÁLISIS DIMENSIONAL\nNO DISPONIBLE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorTextTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este candidato no tiene suficientes datos públicos para generar un desglose dimensional.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorTextMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE8D8B0)),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El índice de floro (${card.indiceFloro}/100) se calcula en base a alertas, procesos y señales disponibles.',
                            style: const TextStyle(
                              color: colorTextSecondary,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================
  // PAGE 3: EXPEDIENTE (ACCORDION)
  // ============================
  Widget _buildPage3Expediente() {
    final card = widget.card;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3E8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8D0C0)),
            ),
            child: Row(
              children: [
                Container(width: 3, height: 16, color: colorAccentRed),
                const SizedBox(width: 8),
                const Text(
                  'EXPEDIENTE COMPLETO',
                  style: TextStyle(
                    color: colorAccentInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Accordion sections
          if (card.hasRealPatron)
            _accordionSection(
              key: 'patron',
              icon: Icons.psychology_outlined,
              title: 'Patrón Detectado',
              color: colorMuchoFloro,
              child: Text(
                card.patronDominante,
                style: const TextStyle(color: colorTextPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.5),
              ),
            ),

          if (card.hasRealFrase &&
              card.frase.trim().length > 15 &&
              card.frase.trim() != card.fraseNarrador.trim() &&
              RegExp(r'[a-záéíóúñA-ZÁÉÍÓÚÑ]').hasMatch(card.frase))
            _accordionSection(
              key: 'frase_candidato',
              icon: Icons.format_quote_outlined,
              title: 'El Candidato Dice',
              color: colorAccentInk,
              child: Text(
                '"${card.frase.trim()}"',
                style: const TextStyle(color: colorTextPrimary, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
              ),
            ),

          if (card.fraseNarrador.trim().length > 15 &&
              RegExp(r'[a-záéíóúñA-ZÁÉÍÓÚÑ]').hasMatch(card.fraseNarrador))
            _accordionSection(
              key: 'analisis',
              icon: Icons.search_outlined,
              title: 'Nuestro Análisis',
              color: colorAccentRed,
              child: Text(
                '"${card.fraseNarrador.trim()}"',
                style: const TextStyle(color: colorTextPrimary, fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
              ),
            ),

          if (card.pensionAlimenticia == 'sí')
            _accordionSection(
              key: 'pension',
              icon: Icons.child_care,
              title: 'Pensión Alimenticia',
              color: colorBanderaRoja,
              subtitle: '⚠️ DEBE PENSIÓN',
              child: const Text(
                'Registrado en el REDAM por deuda de pensión alimenticia.',
                style: TextStyle(color: colorTextPrimary, fontSize: 14, height: 1.5),
              ),
            ),

          if (card.cambiosPartido.isNotEmpty)
            _accordionSection(
              key: 'cambios',
              icon: Icons.swap_horiz_outlined,
              title: 'Cambios de Partido',
              color: colorMuchoFloro,
              count: card.cambiosPartido.length,
              child: _listItems(card.cambiosPartido, colorMuchoFloro),
            ),

          if (card.controversias.isNotEmpty)
            _accordionSection(
              key: 'controversias',
              icon: Icons.warning_amber_outlined,
              title: 'Controversias',
              color: colorAccentRed,
              count: card.controversias.length,
              child: _listItems(card.controversias, colorAccentRed),
            ),

          if (card.antecedentes.isNotEmpty)
            _accordionSection(
              key: 'antecedentes',
              icon: Icons.gavel_outlined,
              title: 'Antecedentes Penales',
              color: colorBanderaRoja,
              count: card.antecedentes.length,
              child: _listItems(card.antecedentes, colorBanderaRoja),
            ),

          if (card.procesosJudiciales.isNotEmpty)
            _accordionSection(
              key: 'procesos',
              icon: Icons.balance_outlined,
              title: 'Procesos Judiciales',
              color: colorAccentInk,
              count: card.procesosJudiciales.length,
              child: _listItems(card.procesosJudiciales, colorAccentInk),
            ),

          if (card.senales.isNotEmpty)
            _accordionSection(
              key: 'senales',
              icon: Icons.flag_outlined,
              title: 'Señales de Alerta',
              color: colorMuchoFloro,
              count: card.senales.length,
              child: _listItems(card.senales, colorMuchoFloro),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================
  // PAGE 4: FUENTES
  // ============================
  Widget _buildPage4Fuentes() {
    final card = widget.card;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _pageCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('FUENTES VERIFICADAS', colorDudoso),
                const SizedBox(height: 12),
                if (card.fuentes.isNotEmpty) SourceLinkList(sources: card.fuentes),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (card.linkJNE != null && card.linkJNE!.isNotEmpty)
            _actionButton(
              icon: Icons.open_in_new,
              label: 'VER HOJA DE VIDA EN JNE',
              onTap: () => _openUrl(card.linkJNE!),
            ),

          const SizedBox(height: 8),

          _actionButton(
            icon: Icons.share_outlined,
            label: 'COMPARTIR PERFIL',
            onTap: () => _shareCandidate(context),
          ),

          const SizedBox(height: 20),

          Text(
            'Datos: JNE Voto Informado + fuentes periodísticas',
            style: TextStyle(color: colorTextMuted, fontSize: 10),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================
  // ACCORDION WIDGET
  // ============================
  Widget _accordionSection({
    required String key,
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
    int? count,
    String? subtitle,
  }) {
    final isExpanded = _expandedSections.contains(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpanded ? color.withAlpha(80) : colorCardBorder,
          width: isExpanded ? 1 : 0.5,
        ),
      ),
      child: Column(
        children: [
          // Header — always visible, tappable
          GestureDetector(
            onTap: () => _toggleSection(key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isExpanded ? color.withAlpha(8) : Colors.transparent,
                borderRadius: isExpanded
                    ? const BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7))
                    : BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            color: isExpanded ? color : colorTextPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle,
                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (count != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      color: isExpanded ? color : colorTextTertiary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content — animated expand
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 0.5, color: color.withAlpha(40)),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ============================
  // SHARED WIDGETS
  // ============================

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 3, height: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colorAccentInk,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _listItems(List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final idx = entry.key;
        final text = entry.value;
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: idx < items.length - 1 ? 8 : 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(6),
            borderRadius: BorderRadius.circular(6),
            border: Border(left: BorderSide(color: color.withAlpha(80), width: 3)),
          ),
          child: Text(text, style: const TextStyle(color: colorTextPrimary, fontSize: 13, height: 1.4)),
        );
      }).toList(),
    );
  }

  Widget _scorePill(int score) {
    Color color;
    String text;
    IconData icon;

    if (score == 3) {
      color = colorPasaRaspando;
      text = '¡Exacto! +3';
      icon = Icons.check_circle_outline;
    } else if (score == 2) {
      color = colorDudoso;
      text = 'Casi... +2';
      icon = Icons.remove_circle_outline;
    } else if (score == 1) {
      color = colorMuchoFloro;
      text = 'Hmm... +1';
      icon = Icons.help_outline;
    } else {
      color = colorAccentRed;
      text = 'Fallaste +0';
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _choicePill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: colorTextTertiary, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _tagBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: colorAccentInk.withAlpha(8),
          border: Border.all(color: colorAccentInk.withAlpha(80), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: colorAccentInk),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: colorAccentInk, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _pageCardDecoration() {
    return BoxDecoration(
      color: colorBgWhite,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(3),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(3),
      ),
      border: Border.all(color: colorCardBorder, width: 0.5),
    );
  }

  Color _colorFor(PlayerChoice choice) {
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

  void _shareCandidate(BuildContext context) {
    final card = widget.card;
    final text = '🔍 ${card.nombre} (${card.partido ?? "Independiente"})\n'
        '📊 Índice de Floro: ${card.indiceFloro}/100 · Nivel: ${card.nivel}\n'
        '🚩 ${card.totalRedFlags} señales de alerta'
        '${card.pensionAlimenticia == "sí" ? " ⚠️ Debe pensión alimenticia" : ""}'
        '${card.cambiosPartido.isNotEmpty ? " 🔄 Cambió de partido" : ""}\n\n'
        '¿Conoces a tu candidato? Descúbrelo en Radar del Floro 🇵🇪\n'
        '#RadarDelFloro #Elecciones2026';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Perfil copiado al portapapeles')),
          ],
        ),
        backgroundColor: colorAccentInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}
