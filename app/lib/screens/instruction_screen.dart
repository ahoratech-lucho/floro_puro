import 'package:flutter/material.dart';
import '../data/tutorial_service.dart';
import '../utils/constants.dart';

class InstructionScreen extends StatefulWidget {
  final VoidCallback onStart;

  const InstructionScreen({super.key, required this.onStart});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen>
    with SingleTickerProviderStateMixin {
  bool _showTutorial = false;
  final GlobalKey _activarKey = GlobalKey();
  Rect? _activarRect;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    if (TutorialService.isActive && TutorialService.currentStep == 2) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _findActivarButton();
          setState(() => _showTutorial = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _findActivarButton() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ro = _activarKey.currentContext?.findRenderObject();
      if (ro is RenderBox && ro.hasSize) {
        final pos = ro.localToGlobal(Offset.zero);
        if (mounted) {
          setState(() {
            _activarRect = Rect.fromLTWH(pos.dx, pos.dy, ro.size.width, ro.size.height);
          });
        }
      }
    });
  }

  void _dismissTutorial() {
    TutorialService.advanceTo(3); // Next step is in game screen
    setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: _buildContent(context),
          ),
          // Tutorial overlay
          if (_showTutorial)
            _buildTutorialOverlay(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
          children: [
            // ===== TOP BAR — newspaper masthead =====
            Container(
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
                  Container(height: 4, color: colorAccentRed),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back_rounded, color: colorTextPrimary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'BRIEFING DE MISIÓN',
                            style: TextStyle(
                              color: colorTextPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorAccentRed.withAlpha(15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'CONFIDENCIAL',
                            style: TextStyle(
                              color: colorAccentRed,
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== SCROLLABLE CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    // ===== HEADLINE — newspaper style =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: colorBgWhite,
                        border: Border.all(color: colorCardBorder.withAlpha(100)),
                      ),
                      child: Column(
                        children: [
                          Container(height: 2, color: colorTextPrimary),
                          const SizedBox(height: 10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Detecta ',
                                  style: TextStyle(
                                    color: colorTextPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'malas prácticas',
                                  style: TextStyle(
                                    color: colorAccentRed,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: '\nantes de que te\nvendan ',
                                  style: TextStyle(
                                    color: colorTextPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300,
                                    height: 1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: 'floro',
                                  style: TextStyle(
                                    color: colorAccentRed,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(height: 1, color: colorTextPrimary),
                          const SizedBox(height: 2),
                          Container(height: 3, color: colorTextPrimary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== CÓMO JUGAR — recorte de periódico =====
                    Transform.rotate(
                      angle: -0.006,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E7), // Old paper
                              border: Border.all(color: const Color(0xFFD4C9A8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  color: colorTextPrimary,
                                  child: const Text(
                                    '▌PROTOCOLO DE INVESTIGACIÓN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      _step(
                                        '01',
                                        'Lee el expediente',
                                        'Revisa datos del candidato: cargo, controversias, antecedentes judiciales.',
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: const Color(0xFFD4C9A8),
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      _step(
                                        '02',
                                        'Emite tu veredicto',
                                        'Clasifícalo deslizando según tu instinto político.',
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: const Color(0xFFD4C9A8),
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      _step(
                                        '03',
                                        'Descubre la verdad',
                                        'Compara tu respuesta con nuestro análisis y fuentes verificadas.',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Pin
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
                    ),
                    const SizedBox(height: 16),

                    // ===== TUS OPCIONES — 4 veredictos =====
                    Transform.rotate(
                      angle: 0.005,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E7),
                              border: Border.all(color: const Color(0xFFD4C9A8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  color: colorAccentRed,
                                  child: const Text(
                                    '▌CLASIFICACIÓN DE VEREDICTOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      _verdictRow(
                                        '←',
                                        colorAccentRed,
                                        'PURO FLORO',
                                        'Definitivamente turbio',
                                      ),
                                      const SizedBox(height: 8),
                                      _verdictRow(
                                        '↓',
                                        colorBanderaRoja,
                                        'BANDERA ROJA',
                                        'Señales graves de alerta',
                                      ),
                                      const SizedBox(height: 8),
                                      _verdictRow(
                                        '↑',
                                        colorMuchoFloro,
                                        'SOSPECHOSO',
                                        'Algo no cuadra',
                                      ),
                                      const SizedBox(height: 8),
                                      _verdictRow(
                                        '→',
                                        colorPasaRaspando,
                                        'PASA RASPANDO',
                                        'Parece limpio... por ahora',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tape on top-right
                          Positioned(
                            top: -4,
                            right: 16,
                            child: Transform.rotate(
                              angle: 0.08,
                              child: Container(
                                width: 44,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade600.withAlpha(180),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ===== BOTTOM CTA =====
            Container(
              key: _activarKey,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: colorBgWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  if (_showTutorial) _dismissTutorial();
                  widget.onStart();
                },
                child: Transform.rotate(
                  angle: -0.012,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: colorAccentRed, width: 3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      children: [
                        // Subtle inner border for double-line stamp effect
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorAccentRed.withAlpha(80), width: 1),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                        // Text centered
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.radar, size: 20, color: colorAccentRed),
                              const SizedBox(width: 10),
                              const Text(
                                'ACTIVAR RADAR',
                                style: TextStyle(
                                  color: colorAccentRed,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
    );
  }

  Widget _step(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number badge — typewriter style
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: colorTextPrimary, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: colorTextPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: colorTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: const TextStyle(
                  color: colorTextTertiary,
                  fontSize: 11,
                  height: 1.3,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verdictRow(String arrow, Color color, String label, String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(8),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Row(
        children: [
          // Arrow direction
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                arrow,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: colorTextTertiary,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialOverlay(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
        children: [
          // Dark overlay with cutout for ACTIVAR RADAR button
          Positioned.fill(
            child: IgnorePointer(
              child: _activarRect != null
                  ? SizedBox.expand(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _CutoutPainter(
                          cutout: _activarRect!.inflate(6),
                          color: Colors.black.withAlpha(200),
                        ),
                      ),
                    )
                  : Container(color: Colors.black.withAlpha(200)),
            ),
          ),

          // Pulsing glow around ACTIVAR RADAR
          if (_activarRect != null)
            Positioned(
              left: _activarRect!.left - 6,
              top: _activarRect!.top - 6,
              width: _activarRect!.width + 12,
              height: _activarRect!.height + 12,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withAlpha((_pulseAnim.value * 255).toInt()),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorAccentRed.withAlpha((_pulseAnim.value * 180).toInt()),
                          blurRadius: 30, spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Don Radar + bubble
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Swipe hints
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tutorialChip(Icons.arrow_back_rounded, 'PURO FLORO', colorAccentRed),
                    const SizedBox(width: 16),
                    _tutorialChip(Icons.arrow_forward_rounded, 'PASA RASPANDO', colorPasaRaspando),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tutorialChip(Icons.flag_rounded, 'BANDERA ROJA', colorBanderaRoja),
                    const SizedBox(width: 12),
                    _tutorialChip(Icons.help_outline_rounded, 'SOSPECHOSO', colorMuchoFloro),
                  ],
                ),
                const SizedBox(height: 16),
                // Speech bubble
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4C5A0), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 16,
                        offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorAccentRed, borderRadius: BorderRadius.circular(4)),
                        child: const Text('DON RADAR',
                          style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Estos son tus veredictos para clasificar a cada candidato.\n¡Ahora presiona ACTIVAR RADAR para empezar!',
                        style: TextStyle(color: Color(0xFF2A1A0A), fontSize: 15,
                          fontWeight: FontWeight.w500, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Don Radar character
                Image.asset('assets/don_radar/don_radar_3.webp',
                  width: 280, height: 280, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
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

          // Step dots + hint — positioned ABOVE the ACTIVAR RADAR button
          Positioned(
            bottom: (_activarRect != null
                ? (MediaQuery.of(context).size.height - _activarRect!.top + 10)
                : bottomPad + 100),
            left: 0, right: 0,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('▼  PRESIONA ACTIVAR RADAR  ▼',
                    style: TextStyle(color: Colors.white.withAlpha(230),
                      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == 2 ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == 2 ? colorAccentRed : Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
    );
  }

  Widget _tutorialChip(IconData icon, String label, Color c) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: c.withAlpha((_pulseAnim.value * 220).toInt()), width: 2),
          boxShadow: [
            BoxShadow(
              color: c.withAlpha((_pulseAnim.value * 60).toInt()),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: c, fontSize: 11,
              fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _CutoutPainter extends CustomPainter {
  final Rect cutout;
  final Color color;
  _CutoutPainter({required this.cutout, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(8)));
    canvas.drawPath(Path.combine(PathOperation.difference, full, hole), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CutoutPainter old) => old.cutout != cutout;
}
