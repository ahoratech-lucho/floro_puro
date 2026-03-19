import 'score_service.dart';

/// Badge definition
class GameBadge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool Function() check;

  const GameBadge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.check,
  });

  bool get isUnlocked => check();
}

/// Manages badges/achievements based on player stats
class BadgeService {
  static List<GameBadge> get allBadges => [
    GameBadge(
      id: 'first_game',
      emoji: '🎮',
      title: 'Primera Partida',
      description: 'Juega tu primera ronda',
      check: () => ScoreService.totalGames >= 1,
    ),
    GameBadge(
      id: 'five_games',
      emoji: '🔄',
      title: 'Reincidente',
      description: 'Juega 5 partidas',
      check: () => ScoreService.totalGames >= 5,
    ),
    GameBadge(
      id: 'ten_games',
      emoji: '🏋️',
      title: 'Veterano',
      description: 'Juega 10 partidas',
      check: () => ScoreService.totalGames >= 10,
    ),
    GameBadge(
      id: 'twenty_games',
      emoji: '🎖️',
      title: 'Fiscal Supremo',
      description: 'Juega 20 partidas',
      check: () => ScoreService.totalGames >= 20,
    ),
    GameBadge(
      id: 'streak_3',
      emoji: '🔥',
      title: 'En Racha',
      description: 'Racha de 3 aciertos seguidos',
      check: () => ScoreService.bestStreak >= 3,
    ),
    GameBadge(
      id: 'streak_5',
      emoji: '⚡',
      title: 'Imparable',
      description: 'Racha de 5 aciertos seguidos',
      check: () => ScoreService.bestStreak >= 5,
    ),
    GameBadge(
      id: 'streak_10',
      emoji: '💥',
      title: 'Leyenda',
      description: 'Racha de 10 aciertos seguidos',
      check: () => ScoreService.bestStreak >= 10,
    ),
    GameBadge(
      id: 'score_50',
      emoji: '📰',
      title: 'Buen Ojo',
      description: 'Alcanza 50% de aciertos',
      check: () => ScoreService.bestPercent >= 50,
    ),
    GameBadge(
      id: 'score_70',
      emoji: '🕵️',
      title: 'Detector Pro',
      description: 'Alcanza 70% de aciertos',
      check: () => ScoreService.bestPercent >= 70,
    ),
    GameBadge(
      id: 'score_90',
      emoji: '🏆',
      title: 'Maestro del Floro',
      description: 'Alcanza 90% de aciertos',
      check: () => ScoreService.bestPercent >= 90,
    ),
    GameBadge(
      id: 'score_100',
      emoji: '👑',
      title: 'Perfección',
      description: 'Alcanza 100% de aciertos',
      check: () => ScoreService.bestPercent >= 100,
    ),
    GameBadge(
      id: 'cards_50',
      emoji: '📋',
      title: 'Investigador',
      description: 'Evalúa 50 candidatos',
      check: () => ScoreService.totalCardsPlayed >= 50,
    ),
    GameBadge(
      id: 'cards_100',
      emoji: '📚',
      title: 'Enciclopedia Política',
      description: 'Evalúa 100 candidatos',
      check: () => ScoreService.totalCardsPlayed >= 100,
    ),
    GameBadge(
      id: 'cards_200',
      emoji: '🗃️',
      title: 'Archivo Nacional',
      description: 'Evalúa 200 candidatos',
      check: () => ScoreService.totalCardsPlayed >= 200,
    ),
  ];

  static List<GameBadge> get unlockedBadges =>
      allBadges.where((b) => b.isUnlocked).toList();

  static List<GameBadge> get lockedBadges =>
      allBadges.where((b) => !b.isUnlocked).toList();

  static int get totalUnlocked => unlockedBadges.length;
  static int get totalBadges => allBadges.length;
}
