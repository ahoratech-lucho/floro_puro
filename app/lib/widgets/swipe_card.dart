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

  /// Build a list of factual clues from candidate data (without revealing the answer)
  List<String> _buildClues(CandidateCard card) {
    final clues = <String>[];

    if (card.pensionAlimenticia == 'sí') {
      clues.add('Registrado en REDAM por deuda de pensión alimenticia');
    }

    if (card.procesosJudiciales.isNotEmpty) {
      final n = card.procesosJudiciales.length;
      clues.add('$n proceso${n > 1 ? "s" : ""} judicial${n > 1 ? "es" : ""} registrado${n > 1 ? "s" : ""}');
    }

    if (card.antecedentes.isNotEmpty) {
      clues.add('Tiene antecedentes penales registrados');
    }

    if (card.cambiosPartido.isNotEmpty) {
      final n = card.cambiosPartido.length;
      clues.add('Ha cambiado de partido $n vez${n > 1 ? "es" : ""}');
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

    return clues.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final rotation = (_dragOffset.dx / 300).clamp(-_maxRotation, _maxRotation);
    final clues = _buildClues(card);

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
                // Main card content — image-dominant layout
                Column(
                  children: [
                    // TOP: Giant caricature with overlaid info (~70%)
                    Expanded(
                      flex: 7,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Caricature image — fills the whole top
                          Container(
                            color: colorBg,
                            child: ImageService.caricature(
                              card.caricatureWebpId,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // Dark gradient at bottom for text overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Name + Party overlaid on image bottom
                          Positioned(
                            bottom: 10,
                            left: 14,
                            right: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name — big, white, bold
                                Text(
                                  card.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                // Party badge
                                if (card.partido != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ImageService.partyLogo(
                                          card.partido,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            card.partido!,
                                            style: const TextStyle(
                                              color: Colors.white,
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

                          // Mystery badge (top-right)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colorAccentInk.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.help_outline,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 3),
                                  Text(
                                    '¿TÚ DECIDES?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 9,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BOTTOM: Compact evidence strip (~30%)
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                        decoration: const BoxDecoration(
                          color: colorBgWhite,
                          border: Border(
                            top: BorderSide(color: colorCardBorder, width: 0.5),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Candidate's own quote (frase) — compact
                              if (card.hasRealFrase)
                                Container(
                                  padding: const EdgeInsets.all(8),
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
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                              if (card.hasRealFrase) const SizedBox(height: 6),

                              // DATO: factual clues — compact
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: const Border(
                                    left: BorderSide(
                                      color: colorDudoso,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.search, color: colorDudoso, size: 11),
                                        SizedBox(width: 3),
                                        Text(
                                          'DATO:',
                                          style: TextStyle(
                                            color: colorDudoso,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    ...clues.map((clue) => Padding(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ',
                                              style: TextStyle(
                                                  color: colorTextSecondary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700)),
                                          Expanded(
                                            child: Text(
                                              clue,
                                              style: const TextStyle(
                                                color: colorTextSecondary,
                                                fontSize: 11,
                                                height: 1.25,
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
                        ),
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
