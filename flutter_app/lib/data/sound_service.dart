import 'dart:js_interop';
import 'dart:math';
import 'package:web/web.dart' as web;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple sound effects using Web Audio API — works in Flutter web
class SoundService {
  static const _keyEnabled = 'sound_enabled';
  static bool _enabled = true;
  static web.AudioContext? _ctx;

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

  static void _ensureContext() {
    _ctx ??= web.AudioContext();
  }

  /// Play a correct answer sound — ascending tone
  static void playCorrect() {
    if (!_enabled) return;
    _ensureContext();
    final ctx = _ctx!;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(523.25, ctx.currentTime); // C5
    osc.frequency.exponentialRampToValueAtTime(783.99, ctx.currentTime + 0.15); // G5
    gain.gain.setValueAtTime(0.3, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.3);
  }

  /// Play a wrong answer sound — descending tone
  static void playWrong() {
    if (!_enabled) return;
    _ensureContext();
    final ctx = _ctx!;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(300.0, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(150.0, ctx.currentTime + 0.2);
    gain.gain.setValueAtTime(0.15, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.25);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.25);
  }

  /// Play swipe sound — quick whoosh
  static void playSwipe() {
    if (!_enabled) return;
    _ensureContext();
    final ctx = _ctx!;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(400.0, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(800.0, ctx.currentTime + 0.08);
    gain.gain.setValueAtTime(0.1, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.1);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.1);
  }

  /// Play celebration fanfare — for good results
  static void playCelebration() {
    if (!_enabled) return;
    _ensureContext();
    final ctx = _ctx!;
    // 3-note fanfare
    final notes = [523.25, 659.25, 783.99]; // C5, E5, G5
    for (int i = 0; i < notes.length; i++) {
      final delay = i * 0.15;
      final osc = ctx.createOscillator();
      final gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(notes[i], ctx.currentTime + delay);
      gain.gain.setValueAtTime(0.25, ctx.currentTime + delay);
      gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + delay + 0.4);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(ctx.currentTime + delay);
      osc.stop(ctx.currentTime + delay + 0.4);
    }
  }

  /// Play a click/tap sound
  static void playTap() {
    if (!_enabled) return;
    _ensureContext();
    final ctx = _ctx!;
    final osc = ctx.createOscillator();
    final gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(1000.0, ctx.currentTime);
    gain.gain.setValueAtTime(0.08, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.05);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + 0.05);
  }
}
