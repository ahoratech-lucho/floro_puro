import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/card_repository.dart';
import '../models/candidate_card.dart';
import '../utils/constants.dart';

/// General statistics dashboard — aggregate data about all candidates
class StatsScreen extends StatelessWidget {
  final CardRepository repository;

  const StatsScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final cards = repository.allCards;
    final nivelStats = repository.statsByNivel;
    final total = cards.length;

    // Party stats (top 10 by count)
    final partyCount = <String, int>{};
    final partyFloro = <String, List<int>>{};
    for (final c in cards) {
      final p = c.partido ?? 'Independiente';
      partyCount[p] = (partyCount[p] ?? 0) + 1;
      partyFloro.putIfAbsent(p, () => []).add(c.indiceFloro);
    }
    final topParties = partyCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Avg floro by party (top 10 by avg)
    final partyAvg = <String, double>{};
    for (final entry in partyFloro.entries) {
      if (entry.value.length >= 3) { // at least 3 candidates to be meaningful
        partyAvg[entry.key] = entry.value.reduce((a, b) => a + b) / entry.value.length;
      }
    }
    final worstParties = partyAvg.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Cargo stats
    final cargoCount = <String, int>{};
    final cargoFloro = <String, List<int>>{};
    for (final c in cards) {
      final cargo = c.cargo ?? 'Sin cargo';
      cargoCount[cargo] = (cargoCount[cargo] ?? 0) + 1;
      cargoFloro.putIfAbsent(cargo, () => []).add(c.indiceFloro);
    }

    // Red flags stats
    final withControversies = cards.where((c) => c.controversias.isNotEmpty).length;
    final withAntecedentes = cards.where((c) => c.antecedentes.isNotEmpty).length;
    final withPension = cards.where((c) => c.pensionAlimenticia == 'sí').length;
    final withProcesos = cards.where((c) => c.procesosJudiciales.isNotEmpty).length;
    final withCambios = cards.where((c) => c.cambiosPartido.isNotEmpty).length;

    // Overall avg
    final avgFloro = total > 0
        ? (cards.map((c) => c.indiceFloro).reduce((a, b) => a + b) / total)
        : 0.0;

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
                      'ESTADÍSTICAS',
                      style: TextStyle(
                        color: colorTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Text('📊', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Overview numbers
                    _sectionTitle('PANORAMA GENERAL'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _bigStat('$total', 'Candidatos\nanalizados', colorAccentInk),
                        const SizedBox(width: 8),
                        _bigStat('${avgFloro.toStringAsFixed(1)}', 'Índice de Floro\npromedio', colorAccentRed),
                        const SizedBox(width: 8),
                        _bigStat('$withControversies', 'Con\ncontroversias', colorBanderaRoja),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nivel distribution
                    _sectionTitle('DISTRIBUCIÓN POR NIVEL'),
                    const SizedBox(height: 8),
                    _nivelDistribution(nivelStats, total),
                    const SizedBox(height: 16),

                    // Red flags breakdown
                    _sectionTitle('SEÑALES DE ALERTA'),
                    const SizedBox(height: 8),
                    _alertCard(Icons.warning_amber_outlined, 'Controversias', withControversies, total, colorAccentRed),
                    _alertCard(Icons.gavel_outlined, 'Antecedentes penales', withAntecedentes, total, colorBanderaRoja),
                    _alertCard(Icons.balance_outlined, 'Procesos judiciales', withProcesos, total, colorAccentInk),
                    _alertCard(Icons.child_care, 'Deudores REDAM', withPension, total, colorAlertaMaxima),
                    _alertCard(Icons.swap_horiz_outlined, 'Cambios de partido', withCambios, total, colorMuchoFloro),
                    const SizedBox(height: 16),

                    // Candidates by cargo
                    _sectionTitle('POR TIPO DE CARGO'),
                    const SizedBox(height: 8),
                    ...cargoCount.entries.map((e) {
                      final avg = cargoFloro[e.key]!.reduce((a, b) => a + b) / cargoFloro[e.key]!.length;
                      return _cargoRow(e.key, e.value, avg);
                    }),
                    const SizedBox(height: 16),

                    // Worst parties by avg floro
                    _sectionTitle('PARTIDOS CON MÁS FLORO (PROMEDIO)'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: _cardDeco(),
                      child: Column(
                        children: worstParties.take(10).toList().asMap().entries.map((e) {
                          final party = e.value;
                          final count = partyCount[party.key] ?? 0;
                          return _partyFloroRow(
                            e.key + 1, party.key, party.value, count,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biggest parties
                    _sectionTitle('PARTIDOS CON MÁS CANDIDATOS'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: _cardDeco(),
                      child: Column(
                        children: topParties.take(10).toList().asMap().entries.map((e) {
                          final party = e.value;
                          final avg = partyAvg[party.key] ?? 0;
                          return _partyCountRow(
                            e.key + 1, party.key, party.value, avg,
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: colorTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _bigStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: colorTextTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nivelDistribution(Map<String, int> stats, int total) {
    final niveles = [
      ('Alerta maxima', colorAlertaMaxima),
      ('Bandera roja', colorBanderaRoja),
      ('Mucho floro', colorMuchoFloro),
      ('Dudoso', colorDudoso),
      ('Pasa raspando', colorPasaRaspando),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        children: niveles.map((n) {
          final count = stats[n.$1] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: n.$2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: Text(
                    n.$1,
                    style: TextStyle(
                      color: n.$2,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: n.$2.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: n.$2.withAlpha(180),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 55,
                  child: Text(
                    '$count (${(pct * 100).toStringAsFixed(0)}%)',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: colorTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _alertCard(IconData icon, String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100) : 0.0;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: colorTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '(${pct.toStringAsFixed(1)}%)',
            style: const TextStyle(
              color: colorTextTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cargoRow(String cargo, int count, double avgFloro) {
    final color = _colorForAvg(avgFloro);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: _cardDeco(),
      child: Row(
        children: [
          const Icon(Icons.how_to_vote_outlined, color: colorAccentInk, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cargo,
                  style: const TextStyle(
                    color: colorTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$count candidatos',
                  style: const TextStyle(
                    color: colorTextTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'IF ${avgFloro.toStringAsFixed(1)}',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'promedio',
                style: TextStyle(color: colorTextMuted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _partyFloroRow(int rank, String party, double avg, int count) {
    final color = _colorForAvg(avg);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$rank.',
              style: TextStyle(
                color: rank <= 3 ? colorAccentRed : colorTextTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  party,
                  style: const TextStyle(
                    color: colorTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count candidatos',
                  style: const TextStyle(color: colorTextMuted, fontSize: 9),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Text(
              avg.toStringAsFixed(1),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partyCountRow(int rank, String party, int count, double avg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$rank.',
              style: TextStyle(
                color: rank <= 3 ? colorAccentInk : colorTextTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              party,
              style: const TextStyle(
                color: colorTextPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: colorAccentInk,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'IF ${avg.toStringAsFixed(0)}',
            style: TextStyle(
              color: _colorForAvg(avg),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForAvg(double avg) {
    if (avg >= 70) return colorAlertaMaxima;
    if (avg >= 50) return colorBanderaRoja;
    if (avg >= 35) return colorMuchoFloro;
    if (avg >= 20) return colorDudoso;
    return colorPasaRaspando;
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: colorBgWhite,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: colorCardBorder, width: 0.5),
  );
}
