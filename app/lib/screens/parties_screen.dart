import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../data/card_repository.dart';
import '../utils/constants.dart';
import 'candidate_profile_screen.dart';

class PartiesScreen extends StatefulWidget {
  final CardRepository repository;

  const PartiesScreen({super.key, required this.repository});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  String _sortBy = 'floro'; // 'floro', 'count', 'controversias'
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allStats = widget.repository.getPartyStats();

    // Filter
    var stats = allStats;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      stats = stats.where((s) => (s['partido'] as String).toLowerCase().contains(q)).toList();
    }

    // Sort
    if (_sortBy == 'count') {
      stats.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    } else if (_sortBy == 'controversias') {
      stats.sort((a, b) => (b['withControversies'] as int).compareTo(a['withControversies'] as int));
    }
    // default: already sorted by avgFloro

    return Scaffold(
      backgroundColor: colorBg,
      appBar: AppBar(
        backgroundColor: colorBgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Partidos Políticos',
          style: TextStyle(
            color: colorTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: colorDivider),
        ),
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: colorBgWhite,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar partido...',
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

          // Sort chips
          Container(
            color: colorBgWhite,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                const Text('Ordenar: ', style: TextStyle(color: colorTextTertiary, fontSize: 12)),
                const SizedBox(width: 8),
                _sortChip('Índice Floro', 'floro'),
                const SizedBox(width: 6),
                _sortChip('Candidatos', 'count'),
                const SizedBox(width: 6),
                _sortChip('Alertas', 'controversias'),
              ],
            ),
          ),
          Container(height: 0.5, color: colorDivider),

          // Summary
          Container(
            color: colorBgWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: colorAccentInk, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${stats.length} partidos políticos',
                  style: const TextStyle(
                    color: colorTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: colorDivider),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: stats.length,
              itemBuilder: (context, index) => _partyCard(stats[index], index + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _partyCard(Map<String, dynamic> party, int rank) {
    final nombre = party['partido'] as String;
    final count = party['count'] as int;
    final avgFloro = party['avgFloro'] as double;
    final withControv = party['withControversies'] as int;
    final nivelCounts = party['nivelCounts'] as Map<String, int>;
    final worstNivel = party['worstNivel'] as String;
    final worstColor = colorForNivel(worstNivel);
    final candidates = party['candidates'] as List<CandidateCard>;

    return GestureDetector(
      onTap: () => _showPartyDetail(nombre, candidates),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Rank
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: rank <= 3 ? colorAccentRed : colorChipDefault,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: rank <= 3 ? Colors.white : colorTextSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Party name
                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      color: colorTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Avg floro score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      avgFloro.toStringAsFixed(1),
                      style: TextStyle(
                        color: worstColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'PROM. FLORO',
                      style: TextStyle(
                        color: colorTextMuted,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Stats row
            Row(
              children: [
                _statBadge(Icons.people, '$count', 'candidatos', colorAccentInk),
                const SizedBox(width: 12),
                _statBadge(Icons.warning_amber_rounded, '$withControv', 'con alertas',
                    withControv > 0 ? colorBanderaRoja : colorPasaRaspando),
                const Spacer(),
                const Icon(Icons.chevron_right, color: colorTextMuted, size: 18),
              ],
            ),
            const SizedBox(height: 8),

            // Nivel distribution bar
            _nivelBar(nivelCounts, count),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(color: colorTextTertiary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _nivelBar(Map<String, int> nivelCounts, int total) {
    if (total == 0) return const SizedBox.shrink();

    final niveles = [
      ('Alerta maxima', colorAlertaMaxima),
      ('Bandera roja', colorBanderaRoja),
      ('Mucho floro', colorMuchoFloro),
      ('Dudoso', colorDudoso),
      ('Pasa raspando', colorPasaRaspando),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Row(
              children: niveles.map((entry) {
                final count = nivelCounts[entry.$1] ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Expanded(
                  flex: count,
                  child: Container(color: entry.$2),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Legend
        Wrap(
          spacing: 8,
          children: niveles.where((e) => (nivelCounts[e.$1] ?? 0) > 0).map((entry) {
            final count = nivelCounts[entry.$1] ?? 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(
                  color: entry.$2, borderRadius: BorderRadius.circular(2),
                )),
                const SizedBox(width: 3),
                Text(
                  '$count ${_shortNivel(entry.$1)}',
                  style: const TextStyle(color: colorTextTertiary, fontSize: 9),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  String _shortNivel(String nivel) {
    switch (nivel) {
      case 'Alerta maxima': return 'alerta';
      case 'Bandera roja': return 'roja';
      case 'Mucho floro': return 'floro';
      case 'Dudoso': return 'dudoso';
      default: return 'ok';
    }
  }

  void _showPartyDetail(String partido, List<CandidateCard> candidates) {
    // Sort by indiceFloro descending
    final sorted = List<CandidateCard>.from(candidates)
      ..sort((a, b) => b.indiceFloro.compareTo(a.indiceFloro));

    final avgFloro = candidates.isEmpty ? 0.0
        : candidates.map((c) => c.indiceFloro).reduce((a, b) => a + b) / candidates.length;
    final withControv = candidates.where((c) => c.hasControversies).length;
    final pct = candidates.isEmpty ? 0 : (withControv * 100 / candidates.length).round();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PartyDetailScreen(
        partido: partido,
        candidates: sorted,
        avgFloro: avgFloro,
        withControversies: withControv,
        pctControversies: pct,
      ),
    ));
  }
}

// ======== PARTY DETAIL SCREEN ========

class _PartyDetailScreen extends StatelessWidget {
  final String partido;
  final List<CandidateCard> candidates;
  final double avgFloro;
  final int withControversies;
  final int pctControversies;

  const _PartyDetailScreen({
    required this.partido,
    required this.candidates,
    required this.avgFloro,
    required this.withControversies,
    required this.pctControversies,
  });

  @override
  Widget build(BuildContext context) {
    final nivelColor = avgFloro >= 60
        ? colorAlertaMaxima
        : avgFloro >= 40
            ? colorBanderaRoja
            : avgFloro >= 25
                ? colorMuchoFloro
                : avgFloro >= 15
                    ? colorDudoso
                    : colorPasaRaspando;

    return Scaffold(
      backgroundColor: colorBg,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: colorBgWhite,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: colorTextPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              partido,
              style: const TextStyle(
                color: colorTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Stats header
          SliverToBoxAdapter(
            child: Container(
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(height: 0.5, color: colorDivider),
                  const SizedBox(height: 16),
                  // Big stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _bigStat(avgFloro.toStringAsFixed(1), 'Índice Floro\nPromedio', nivelColor),
                      _bigStat('${candidates.length}', 'Total\nCandidatos', colorAccentInk),
                      _bigStat('$pctControversies%', 'Con\nAlertas', colorBanderaRoja),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Verdict
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: nivelColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: nivelColor.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          avgFloro >= 40 ? Icons.warning_rounded : Icons.info_outline,
                          color: nivelColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _partyVerdict(avgFloro, pctControversies),
                            style: TextStyle(
                              color: nivelColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Container(height: 0.5, color: colorDivider),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(width: 3, height: 16, color: colorAccentRed),
                  const SizedBox(width: 8),
                  Text(
                    'CANDIDATOS (${candidates.length})',
                    style: const TextStyle(
                      color: colorTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Candidate list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final card = candidates[index];
                final nColor = colorForNivel(card.nivel);
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CandidateProfileScreen(card: card),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorBgWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorCardBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        // Rank in party
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: colorTextMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.nombre,
                                style: const TextStyle(
                                  color: colorTextPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card.cargo ?? '',
                                style: const TextStyle(color: colorTextTertiary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Floro + nivel
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${card.indiceFloro}',
                              style: TextStyle(
                                color: nColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: nColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                card.nivel,
                                style: TextStyle(
                                  color: nColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: colorTextMuted, size: 16),
                      ],
                    ),
                  ),
                );
              },
              childCount: candidates.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _bigStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: colorTextTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _partyVerdict(double avg, int pct) {
    if (avg >= 50) return 'Partido con alto índice de floro. $pct% de sus candidatos tienen señales de alerta.';
    if (avg >= 30) return 'Partido con índice de floro moderado-alto. Investiga a sus candidatos antes de votar.';
    if (avg >= 15) return 'Partido con índice de floro moderado. Algunos candidatos requieren atención.';
    return 'Partido con bajo índice de floro. La mayoría de candidatos pasa el filtro.';
  }
}
