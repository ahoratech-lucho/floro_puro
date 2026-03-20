import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../data/card_repository.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import 'candidate_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  final CardRepository repository;

  const ExploreScreen({super.key, required this.repository});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String? _cargoFilter;
  String? _nivelFilter;

  List<CandidateCard> get _filtered {
    var cards = widget.repository.allCards;

    if (_cargoFilter != null) {
      cards = cards.where((c) => c.cargo == _cargoFilter).toList();
    }
    if (_nivelFilter != null) {
      cards = cards.where((c) => c.nivel == _nivelFilter).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      cards = cards.where((c) =>
        c.nombre.toLowerCase().contains(q) ||
        (c.partido ?? '').toLowerCase().contains(q) ||
        (c.region ?? '').toLowerCase().contains(q)
      ).toList();
    }

    // Sort by indice floro descending
    cards.sort((a, b) => b.indiceFloro.compareTo(a.indiceFloro));
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header (no back button — this is a tab)
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Explorar Candidatos',
                      style: TextStyle(
                        color: colorTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${filtered.length}',
                    style: const TextStyle(
                      color: colorTextTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Search bar
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, partido o región...',
                  hintStyle: const TextStyle(color: colorTextMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: colorTextTertiary, size: 20),
                  filled: true,
                  fillColor: colorBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: const TextStyle(color: colorTextPrimary, fontSize: 14),
              ),
            ),

            // Filters row
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Todos', null, _cargoFilter, (v) => setState(() => _cargoFilter = v)),
                    ...widget.repository.cargoTypes.map((c) =>
                      _filterChip(c, c, _cargoFilter, (v) => setState(() => _cargoFilter = v)),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 20, color: colorDivider),
                    const SizedBox(width: 12),
                    _nivelChip('Alerta maxima', colorAlertaMaxima),
                    _nivelChip('Bandera roja', colorBanderaRoja),
                    _nivelChip('Mucho floro', colorMuchoFloro),
                    _nivelChip('Dudoso', colorDudoso),
                    _nivelChip('Pasa raspando', colorPasaRaspando),
                  ],
                ),
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // List
            Expanded(
              child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, color: colorTextMuted, size: 48),
                        SizedBox(height: 12),
                        Text('No se encontraron candidatos',
                          style: TextStyle(color: colorTextTertiary, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final card = filtered[index];
                      return _candidateRow(card);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? value, String? current, Function(String?) onTap) {
    final selected = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? colorChipSelected : colorChipDefault,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : colorTextSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _nivelChip(String nivel, Color color) {
    final selected = _nivelFilter == nivel;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _nivelFilter = selected ? null : nivel),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? color : color.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withAlpha(selected ? 255 : 80)),
          ),
          child: Text(
            nivel,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _candidateRow(CandidateCard card) {
    final nivelColor = colorForNivel(card.nivel);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CandidateProfileScreen(card: card),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            // Caricature (fallback: saturated photo)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 48,
                height: 48,
                child: ImageService.caricature(
                  card.caricatureWebpId,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.nombre,
                    style: const TextStyle(
                      color: colorTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (card.partido != null) ...[
                        Flexible(
                          child: Text(
                            card.partido!,
                            style: const TextStyle(color: colorTextTertiary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(' · ', style: TextStyle(color: colorTextMuted, fontSize: 11)),
                      ],
                      Text(
                        card.cargo ?? '',
                        style: const TextStyle(color: colorTextTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Floro index + nivel
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${card.indiceFloro}',
                  style: TextStyle(
                    color: nivelColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: nivelColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    card.nivel,
                    style: TextStyle(
                      color: nivelColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: colorTextMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
