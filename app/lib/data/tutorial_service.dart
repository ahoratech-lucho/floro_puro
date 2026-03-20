import 'package:shared_preferences/shared_preferences.dart';

/// Global tutorial state — tracks which step the user is on across screens.
/// Steps:
///   0 = Don Radar intro (home screen)
///   1 = Point to play button (home screen) — user presses it
///   2 = Instruction screen — highlight ACTIVAR RADAR
///   3 = Game screen — swipe/buttons explanation
///   4 = Reveal screen — 4 sub-steps for tabs
///   5 = Home screen — bottom nav tabs explanation
///   6 = Done (completed)
class TutorialService {
  static const String _key = 'tutorial_step';
  static const String _seenKey = 'tutorial_completed';
  static int _currentStep = 0;
  static bool _completed = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _completed = prefs.getBool(_seenKey) ?? false;
    _currentStep = prefs.getInt(_key) ?? 0;
  }

  static bool get isActive => !_completed;
  static int get currentStep => _currentStep;

  static Future<void> advanceTo(int step) async {
    _currentStep = step;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, step);
  }

  static Future<void> complete() async {
    _completed = true;
    _currentStep = 6;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    await prefs.setInt(_key, 6);
  }

  /// Reset tutorial (for "¿Cómo jugar?" button)
  static Future<void> reset() async {
    _completed = false;
    _currentStep = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, false);
    await prefs.setInt(_key, 0);
  }
}
