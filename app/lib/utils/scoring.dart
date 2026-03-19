import '../models/candidate_card.dart';

/// 4 player choices matching the Word document
enum PlayerChoice { puroFloro, banderaRoja, sospechoso, pasaRaspando }

/// Maps choice to display label
String choiceLabel(PlayerChoice choice) {
  switch (choice) {
    case PlayerChoice.puroFloro:
      return 'Puro floro';
    case PlayerChoice.banderaRoja:
      return 'Bandera roja';
    case PlayerChoice.sospechoso:
      return 'Sospechoso';
    case PlayerChoice.pasaRaspando:
      return 'Pasa raspando';
  }
}

/// Maps respuestaIdeal string to PlayerChoice
PlayerChoice? idealChoice(String? respuesta) {
  switch (respuesta?.toLowerCase()) {
    case 'puro floro':
      return PlayerChoice.puroFloro;
    case 'bandera roja':
      return PlayerChoice.banderaRoja;
    case 'sospechoso':
      return PlayerChoice.sospechoso;
    case 'pasa raspando':
      return PlayerChoice.pasaRaspando;
    default:
      return null;
  }
}

/// Severity order: pasaRaspando < sospechoso < banderaRoja < puroFloro
int _severity(PlayerChoice c) {
  switch (c) {
    case PlayerChoice.pasaRaspando:
      return 0;
    case PlayerChoice.sospechoso:
      return 1;
    case PlayerChoice.banderaRoja:
      return 2;
    case PlayerChoice.puroFloro:
      return 3;
  }
}

/// Score a single choice: 0-3 points
int scoreChoice(CandidateCard card, PlayerChoice playerChoice) {
  final ideal = idealChoice(card.respuestaIdeal);
  if (ideal == null) return 1; // No ideal answer = participation point

  if (playerChoice == ideal) return 3; // Perfect match

  final diff = (_severity(playerChoice) - _severity(ideal)).abs();
  if (diff == 1) return 2; // Adjacent answer
  if (diff == 2) return 1; // Two steps off
  return 0; // Opposite (pasa raspando vs puro floro)
}

/// Overall round score
class RoundResult {
  final List<CandidateCard> cards;
  final List<PlayerChoice> choices;

  RoundResult({required this.cards, required this.choices});

  int get totalScore {
    int sum = 0;
    for (int i = 0; i < cards.length; i++) {
      sum += scoreChoice(cards[i], choices[i]);
    }
    return sum;
  }

  int get maxScore => cards.length * 3;

  double get percentage => maxScore > 0 ? totalScore / maxScore : 0;

  /// Titles from the Word document
  String get title {
    final pct = (percentage * 100).round();
    if (pct >= 81) return 'Auditor del Verso';
    if (pct >= 61) return 'Fiscal del Floro';
    if (pct >= 41) return 'Cazador de Floro';
    if (pct >= 21) return 'Aprendiz del Radar';
    return 'Ciudadano Distraído';
  }

  String get rating {
    final pct = (percentage * 100).round();
    if (pct >= 81) return 'Detectaste incoherencias, promesas inviables y señales de opacidad.';
    if (pct >= 61) return '¡Buen olfato político! Pocos te venden floro.';
    if (pct >= 41) return 'Vas aprendiendo a detectar el floro.';
    if (pct >= 21) return 'Te falta calle... el floro se te escapa.';
    return 'Te comiste el floro completito.';
  }

  String get emoji {
    final pct = (percentage * 100).round();
    if (pct >= 81) return '🏆';
    if (pct >= 61) return '👃';
    if (pct >= 41) return '📚';
    if (pct >= 21) return '🤔';
    return '🤡';
  }
}
