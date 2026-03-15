import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launch() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launch,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.link, color: Colors.blue, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _displayDomain,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.open_in_new,
              color: Colors.blue,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget showing a list of source links
class SourceLinkList extends StatelessWidget {
  final List<String> sources;

  const SourceLinkList({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Text(
            'Fuentes verificadas (${sources.length})',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...sources.asMap().entries.map(
              (e) => SourceLink(url: e.value, index: e.key),
            ),
      ],
    );
  }
}
