import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import '../utils/scoring.dart';
import '../data/sound_service.dart';

/// Callback when user swipes to make a choice
typedef OnSwipeChoice = void Function(PlayerChoice choice);

class SwipeCardWidget extends StatefulWidget {
  final CandidateCard card;
  final OnSwipeChoice? onSwipeChoice;
  final bool enableSwipe;
  final int cardNumber;
  final int totalCards;

  const SwipeCardWidget({
    super.key,
    required this.card,
    this.onSwipeChoice,
    this.enableSwipe = true,
    this.cardNumber = 1,
    this.totalCards = 1,
  });

  @override
  State<SwipeCardWidget> createState() => _SwipeCardWidgetState();
}

class _SwipeCardWidgetState extends State<SwipeCardWidget>
    with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isExiting = false;

  // Exit animation
  late AnimationController _exitController;
  Offset _exitStartOffset = Offset.zero;
  double _exitStartRotation = 0.0;

  // Thresholds
  static const double _swipeThreshold = 80.0;
  static const double _maxRotation = 0.3;

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  // Only LEFT and RIGHT swipes now
  PlayerChoice? get _currentSwipeDirection {
    if (_dragOffset.distance < _swipeThreshold * 0.5) return null;

    final dx = _dragOffset.dx;

    // Left = puro floro
    if (dx < -_swipeThreshold) return PlayerChoice.puroFloro;
    // Right = pasa raspando
    if (dx > _swipeThreshold) return PlayerChoice.pasaRaspando;

    return null;
  }

  Color? get _overlayColor {
    final dir = _currentSwipeDirection;
    if (dir == null) return null;
    switch (dir) {
      case PlayerChoice.puroFloro:
        return colorAccentRed;
      case PlayerChoice.pasaRaspando:
        return colorPasaRaspando;
      case PlayerChoice.sospechoso:
        return colorMuchoFloro;
      case PlayerChoice.banderaRoja:
        return colorBanderaRoja;
    }
  }

  String? get _overlayLabel {
    final dir = _currentSwipeDirection;
    if (dir == null) return null;
    return choiceLabel(dir).toUpperCase();
  }

  IconData? get _overlayIcon {
    final dir = _currentSwipeDirection;
    if (dir == null) return null;
    switch (dir) {
      case PlayerChoice.puroFloro:
        return Icons.close_rounded;
      case PlayerChoice.pasaRaspando:
        return Icons.check_rounded;
      case PlayerChoice.sospechoso:
        return Icons.help_outline_rounded;
      case PlayerChoice.banderaRoja:
        return Icons.flag_rounded;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enableSwipe) return;
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enableSwipe || !_isDragging) return;
    setState(() {
      // Only allow horizontal movement
      _dragOffset += Offset(details.delta.dx, details.delta.dy * 0.3);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enableSwipe || !_isDragging) return;

    final choice = _currentSwipeDirection;
    if (choice != null && widget.onSwipeChoice != null) {
      // Animate card flying off screen
      _exitStartOffset = _dragOffset;
      _exitStartRotation = (_dragOffset.dx / 300).clamp(-_maxRotation, _maxRotation);
      setState(() {
        _isDragging = false;
        _isExiting = true;
      });
      _exitController.reset();
      // Sound effect on swipe
      SoundService.playSwipe();
      // Fire callback early (don't wait for full animation)
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) widget.onSwipeChoice!(choice);
      });
      _exitController.forward().then((_) {
        if (mounted) {
          setState(() {
            _isExiting = false;
            _dragOffset = Offset.zero;
          });
        }
      });
      return;
    }

    setState(() {
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  /// Build clues from candidate data
  List<String> _buildClues(CandidateCard card) {
    final clues = <String>[];

    if (card.pensionAlimenticia == 'sí') {
      clues.add('Registrado en REDAM por deuda de pensión alimenticia');
    }
    if (card.procesosJudiciales.isNotEmpty) {
      final n = card.procesosJudiciales.length;
      clues.add('$n proceso${n > 1 ? "s" : ""} judicial${n > 1 ? "es" : ""}');
    }
    if (card.antecedentes.isNotEmpty) {
      clues.add('Antecedentes penales registrados');
    }
    if (card.cambiosPartido.isNotEmpty) {
      final n = card.cambiosPartido.length;
      clues.add('Cambió de partido $n vez${n > 1 ? "es" : ""}');
    }
    if (card.controversias.isNotEmpty) {
      final n = card.controversias.length;
      clues.add('$n controversia${n > 1 ? "s" : ""} documentada${n > 1 ? "s" : ""}');
    }
    if (card.senales.isNotEmpty) {
      final n = card.senales.length;
      clues.add('$n señal${n > 1 ? "es" : ""} de alerta');
    }
    if (clues.isEmpty) {
      clues.add('Sin alertas ni procesos registrados');
    }
    return clues.take(3).toList();
  }

  /// Count total alerts for danger level
  int _alertCount(CandidateCard card) {
    int count = 0;
    if (card.pensionAlimenticia == 'sí') count += 2;
    count += card.procesosJudiciales.length;
    count += card.antecedentes.length;
    count += card.controversias.length;
    count += card.senales.length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final clues = _buildClues(card);
    final alerts = _alertCount(card);

    // Calculate offset and rotation, accounting for exit animation
    double currentDx = _dragOffset.dx;
    double currentDy = _dragOffset.dy;
    double rotation;

    if (_isExiting) {
      final t = Curves.easeIn.transform(_exitController.value);
      final flyDistance = 600.0;
      final direction = _exitStartOffset.dx >= 0 ? 1.0 : -1.0;
      currentDx = _exitStartOffset.dx + direction * flyDistance * t;
      currentDy = _exitStartOffset.dy - 50 * t;
      rotation = _exitStartRotation + direction * 0.3 * t;
    } else {
      rotation = (currentDx / 300).clamp(-_maxRotation, _maxRotation);
    }

    // Determine swipe progress for visual feedback
    final swipeProgress = (_dragOffset.dx.abs() / _swipeThreshold).clamp(0.0, 1.0);
    final isSwipingLeft = _dragOffset.dx < 0;

    return AnimatedBuilder(
      animation: _exitController,
      builder: (context, child) => GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedContainer(
        duration: (_isDragging || _isExiting) ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(currentDx, currentDy)
          ..rotateZ(rotation),
        transformAlignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: colorBgWhite,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(3),
            ),
            boxShadow: [
              BoxShadow(
                color: (_overlayColor ?? Colors.black).withOpacity(_isDragging ? 0.18 : 0.10),
                blurRadius: _isDragging ? 24 : 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: _overlayColor?.withOpacity(0.6) ?? colorCardBorder,
              width: _overlayColor != null ? 2.5 : 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(3),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // === CARICATURE — takes most of the card ===
                    Expanded(
                      flex: 72,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Container(
                            color: const Color(0xFFF5F0E8),
                            child: ImageService.caricature(
                              card.caricatureWebpId,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Subtle paper texture overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.05),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.03),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Dark gradient at bottom for text
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 130,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Name + Party at bottom of image
                          Positioned(
                            bottom: 12,
                            left: 14,
                            right: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -0.3,
                                    shadows: [
                                      Shadow(color: Colors.black87, blurRadius: 8),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                if (card.partido != null)
                                  Row(
                                    children: [
                                      ImageService.partyLogo(card.partido, size: 20),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          card.partido!,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 12,
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

                          // === CASO # + CARGO badge (top-left) ===
                          Positioned(
                            top: 10,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(2, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                card.cargo?.toUpperCase() ?? 'CANDIDATO',
                                style: const TextStyle(
                                  color: colorAccentInk,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // === Card counter (top-right) ===
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(-1, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${widget.cardNumber}/${widget.totalCards}',
                                style: const TextStyle(
                                  color: colorAccentInk,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          // Region badge (below cargo)
                          if (card.region != null && card.region!.isNotEmpty)
                            Positioned(
                              top: 36,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorAccentInk.withOpacity(0.85),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white, size: 9),
                                    const SizedBox(width: 3),
                                    Text(
                                      card.region!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // === BOTTOM: Expediente — newspaper clipping style ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F3E8),
                        border: Border(
                          top: BorderSide(
                            color: colorAccentInk.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header row: red bar + EXPEDIENTE + alert dots
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: colorAccentRed,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'EXPEDIENTE',
                                style: TextStyle(
                                  color: colorAccentInk,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Spacer(),
                              // Alert dots with subtle animation feel
                              Row(
                                children: List.generate(5, (i) => Container(
                                  width: 9,
                                  height: 9,
                                  margin: const EdgeInsets.only(left: 3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i < alerts.clamp(0, 5)
                                        ? (alerts >= 5 ? colorAccentRed : alerts >= 3 ? colorMuchoFloro : colorDudoso)
                                        : const Color(0xFFE0D8C8),
                                    border: Border.all(
                                      color: i < alerts.clamp(0, 5)
                                          ? Colors.transparent
                                          : const Color(0xFFD0C8B8),
                                      width: 0.5,
                                    ),
                                  ),
                                )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Dashed separator
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: const Color(0xFFD8D0C0),
                          ),
                          const SizedBox(height: 6),
                          // Clues — typewriter style
                          ...clues.map((clue) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(top: 5, right: 8),
                                  decoration: BoxDecoration(
                                    color: colorAccentRed.withOpacity(0.6),
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    clue,
                                    style: const TextStyle(
                                      color: Color(0xFF4A4238),
                                      fontSize: 11.5,
                                      height: 1.3,
                                      fontFamily: 'monospace',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),

                // === SWIPE OVERLAY ===
                if (_overlayColor != null)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _currentSwipeDirection != null ? 0.15 : 0.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _overlayColor,
                        ),
                      ),
                    ),
                  ),

                // Swipe stamp label — estilo sello oficial
                if (_overlayLabel != null)
                  Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Transform.rotate(
                        angle: isSwipingLeft ? -0.18 : 0.18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _overlayColor!.withAlpha(230),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.white.withAlpha(180), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _overlayColor!.withAlpha(120),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_overlayIcon, color: Colors.white, size: 26),
                              const SizedBox(width: 8),
                              Text(
                                _overlayLabel!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

