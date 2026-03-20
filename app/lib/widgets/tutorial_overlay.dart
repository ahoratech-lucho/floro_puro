import 'package:flutter/material.dart';
import '../data/tutorial_service.dart';
import '../utils/constants.dart';

/// Tutorial overlay for the HOME SCREEN only (steps 0-1).
/// Step 0: Don Radar introduces himself
/// Step 1: Points to the play button — user presses the REAL button
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final GlobalKey playButtonKey;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    required this.playButtonKey,
  });

  @override
  TutorialOverlayState createState() => TutorialOverlayState();
}

class TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _localStep = 0; // 0 = intro, 1 = button
  Rect? _btnRect;

  late AnimationController _pulseCtrl;
  late AnimationController _bounceCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _bounceAnim;

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

    _bounceCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
    _bounceCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _findButton());
  }

  void _findButton() {
    final ro = widget.playButtonKey.currentContext?.findRenderObject();
    if (ro is RenderBox && ro.hasSize) {
      final pos = ro.localToGlobal(Offset.zero);
      if (mounted) {
        setState(() {
          _btnRect = Rect.fromLTWH(pos.dx, pos.dy, ro.size.width, ro.size.height);
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  /// Called externally when user presses the play button during step 1
  void onPlayButtonPressed() {
    // Advance tutorial to step 2 (instruction screen will show it)
    TutorialService.advanceTo(2);
    // Remove the overlay
    widget.onComplete();
  }

  void _goToButtonStep() {
    _bounceCtrl.reset();
    setState(() => _localStep = 1);
    TutorialService.advanceTo(1);
    _bounceCtrl.forward();
    // Re-find button position in case layout changed
    WidgetsBinding.instance.addPostFrameCallback((_) => _findButton());
  }

  void _skip() {
    TutorialService.complete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isButtonStep = _localStep == 1;

    return Stack(
      children: [
        // ===== OVERLAY =====
        if (isButtonStep)
          // Button step: IgnorePointer so real button works
          Positioned.fill(
            child: IgnorePointer(
              child: _btnRect != null
                  ? SizedBox.expand(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _CutoutPainter(
                          cutout: _btnRect!.inflate(8),
                          color: Colors.black.withAlpha(200),
                        ),
                      ),
                    )
                  : Container(color: Colors.black.withAlpha(200)),
            ),
          )
        else
          // Intro step: tap to continue
          Positioned.fill(
            child: GestureDetector(
              onTap: _goToButtonStep,
              child: Container(color: Colors.black.withAlpha(200)),
            ),
          ),

        // ===== PULSING GLOW around button (step 1) =====
        if (isButtonStep && _btnRect != null)
          Positioned(
            left: _btnRect!.left - 8,
            top: _btnRect!.top - 8,
            width: _btnRect!.width + 16,
            height: _btnRect!.height + 16,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
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

        // ===== CONTENT =====
        IgnorePointer(
          child: ScaleTransition(
            scale: _bounceAnim,
            child: isButtonStep
                ? _buildButtonContent(topPad, bottomPad)
                : _buildIntroContent(),
          ),
        ),

        // ===== SALTAR =====
        Positioned(
          top: topPad + 10,
          right: 16,
          child: GestureDetector(
            onTap: _skip,
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

        // ===== STEP INDICATOR =====
        Positioned(
          bottom: bottomPad + 70,
          left: 0, right: 0,
          child: IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isButtonStep ? '▼  PRESIONA EL BOTÓN  ▼' : 'TOCA PARA CONTINUAR',
                  style: TextStyle(
                    color: Colors.white.withAlpha(isButtonStep ? 230 : 110),
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                // 3 dots: home-intro, home-button, instruction-screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _localStep ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _localStep ? colorAccentRed : Colors.white.withAlpha(40),
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

  // ===== INTRO (step 0) =====
  Widget _buildIntroContent() {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _bubble('¡Oe! Soy Don Radar, periodista investigador.\nTe voy a enseñar a detectar el floro político.'),
          const SizedBox(height: 10),
          Image.asset('assets/don_radar/don_radar_1.webp',
            width: 320, height: 320, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ===== BUTTON STEP (step 1) =====
  Widget _buildButtonContent(double topPad, double bottomPad) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Bubble at top
          Positioned(
            top: topPad + 50,
            left: 0, right: 0,
            child: _bubble('¡Presiona el botón para empezar tu primera investigación!'),
          ),
          // Pulsing arrow
          if (_btnRect != null)
            Positioned(
              left: _btnRect!.left + _btnRect!.width / 2 - 18,
              top: _btnRect!.top - 48,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, __) => Opacity(
                  opacity: _pulseAnim.value,
                  child: const Icon(Icons.keyboard_double_arrow_down_rounded,
                    color: Colors.white, size: 36),
                ),
              ),
            ),
          // Big Don Radar at bottom-right
          Positioned(
            right: -30,
            bottom: bottomPad + 30,
            child: Image.asset('assets/don_radar/don_radar_2.webp',
              width: 380, height: 380, fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String msg) {
    return Container(
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
          Text(msg,
            style: const TextStyle(color: Color(0xFF2A1A0A), fontSize: 15,
              fontWeight: FontWeight.w500, height: 1.5)),
        ],
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
    final hole = Path()..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(12)));
    canvas.drawPath(Path.combine(PathOperation.difference, full, hole), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CutoutPainter old) => old.cutout != cutout;
}
