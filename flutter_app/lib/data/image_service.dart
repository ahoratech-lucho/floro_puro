import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ImageService {
  static String caricatureUrl(String slug) =>
      '$cdnBaseUrl/images/caricatures/$slug.webp';

  static String photoUrl(String slug) =>
      '$cdnBaseUrl/images/photos/$slug.webp';

  /// Cached caricature widget with placeholder
  static Widget caricature(
    String slug, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedNetworkImage(
      imageUrl: caricatureUrl(slug),
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Icon(Icons.person, color: Colors.white38, size: 48),
      ),
    );
  }

  /// Cached photo widget with placeholder
  static Widget photo(
    String slug, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedNetworkImage(
      imageUrl: photoUrl(slug),
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white54,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Icon(Icons.person_outline, color: Colors.white38, size: 48),
      ),
    );
  }
}
