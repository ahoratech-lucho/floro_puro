import '../models/candidate_card.dart';

enum SwipeDirection { right, left, up }

/// Maps swipe direction to label
String swipeLabel(SwipeDirection dir) {
  switch (dir) {
    case SwipeDirection.right:
      return 'Pasa raspando';
    case SwipeDirection.left:
      return 'Puro floro';
    case SwipeDirection.up:
      return 'Sospechoso';
  }
}

/// Maps respuestaIdeal string to SwipeDirection
SwipeDirection? idealDirection(String? respuesta) {
  switch (respuesta?.toLowerCase()) {
    case 'pasa raspando':
      return SwipeDirection.right;
    case 'puro floro':
      return SwipeDirection.left;
    case 'sospechoso':
      return SwipeDirection.up;
    default:
      return null;
  }
}

/// Score a single swipe: 0-3 points
int scoreSwipe(CandidateCard card, SwipeDirection playerChoice) {
  final ideal = idealDirection(card.respuestaIdeal);
  if (ideal == null) return 1; // No ideal answer = participation point

  if (playerChoice == ideal) return 3; // Perfect match

  // Partial credit for close answers
  if (ideal == SwipeDirection.up) {
    return 1; // Sospechoso is the wildcard, any other answer gets 1
  }
  if (playerChoice == SwipeDirection.up) {
    return 2; // Saying "sospechoso" for puro floro or pasa raspando = decent
  }

  return 0; // Opposite answer (pasa raspando vs puro floro)
}

/// Overall round score
class RoundResult {
  final List<CandidateCard> cards;
  final List<SwipeDirection> choices;

  RoundResult({required this.cards, required this.choices});

  int get totalScore {
    int sum = 0;
    for (int i = 0; i < cards.length; i++) {
      sum += scoreSwipe(cards[i], choices[i]);
    }
    return sum;
  }

  int get maxScore => cards.length * 3;

  double get percentage => maxScore > 0 ? totalScore / maxScore : 0;

  String get rating {
    final pct = percentage;
    if (pct >= 0.9) return '¡Detector de Floro Experto!';
    if (pct >= 0.7) return '¡Buen olfato político!';
    if (pct >= 0.5) return 'Vas aprendiendo...';
    if (pct >= 0.3) return 'Te falta calle';
    return 'Te comiste el floro completito';
  }

  String get emoji {
    final pct = percentage;
    if (pct >= 0.9) return '🏆';
    if (pct >= 0.7) return '👃';
    if (pct >= 0.5) return '📚';
    if (pct >= 0.3) return '🤔';
    return '🤡';
  }
}
