import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
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

class _GameScreenState extends State<GameScreen> {
  late AppinioSwiperController _swiperController;
  int _currentIndex = 0;
  final List<SwipeDirection> _choices = [];
  String? _swipeOverlay;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_currentIndex + 1} / ${widget.cards.length}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Progress bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _currentIndex / widget.cards.length,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red[400]!,
              ),
              minHeight: 3,
            ),
          ),

          // Swiper
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AppinioSwiper(
              controller: _swiperController,
              cardCount: widget.cards.length,
              cardBuilder: (context, index) {
                return SwipeCardWidget(card: widget.cards[index]);
              },
              onSwipeEnd: _onSwipeEnd,
              onEnd: _onEnd,
              allowUnSwipe: false,
              isDisabled: false,
              swipeOptions: const SwipeOptions.all(),
              duration: const Duration(milliseconds: 300),
              maxAngle: 30,
              threshold: 80,
              backgroundCardCount: 1,
              backgroundCardOffset: const Offset(0, -10),
              backgroundCardScale: 0.95,
            ),
          ),

          // Swipe direction overlay
          if (_swipeOverlay != null)
            Center(
              child: AnimatedOpacity(
                opacity: _swipeOverlay != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _overlayColor().withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _swipeOverlay ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom action buttons
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  label: 'Puro floro',
                  onTap: () => _swiperController.swipeLeft(),
                ),
                _actionButton(
                  icon: Icons.arrow_upward,
                  color: Colors.amber,
                  label: 'Sospechoso',
                  onTap: () => _swiperController.swipeUp(),
                ),
                _actionButton(
                  icon: Icons.check,
                  color: Colors.green,
                  label: 'Pasa',
                  onTap: () => _swiperController.swipeRight(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSwipeEnd(
    int previousIndex,
    int targetIndex,
    SwiperActivity activity,
  ) {
    SwipeDirection? direction;
    String? overlay;

    if (activity is Swipe) {
      switch (activity.direction) {
        case AxisDirection.left:
          direction = SwipeDirection.left;
          overlay = '← PURO FLORO';
          break;
        case AxisDirection.right:
          direction = SwipeDirection.right;
          overlay = 'PASA RASPANDO →';
          break;
        case AxisDirection.up:
          direction = SwipeDirection.up;
          overlay = '↑ SOSPECHOSO';
          break;
        default:
          // down swipe = treat as right (pasa raspando)
          direction = SwipeDirection.right;
          overlay = 'PASA RASPANDO →';
      }
    }

    if (direction != null) {
      _choices.add(direction);
      setState(() {
        _swipeOverlay = overlay;
        _currentIndex = previousIndex + 1;
      });

      // Show overlay briefly then navigate to reveal
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() => _swipeOverlay = null);

        // Show reveal for this card
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RevealScreen(
              card: widget.cards[previousIndex],
              playerChoice: direction!,
              cardNumber: previousIndex + 1,
              totalCards: widget.cards.length,
              onContinue: () {
                Navigator.of(context).pop(); // Pop reveal
              },
            ),
          ),
        );
      });
    }
  }

  void _onEnd() {
    // All cards swiped - show results
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            result: RoundResult(
              cards: widget.cards,
              choices: _choices,
            ),
          ),
        ),
      );
    });
  }

  Color _overlayColor() {
    if (_swipeOverlay?.contains('FLORO') ?? false) return Colors.red;
    if (_swipeOverlay?.contains('SOSPECHOSO') ?? false) return Colors.amber;
    return Colors.green;
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
