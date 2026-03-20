import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const _keyEnabled = 'sound_enabled';
  static bool _enabled = true;
  static bool _ready = false;

  static bool get enabled => _enabled;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyEnabled) ?? true;
    _ready = true;
  }

  static Future<void> toggle() async {
    _enabled = !_enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, _enabled);
  }

  /// Play a sound fresh each time using a new AudioPlayer instance.
  /// This avoids the "completed state" bug where stop+resume doesn't work.
  static Future<void> _play(String asset, {double volume = 1.0}) async {
    if (!_enabled || !_ready) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(volume);
      await player.setSource(AssetSource(asset));
      await player.resume();
      // Auto-dispose after playback completes
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
      // Safety: dispose after 10 seconds max
      Future.delayed(const Duration(seconds: 10), () {
        player.dispose();
      });
    } catch (_) {}
  }

  static void playCorrect() => _play('sounds/correct.wav', volume: 1.0);
  static void playWrong() => _play('sounds/wrong.wav', volume: 1.0);
  static void playSwipe() => _play('sounds/swipe.wav', volume: 0.8);
  static void playTap() => _play('sounds/tap.wav', volume: 0.8);
  static void playCelebration() => _play('sounds/celebration.wav', volume: 1.0);
}
