import 'package:flutter/material.dart';
import '../data/card_repository.dart';
import '../data/image_service.dart';
import '../models/candidate_card.dart';
import '../utils/constants.dart';
import '../widgets/floro_meter.dart';

/// Compare two candidates side by side
class CompareScreen extends StatefulWidget {
  final CardRepository repository;

  const CompareScreen({super.key, required this.repository});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  CandidateCard? _cardA;
  CandidateCard? _cardB;

  @override
  Widget build(BuildContext context) {
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
                      'COMPARADOR',
                      style: TextStyle(
                        color: colorTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Text('⚖️', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Selection row
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: _selectorButton(_cardA, true)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: colorAccentRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(child: _selectorButton(_cardB, false)),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Comparison content
            Expanded(
              child: _cardA != null && _cardB != null
                  ? _comparisonView()
                  : _emptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectorButton(CandidateCard? card, bool isA) {
    return GestureDetector(
      onTap: () => _selectCandidate(isA),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: card != null ? colorBgWhite : colorChipDefault,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: card != null
                ? colorForNivel(card.nivel).withAlpha(80)
                : colorCardBorder,
            width: card != null ? 1.5 : 0.5,
          ),
        ),
        child: card != null
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ImageService.caricature(card.caricatureWebpId, width: 36, height: 36),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.nombre,
                          style: const TextStyle(
                            color: colorTextPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          card.partido ?? '',
                          style: const TextStyle(
                            color: colorTextTertiary,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    color: colorTextMuted,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isA ? 'Candidato A' : 'Candidato B',
                    style: const TextStyle(
                      color: colorTextMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚖️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Selecciona dos candidatos\npara comparar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorTextTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonView() {
    final a = _cardA!;
    final b = _cardB!;

    // Collect all dimension keys
    final allDims = <String>{...a.puntajes.keys, ...b.puntajes.keys}.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // IF comparison
          _comparisonHeader(a, b),
          const SizedBox(height: 14),

          // Level badges
          _comparisonRow(
            'NIVEL',
            _nivelBadge(a.nivel),
            _nivelBadge(b.nivel),
          ),
          const SizedBox(height: 10),

          // Red flags
          _comparisonRow(
            'ALERTAS',
            _alertCount(a.totalRedFlags),
            _alertCount(b.totalRedFlags),
          ),
          const SizedBox(height: 10),

          // Controversias
          _comparisonRow(
            'CONTROVERSIAS',
            _countBadge(a.controversias.length),
            _countBadge(b.controversias.length),
          ),
          const SizedBox(height: 10),

          // Antecedentes
          _comparisonRow(
            'ANTECEDENTES',
            _countBadge(a.antecedentes.length),
            _countBadge(b.antecedentes.length),
          ),
          const SizedBox(height: 10),

          // Pension
          _comparisonRow(
            'REDAM',
            _yesNo(a.pensionAlimenticia == 'sí'),
            _yesNo(b.pensionAlimenticia == 'sí'),
          ),
          const SizedBox(height: 10),

          // Cambios de partido
          _comparisonRow(
            'CAMBIOS PARTIDO',
            _countBadge(a.cambiosPartido.length),
            _countBadge(b.cambiosPartido.length),
          ),
          const SizedBox(height: 14),

          // Dimension comparison
          if (allDims.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DESGLOSE POR DIMENSIÓN',
                style: TextStyle(
                  color: colorTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...allDims.map((dim) => _dimensionRow(
              dim,
              a.puntajes[dim] ?? 0,
              b.puntajes[dim] ?? 0,
            )),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _comparisonHeader(CandidateCard a, CandidateCard b) {
    final colorA = colorForNivel(a.nivel);
    final colorB = colorForNivel(b.nivel);
    final aWorse = a.indiceFloro > b.indiceFloro;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorCardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          // A score
          Expanded(
            child: Column(
              children: [
                Text(
                  '${a.indiceFloro}',
                  style: TextStyle(
                    color: colorA,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  a.nombre.split(' ').take(2).join(' '),
                  style: const TextStyle(
                    color: colorTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // VS indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorAccentRedLight,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'IF',
              style: TextStyle(
                color: colorAccentRed,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // B score
          Expanded(
            child: Column(
              children: [
                Text(
                  '${b.indiceFloro}',
                  style: TextStyle(
                    color: colorB,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  b.nombre.split(' ').take(2).join(' '),
                  style: const TextStyle(
                    color: colorTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonRow(String label, Widget valueA, Widget valueB) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorCardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(child: Center(child: valueA)),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: colorTextTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Center(child: valueB)),
        ],
      ),
    );
  }

  Widget _dimensionRow(String label, int a, int b) {
    final maxVal = 20;
    final colorA = _dimColor(a);
    final colorB = _dimColor(b);
    final worse = a > b ? -1 : a < b ? 1 : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorCardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            _shortLabel(label),
            style: const TextStyle(
              color: colorTextSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // A bar (right-aligned)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$a',
                      style: TextStyle(
                        color: colorA,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 80,
                      height: 12,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorA.withAlpha(15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: maxVal > 0 ? a / maxVal : 0,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: colorA.withAlpha(180),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // B bar (left-aligned)
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 12,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorB.withAlpha(15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: maxVal > 0 ? b / maxVal : 0,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: colorB.withAlpha(180),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$b',
                      style: TextStyle(
                        color: colorB,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nivelBadge(String nivel) {
    final color = colorForNivel(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        nivel,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _alertCount(int count) {
    return Text(
      '🚩 $count',
      style: TextStyle(
        color: count > 0 ? colorAccentRed : colorPasaRaspando,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _countBadge(int count) {
    return Text(
      '$count',
      style: TextStyle(
        color: count > 0 ? colorAccentRed : colorTextMuted,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _yesNo(bool yes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: yes ? colorAccentRedLight : colorPasaRaspando.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        yes ? 'SÍ' : 'NO',
        style: TextStyle(
          color: yes ? colorAccentRed : colorPasaRaspando,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _dimColor(int value) {
    if (value >= 15) return colorAlertaMaxima;
    if (value >= 10) return colorBanderaRoja;
    if (value >= 5) return colorMuchoFloro;
    return colorPasaRaspando;
  }

  String _shortLabel(String key) {
    final labels = {
      'discursoPopulista': 'POPULISMO',
      'incoherenciaIdeologica': 'INCOHERENCIA',
      'historialDudoso': 'HISTORIAL',
      'opacidadFinanciera': 'OPACIDAD',
      'nepotismoRedes': 'NEPOTISMO',
      'promesasIrreales': 'PROMESAS',
    };
    return labels[key] ?? key.toUpperCase();
  }

  void _selectCandidate(bool isA) async {
    final allCards = widget.repository.allCards;
    final result = await showModalBottomSheet<CandidateCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CandidatePickerSheet(cards: allCards),
    );
    if (result != null) {
      setState(() {
        if (isA) {
          _cardA = result;
        } else {
          _cardB = result;
        }
      });
    }
  }
}

/// Bottom sheet picker for selecting a candidate
class _CandidatePickerSheet extends StatefulWidget {
  final List<CandidateCard> cards;

  const _CandidatePickerSheet({required this.cards});

  @override
  State<_CandidatePickerSheet> createState() => _CandidatePickerSheetState();
}

class _CandidatePickerSheetState extends State<_CandidatePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.cards.take(50).toList()
        : widget.cards
            .where((c) =>
                c.nombre.toLowerCase().contains(_query.toLowerCase()) ||
                (c.partido ?? '').toLowerCase().contains(_query.toLowerCase()))
            .take(50)
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: colorDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar candidato...',
                hintStyle: const TextStyle(color: colorTextMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: colorTextTertiary, size: 20),
                filled: true,
                fillColor: colorBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          // Results
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final c = filtered[i];
                final color = colorForNivel(c.nivel);
                return ListTile(
                  dense: true,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ImageService.caricature(c.caricatureWebpId, width: 38, height: 38),
                  ),
                  title: Text(
                    c.nombre,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${c.partido ?? "Independiente"} · ${c.cargo ?? ""}',
                    style: const TextStyle(fontSize: 10, color: colorTextTertiary),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withAlpha(15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withAlpha(80)),
                    ),
                    child: Text(
                      'IF ${c.indiceFloro}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
