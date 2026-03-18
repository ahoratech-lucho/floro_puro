import 'package:flutter/material.dart';
import '../data/card_repository.dart';
import '../data/image_service.dart';
import '../models/candidate_card.dart';
import '../utils/constants.dart';
import 'candidate_profile_screen.dart';

/// Hall of Shame — Top candidates ranked by Índice de Floro
class RankingScreen extends StatefulWidget {
  final CardRepository repository;

  const RankingScreen({super.key, required this.repository});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  String? _cargoFilter;

  @override
  Widget build(BuildContext context) {
    var cards = widget.repository.allCards;
    if (_cargoFilter != null) {
      cards = cards.where((c) => c.cargo == _cargoFilter).toList();
    }
    // Sort by indice floro descending
    cards = List.from(cards)..sort((a, b) => b.indiceFloro.compareTo(a.indiceFloro));
    final top = cards.take(25).toList();
    final cargoTypes = widget.repository.cargoTypes;

    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: colorTextPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'RANKING DEL FLORO',
                      style: TextStyle(
                        color: colorTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Text('🏆', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Cargo filter chips
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Todos', null),
                    const SizedBox(width: 6),
                    ...cargoTypes.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _filterChip(c, c),
                    )),
                  ],
                ),
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Ranking list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: top.length,
                itemBuilder: (context, index) => _rankingCard(top[index], index + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? cargo) {
    final selected = _cargoFilter == cargo;
    return GestureDetector(
      onTap: () => setState(() => _cargoFilter = cargo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colorChipSelected : colorChipDefault,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? colorChipSelected : colorCardBorder,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: selected ? Colors.white : colorTextSecondary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _rankingCard(CandidateCard card, int rank) {
    final nivelColor = colorForNivel(card.nivel);
    final isTop3 = rank <= 3;
    final rankEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CandidateProfileScreen(card: card)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isTop3 ? nivelColor.withAlpha(100) : colorCardBorder,
            width: isTop3 ? 1.5 : 0.5,
          ),
          boxShadow: isTop3
              ? [BoxShadow(color: nivelColor.withAlpha(15), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            // Rank number
            SizedBox(
              width: 36,
              child: isTop3
                  ? Text(rankEmoji, style: const TextStyle(fontSize: 22))
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        color: rank <= 10 ? colorAccentRed : colorTextTertiary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const SizedBox(width: 8),

            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ImageService.photo(card.photoWebpId, width: 48, height: 48),
            ),
            const SizedBox(width: 10),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.nombre,
                    style: TextStyle(
                      color: colorTextPrimary,
                      fontSize: isTop3 ? 15 : 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (card.partido != null) ...[
                        ImageService.partyLogo(card.partido, size: 14),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          '${card.partido ?? "Independiente"} · ${card.cargo ?? ""}',
                          style: const TextStyle(
                            color: colorTextTertiary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (card.totalRedFlags > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '🚩 ${card.totalRedFlags} alertas',
                      style: const TextStyle(
                        color: colorAccentRed,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Score + nivel
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: nivelColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: nivelColor.withAlpha(80)),
                  ),
                  child: Text(
                    '${card.indiceFloro}',
                    style: TextStyle(
                      color: nivelColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  card.nivel,
                  style: TextStyle(
                    color: nivelColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
