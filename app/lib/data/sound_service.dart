import 'package:shared_preferences/shared_preferences.dart';

/// Sound service stub for Android — Web Audio API not available on mobile.
/// Sound effects are disabled on Android; the toggle UI is preserved so
/// it can be wired to a real audio package later if desired.
class SoundService {
  static const _keyEnabled = 'sound_enabled';
  static bool _enabled = true;

  static bool get enabled => _enabled;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyEnabled) ?? true;
  }

  static Future<void> toggle() async {
    _enabled = !_enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, _enabled);
  }

  // Stubs — no-op on Android
  static void playCorrect() {}
  static void playWrong() {}
  static void playSwipe() {}
  static void playCelebration() {}
  static void playTap() {}
}
