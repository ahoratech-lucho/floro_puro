import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ImageService {
  static String caricatureUrl(String slug) =>
      '$cdnBaseUrl/images/caricaturas_webp/$slug.webp';

  static String photoUrl(String slug) =>
      '$cdnBaseUrl/images/photos_webp/$slug.webp';

  static String logoUrl(String slug) =>
      '$cdnBaseUrl/images/logos/$slug.jpg';

  static String _partySlug(String partyName) {
    return partyName
        .toLowerCase()
        .replaceAll(RegExp(r'[áàä]'), 'a')
        .replaceAll(RegExp(r'[éèë]'), 'e')
        .replaceAll(RegExp(r'[íìï]'), 'i')
        .replaceAll(RegExp(r'[óòö]'), 'o')
        .replaceAll(RegExp(r'[úùü]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static Widget partyLogo(String? partyName, {double size = 28}) {
    if (partyName == null || partyName.isEmpty || cdnBaseUrl.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    final slug = _partySlug(partyName);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        logoUrl(slug),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (c, e, s) => SizedBox(width: size, height: size),
      ),
    );
  }

  static String _initials(String slug) {
    final parts = slug.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static Color _colorFromSlug(String slug) {
    final hash = slug.hashCode.abs();
    final colors = [
      const Color(0xFF6C5CE7), const Color(0xFFE17055),
      const Color(0xFF00B894), const Color(0xFFFDAA5B),
      const Color(0xFFE84393), const Color(0xFF0984E3),
      const Color(0xFFFF7675), const Color(0xFF55A3F5),
      const Color(0xFFA29BFE), const Color(0xFF00CEC9),
    ];
    return colors[hash % colors.length];
  }

  static Widget _placeholder(String slug, {double? width, double? height}) {
    final initials = _initials(slug);
    final bgColor = _colorFromSlug(slug);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, bgColor.withOpacity(0.7), bgColor.withOpacity(0.5)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -20, right: -20, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.12)))),
          Positioned(bottom: -10, left: -10, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)))),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15), border: Border.all(color: Colors.white.withOpacity(0.25), width: 2)),
                  child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2))),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Text('SIN FOTO', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _loading({double? width, double? height}) {
    return Container(
      width: width, height: height,
      color: const Color(0xFFF0ECE6),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: colorTextMuted)),
    );
  }

  static Widget caricature(String slug, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (cdnBaseUrl.isEmpty) return _placeholder(slug, width: width, height: height);
    return Image.network(
      caricatureUrl(slug),
      width: width, height: height, fit: fit,
      loadingBuilder: (c, child, progress) => progress == null ? child : _loading(width: width, height: height),
      errorBuilder: (c, e, s) => _placeholder(slug, width: width, height: height),
    );
  }

  static Widget photo(String slug, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (cdnBaseUrl.isEmpty) return _placeholder(slug, width: width, height: height);
    return Image.network(
      photoUrl(slug),
      width: width, height: height, fit: fit,
      loadingBuilder: (c, child, progress) => progress == null ? child : _loading(width: width, height: height),
      errorBuilder: (c, e, s) => _placeholder(slug, width: width, height: height),
    );
  }
}
