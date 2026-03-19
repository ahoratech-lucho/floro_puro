import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecurityService {
  /// Check if device is rooted/jailbroken
  static Future<bool> isDeviceRooted() async {
    if (kIsWeb) return false;

    try {
      // Check for common root indicators on Android
      final rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
        '/system/app/SuperSU.apk',
        '/system/app/SuperSU',
        '/system/app/Magisk.apk',
      ];

      for (final path in rootPaths) {
        if (await File(path).exists()) {
          return true;
        }
      }

      // Try to execute su
      try {
        final result = await Process.run('su', ['-c', 'id']);
        if (result.exitCode == 0) return true;
      } catch (_) {}

      // Check for Magisk
      try {
        final result = await Process.run('magisk', ['--version']);
        if (result.exitCode == 0) return true;
      } catch (_) {}

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check if app has been tampered with (basic signature verification)
  static Future<bool> isAppTampered() async {
    if (kIsWeb || kDebugMode) return false;

    try {
      // Check if running in debug mode in release build
      bool isDebug = false;
      assert(() {
        isDebug = true;
        return true;
      }());
      if (isDebug) return true;

      // Check for common hooking frameworks
      final suspiciousPaths = [
        '/data/data/de.robv.android.xposed.installer',
        '/data/data/com.saurik.substrate',
        '/data/data/com.topjohnwu.magisk',
        '/data/data/eu.chainfire.supersu',
      ];

      for (final path in suspiciousPaths) {
        if (await Directory(path).exists()) {
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Run all security checks
  static Future<SecurityResult> checkSecurity() async {
    final rooted = await isDeviceRooted();
    final tampered = await isAppTampered();

    return SecurityResult(
      isRooted: rooted,
      isTampered: tampered,
      isSecure: !rooted && !tampered,
    );
  }
}

class SecurityResult {
  final bool isRooted;
  final bool isTampered;
  final bool isSecure;

  SecurityResult({
    required this.isRooted,
    required this.isTampered,
    required this.isSecure,
  });

  String get warning {
    if (isRooted && isTampered) {
      return 'Dispositivo rooteado y app modificada detectados.';
    } else if (isRooted) {
      return 'Dispositivo rooteado detectado.';
    } else if (isTampered) {
      return 'Modificación de la app detectada.';
    }
    return '';
  }
}
