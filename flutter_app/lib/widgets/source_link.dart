import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class SourceLink extends StatelessWidget {
  final String url;
  final int index;

  const SourceLink({
    super.key,
    required this.url,
    required this.index,
  });

  String get _displayDomain {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url.length > 40 ? '${url.substring(0, 40)}...' : url;
    }
  }

  /// Friendly name for known domains
  String get _displayName {
    final domain = _displayDomain;
    const names = {
      'infobae.com': 'Infobae',
      'larepublica.pe': 'La República',
      'elcomercio.pe': 'El Comercio',
      'gestion.pe': 'Gestión',
      'rpp.pe': 'RPP Noticias',
      'pagina3.pe': 'Página 3',
      'diariocorreo.pe': 'Diario Correo',
      'ojo-publico.com': 'Ojo Público',
      'es.wikipedia.org': 'Wikipedia',
      'youtube.com': 'YouTube',
      'congreso.gob.pe': 'Congreso',
      'plataformaelectoral.jne.gob.pe': 'JNE Plataforma Electoral',
    };
    return names[domain] ?? domain;
  }

  Future<void> _launch(BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.link_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Este enlace ya no está disponible',
              style: TextStyle(fontSize: 13))),
          ]),
          backgroundColor: colorTextTertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launch(context),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: colorDudoso.withAlpha(25),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: colorDudoso,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _displayName,
                style: const TextStyle(
                  color: colorDudoso,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: colorDudoso,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: colorDudoso,
              size: 11,
            ),
          ],
        ),
      ),
    );
  }
}

/// URLs to filter out (temporary/internal links)
bool _isValidSource(String url) {
  try {
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();
    // Filter out Vertex AI Search temporary URLs (they expire and 404)
    if (host.contains('vertexaisearch')) return false;
    // Filter out plain google search links
    if (host == 'www.google.com' || host == 'google.com') return false;
    return true;
  } catch (_) {
    return false;
  }
}

/// Widget showing a list of source links
class SourceLinkList extends StatelessWidget {
  final List<String> sources;

  const SourceLinkList({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    // Filter out invalid/temporary sources
    final validSources = sources.where(_isValidSource).toList();
    final filteredCount = sources.length - validSources.length;

    if (validSources.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: colorTextMuted, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Las fuentes originales ya no están disponibles.\nDatos verificados con IA desde fuentes periodísticas.',
                    style: TextStyle(
                      color: colorTextTertiary,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verificadas (${validSources.length})',
          style: const TextStyle(
            color: colorTextTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...validSources.asMap().entries.map(
              (e) => SourceLink(url: e.value, index: e.key),
            ),
        if (filteredCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+ $filteredCount fuentes internas (no disponibles públicamente)',
            style: const TextStyle(
              color: colorTextMuted,
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
