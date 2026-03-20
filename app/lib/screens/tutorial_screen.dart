import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Tutorial interactivo con Don Radar que enseña a jugar
class TutorialScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialScreen({super.key, required this.onComplete});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();

  /// Returns true if the user has already seen the tutorial
  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_seen') ?? false;
  }

  /// Marks tutorial as seen
  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
  }
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnim;
  late Animation<double> _bounceAnim;

  final List<_TutorialStep> _steps = [
    _TutorialStep(
      image: 'assets/don_radar/don_radar_1.webp',
      title: '!Oe! Soy Don Radar',
      subtitle: 'Tu guia de investigacion politica',
      description:
          'Te voy a ensenar como detectar el floro de los candidatos. Presta atencion, que esto es serio... bueno, casi.',
      bgColor: const Color(0xFF2C3E50),
      accentColor: colorAccentRed,
    ),
    _TutorialStep(
      image: 'assets/don_radar/don_radar_2.webp',
      title: 'Revisa la carta',
      subtitle: 'Cada candidato tiene su expediente',
      description:
          'Te mostrare la caricatura, nombre, partido y cargo. Con eso tienes que decidir: es floro o pasa?',
      bgColor: const Color(0xFF1A3A4A),
      accentColor: colorAccentInk,
    ),
    _TutorialStep(
      image: 'assets/don_radar/don_radar_3.webp',
      title: 'Desliza para decidir',
      subtitle: 'Izquierda o derecha, tu decides',
      description:
          'Desliza a la IZQUIERDA si es PURO FLORO.\nDesliza a la DERECHA si crees que PASA RASPANDO.',
      bgColor: const Color(0xFF2D4A2D),
      accentColor: colorMuchoFloro,
      showSwipeHint: true,
    ),
    _TutorialStep(
      image: 'assets/don_radar/don_radar_5.webp',
      title: 'Algo no cuadra?',
      subtitle: 'Usa los botones especiales',
      description:
          'Si detectas algo turbio, presiona SOSPECHOSO.\nSi es grave, marca BANDERA ROJA!',
      bgColor: const Color(0xFF4A2D2D),
      accentColor: colorBanderaRoja,
      showButtons: true,
    ),
    _TutorialStep(
      image: 'assets/don_radar/don_radar_9.webp',
      title: 'Descubre la verdad',
      subtitle: 'El expediente completo se revela',
      description:
          'Despues de tu decision, te muestro TODO: controversias, cambios de partido, antecedentes y mas.',
      bgColor: const Color(0xFF3A2D4A),
      accentColor: colorDudoso,
    ),
    _TutorialStep(
      image: 'assets/don_radar/don_radar_7.webp',
      title: 'Sube en el ranking!',
      subtitle: 'Mientras mas aciertes, mejor',
      description:
          'Gana puntos por cada decision correcta. Compite y demuestra que conoces a tus candidatos!',
      bgColor: const Color(0xFF2C4A3A),
      accentColor: const Color(0xFF27AE60),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= _steps.length) {
      _completeTutorial();
      return;
    }
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _completeTutorial() async {
    await TutorialScreen.markAsSeen();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _steps[_currentPage].bgColor,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _NewspaperPatternPainter(
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),

          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _steps.length,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _fadeController.reset();
              _fadeController.forward();
              _bounceController.reset();
              _bounceController.forward();
            },
            itemBuilder: (context, index) => _buildPage(_steps[index]),
          ),

          // Skip button (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _completeTutorial,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                child: const Text(
                  'SALTAR',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Row(
                children: [
                  // Page dots
                  Row(
                    children: List.generate(
                      _steps.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? _steps[_currentPage].accentColor
                              : Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Next / Start button
                  GestureDetector(
                    onTap: () => _goToPage(_currentPage + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == _steps.length - 1 ? 28 : 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _steps[_currentPage].accentColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _steps[_currentPage].accentColor.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _steps.length - 1
                                ? 'ACTIVAR RADAR'
                                : 'SIGUIENTE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentPage == _steps.length - 1
                                ? Icons.radar
                                : Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_TutorialStep step) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Column(
          children: [
            const Spacer(flex: 1),

            // Don Radar image with bounce animation
            ScaleTransition(
              scale: _bounceAnim,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(10),
                  border: Border.all(
                    color: step.accentColor.withAlpha(60),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: step.accentColor.withAlpha(30),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      step.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 80,
                        color: step.accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Text content with fade animation
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Subtitle chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: step.accentColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: step.accentColor.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      step.subtitle.toUpperCase(),
                      style: TextStyle(
                        color: step.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    step.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),

                  // Description
                  Text(
                    step.description,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 15,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Swipe hint arrows
                  if (step.showSwipeHint) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _swipeHintChip(
                          Icons.arrow_back,
                          'PURO FLORO',
                          colorAccentRed,
                        ),
                        const SizedBox(width: 20),
                        _swipeHintChip(
                          Icons.arrow_forward,
                          'PASA RASPANDO',
                          colorDudoso,
                        ),
                      ],
                    ),
                  ],

                  // Button hints
                  if (step.showButtons) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buttonHintChip(
                          Icons.flag,
                          'BANDERA ROJA',
                          colorBanderaRoja,
                        ),
                        const SizedBox(width: 16),
                        _buttonHintChip(
                          Icons.help_outline,
                          'SOSPECHOSO',
                          colorMuchoFloro,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _swipeHintChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonHintChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final Color bgColor;
  final Color accentColor;
  final bool showSwipeHint;
  final bool showButtons;

  const _TutorialStep({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bgColor,
    required this.accentColor,
    this.showSwipeHint = false,
    this.showButtons = false,
  });
}

/// Subtle newspaper line pattern for the tutorial background
class _NewspaperPatternPainter extends CustomPainter {
  final Color color;

  _NewspaperPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Horizontal lines like newspaper columns
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
