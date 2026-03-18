import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import '../utils/scoring.dart';

/// Callback when user swipes to make a choice
typedef OnSwipeChoice = void Function(PlayerChoice choice);

class SwipeCardWidget extends StatefulWidget {
  final CandidateCard card;
  final OnSwipeChoice? onSwipeChoice;
  final bool enableSwipe;

  const SwipeCardWidget({
    super.key,
    required this.card,
    this.onSwipeChoice,
    this.enableSwipe = true,
  });

  @override
  State<SwipeCardWidget> createState() => _SwipeCardWidgetState();
}

class _SwipeCardWidgetState extends State<SwipeCardWidget>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  // Thresholds
  static const double _swipeThreshold = 80.0;
  static const double _maxRotation = 0.3; // radians (~17 degrees)

  PlayerChoice? get _currentSwipeDirection {
    if (_dragOffset.distance < _swipeThreshold * 0.5) return null;

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    // Up = sospechoso (if dy is dominant and negative)
    if (dy < -_swipeThreshold && dy.abs() > dx.abs()) {
      return PlayerChoice.sospechoso;
    }
    // Left = puro floro
    if (dx < -_swipeThreshold) return PlayerChoice.puroFloro;
    // Right = pasa raspando
    if (dx > _swipeThreshold) return PlayerChoice.pasaRaspando;
    // Down = bandera roja
    if (dy > _swipeThreshold) return PlayerChoice.banderaRoja;

    return null;
  }

  Color? get _overlayColor {
    final dir = _currentSwipeDirection;
    if (dir == null) return null;
    switch (dir) {
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
      case PlayerChoice.banderaRoja:
        return Icons.flag_rounded;
      case PlayerChoice.sospechoso:
        return Icons.help_outline_rounded;
      case PlayerChoice.pasaRaspando:
        return Icons.check_rounded;
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enableSwipe) return;
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enableSwipe || !_isDragging) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enableSwipe || !_isDragging) return;

    final choice = _currentSwipeDirection;
    if (choice != null && widget.onSwipeChoice != null) {
      widget.onSwipeChoice!(choice);
    }

    setState(() {
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nivelColor = colorForNivel(widget.card.nivel);
    final card = widget.card;
    final rotation = (_dragOffset.dx / 300).clamp(-_maxRotation, _maxRotation);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedContainer(
        duration: _isDragging
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy)
          ..rotateZ(rotation),
        transformAlignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorBgWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (_overlayColor ?? Colors.black).withOpacity(
                    _isDragging ? 0.15 : 0.08),
                blurRadius: _isDragging ? 20 : 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: _overlayColor?.withOpacity(0.5) ?? colorCardBorder,
              width: _overlayColor != null ? 2 : 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Main card content
                Column(
                  children: [
                    // Top: Caricature area
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Caricature image
                          Container(
                            color: colorBg,
                            child: ImageService.caricature(
                              card.caricatureWebpId,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Bottom gradient for readability
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Nivel badge (top-right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: nivelColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                card.nivel.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),

                          // Cargo + Region badge (top-left)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (card.cargo != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                      border:
                                          Border.all(color: colorCardBorder),
                                    ),
                                    child: Text(
                                      card.cargo!.toUpperCase(),
                                      style: const TextStyle(
                                        color: colorTextSecondary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                if (card.region != null &&
                                    card.region!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorAccentInk.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.white, size: 10),
                                        const SizedBox(width: 3),
                                        Text(
                                          card.region!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Controversy badge (bottom-left) — alert icon with count
                          if (card.totalRedFlags > 0)
                            Positioned(
                              bottom: 6,
                              left: 10,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorAccentRed.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded,
                                            color: Colors.white, size: 12),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${card.totalRedFlags}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Pensión alimenticia badge
                                  if (card.pensionAlimenticia == 'sí') ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorBanderaRoja.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.child_care,
                                              color: Colors.white, size: 11),
                                          SizedBox(width: 2),
                                          Text(
                                            'PENSIÓN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                          // Floro index (bottom-right)
                          Positioned(
                            bottom: 6,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: nivelColor.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'IF ',
                                    style: TextStyle(
                                      color: colorTextTertiary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${card.indiceFloro}',
                                    style: TextStyle(
                                      color: nivelColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom: Info section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      decoration: const BoxDecoration(
                        color: colorBgWhite,
                        border: Border(
                          top: BorderSide(color: colorCardBorder, width: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name — headline style
                          Text(
                            card.nombre,
                            style: const TextStyle(
                              color: colorTextPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),

                          // Party badge with JNE logo
                          if (card.partido != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colorCardBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Party logo from JNE
                                  ImageService.partyLogo(
                                    card.partido,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      card.partido!,
                                      style: TextStyle(
                                        color: colorTextSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),

                          // Candidate's own quote (frase) — speech bubble style
                          if (card.hasRealFrase)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorBg,
                                borderRadius: BorderRadius.circular(6),
                                border: const Border(
                                  left: BorderSide(
                                    color: colorAccentInk,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DICE:',
                                    style: TextStyle(
                                      color: colorAccentInk,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '"${card.frase}"',
                                    style: const TextStyle(
                                      color: colorTextSecondary,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                          // Narrator phrase — editorial style (only if different from frase)
                          if (card.fraseNarrador.isNotEmpty &&
                              card.fraseNarrador.length > 10 &&
                              card.fraseNarrador != card.frase) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorAccentRedLight,
                                borderRadius: BorderRadius.circular(6),
                                border: const Border(
                                  left: BorderSide(
                                    color: colorAccentRed,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'RADAR:',
                                    style: TextStyle(
                                      color: colorAccentRed,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '"${card.fraseNarrador}"',
                                    style: const TextStyle(
                                      color: colorTextSecondary,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Swipe overlay indicator
                if (_overlayColor != null)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _currentSwipeDirection != null ? 0.15 : 0.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _overlayColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // Swipe label overlay
                if (_overlayLabel != null)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _overlayColor!, width: 3),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_overlayIcon,
                                  color: _overlayColor, size: 24),
                              const SizedBox(width: 6),
                              Text(
                                _overlayLabel!,
                                style: TextStyle(
                                  color: _overlayColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
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
    );
  }
}
