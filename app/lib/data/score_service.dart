import 'package:shared_preferences/shared_preferences.dart';

/// Persists best scores and stats using SharedPreferences (localStorage on web)
class ScoreService {
  static const _keyBestScore = 'best_score';
  static const _keyBestPercent = 'best_percent';
  static const _keyBestStreak = 'best_streak';
  static const _keyTotalGames = 'total_games';
  static const _keyTotalCards = 'total_cards_played';
  static const _keyBestTitle = 'best_title';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== GETTERS =====
  static int get bestScore => _prefs?.getInt(_keyBestScore) ?? 0;
  static int get bestPercent => _prefs?.getInt(_keyBestPercent) ?? 0;
  static int get bestStreak => _prefs?.getInt(_keyBestStreak) ?? 0;
  static int get totalGames => _prefs?.getInt(_keyTotalGames) ?? 0;
  static int get totalCardsPlayed => _prefs?.getInt(_keyTotalCards) ?? 0;
  static String get bestTitle => _prefs?.getString(_keyBestTitle) ?? '';

  static bool get hasPlayed => totalGames > 0;

  // ===== SAVE ROUND =====
  /// Save the result of a round. Returns true if it was a new best score.
  static Future<bool> saveRound({
    required int score,
    required int maxScore,
    required int percent,
    required int streak,
    required int cardsPlayed,
    required String title,
  }) async {
    if (_prefs == null) await init();

    bool isNewBest = false;

    // Update total games
    await _prefs!.setInt(_keyTotalGames, totalGames + 1);
    await _prefs!.setInt(_keyTotalCards, totalCardsPlayed + cardsPlayed);

    // Update best score
    if (percent > bestPercent) {
      await _prefs!.setInt(_keyBestScore, score);
      await _prefs!.setInt(_keyBestPercent, percent);
      await _prefs!.setString(_keyBestTitle, title);
      isNewBest = true;
    }

    // Update best streak
    if (streak > bestStreak) {
      await _prefs!.setInt(_keyBestStreak, streak);
    }

    return isNewBest;
  }
}
