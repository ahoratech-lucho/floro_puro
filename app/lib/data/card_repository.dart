import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../models/candidate_card.dart';
import '../utils/constants.dart';

class CardRepository {
  List<CandidateCard> _allCards = [];
  final _random = Random();

  Future<void> loadCards() async {
    final jsonStr = await rootBundle.loadString('assets/game_data.json');
    final data = json.decode(jsonStr);
    _allCards = (data['cards'] as List)
        .map((c) => CandidateCard.fromJson(c))
        .toList();
  }

  List<CandidateCard> get allCards => _allCards;

  int get totalCards => _allCards.length;

  List<CandidateCard> get interestingCards =>
      _allCards.where((c) => c.hasControversies).toList();

  List<CandidateCard> get presidentialCards =>
      _allCards.where((c) => c.cargo == 'PRESIDENTE').toList();

  List<CandidateCard> cardsByCargo(String cargo) =>
      _allCards.where((c) => c.cargo == cargo).toList();

  /// Get unique region types, optionally filtered by cargo
  List<String> regionTypesForCargo([String? cargo]) {
    var cards = _allCards;
    if (cargo != null) {
      cards = cards.where((c) => c.cargo == cargo).toList();
    }
    return cards
        .map((c) => c.region ?? '')
        .toSet()
        .where((r) => r.isNotEmpty)
        .toList()
      ..sort();
  }

  /// Get unique region types (all)
  List<String> get regionTypes => regionTypesForCargo();

  /// Select cards for a round with guaranteed interesting cards mixed in.
  /// When no region filter is set, 80% of cards come from Huánuco.
  List<CandidateCard> selectRound({
    int count = cardsPerRound,
    String? cargoFilter,
    String? regionFilter,
    bool onlyInteresting = false,
  }) {
    // Always exclude candidates with no real data
    List<CandidateCard> pool = _allCards.where((c) => c.hasRealData).toList();

    if (cargoFilter != null) {
      pool = pool.where((c) => c.cargo == cargoFilter).toList();
    }

    if (regionFilter != null) {
      pool = pool.where((c) => c.region == regionFilter).toList();
    }

    if (onlyInteresting) {
      pool = pool.where((c) => c.hasControversies).toList();
      pool.shuffle(_random);
      return pool.take(count).toList();
    }

    // --- Huánuco priority: 80% from Huánuco when no region filter ---
    if (regionFilter == null) {
      final huanucoPool = pool.where((c) =>
        (c.region ?? '').toUpperCase().contains('HUANUCO') ||
        (c.region ?? '').toUpperCase().contains('HUÁNUCO')
      ).toList();
      final otherPool = pool.where((c) =>
        !(c.region ?? '').toUpperCase().contains('HUANUCO') &&
        !(c.region ?? '').toUpperCase().contains('HUÁNUCO')
      ).toList();

      if (huanucoPool.isNotEmpty) {
        final numHuanuco = min((count * 0.8).ceil(), huanucoPool.length);
        final numOther = count - numHuanuco;

        // Within each sub-pool, guarantee interesting cards
        final huanucoInteresting = huanucoPool.where((c) => c.hasControversies).toList();
        final huanucoRegular = huanucoPool.where((c) => !c.hasControversies).toList();
        huanucoInteresting.shuffle(_random);
        huanucoRegular.shuffle(_random);

        final hIntCount = min(guaranteedInterestingCards, huanucoInteresting.length);
        final hRegCount = numHuanuco - hIntCount;
        final huanucoSelected = <CandidateCard>[
          ...huanucoInteresting.take(hIntCount),
          ...huanucoRegular.take(hRegCount),
        ];

        otherPool.shuffle(_random);
        final otherSelected = otherPool.take(numOther).toList();

        final selected = [...huanucoSelected, ...otherSelected];
        selected.shuffle(_random);
        return selected;
      }
    }

    // Weighted selection: guarantee some interesting cards
    final interesting = pool.where((c) => c.hasControversies).toList();
    final regular = pool.where((c) => !c.hasControversies).toList();

    interesting.shuffle(_random);
    regular.shuffle(_random);

    final numInteresting = min(guaranteedInterestingCards, interesting.length);
    final numRegular = count - numInteresting;

    final selected = <CandidateCard>[
      ...interesting.take(numInteresting),
      ...regular.take(numRegular),
    ];

    selected.shuffle(_random);
    return selected;
  }

  /// Get all unique parties with candidate counts and stats
  List<Map<String, dynamic>> getPartyStats() {
    final partyMap = <String, List<CandidateCard>>{};
    for (final card in _allCards) {
      final partido = card.partido ?? 'Sin partido';
      partyMap.putIfAbsent(partido, () => []).add(card);
    }

    final stats = <Map<String, dynamic>>[];
    for (final entry in partyMap.entries) {
      final cards = entry.value;
      final avgFloro = cards.isEmpty ? 0.0
          : cards.map((c) => c.indiceFloro).reduce((a, b) => a + b) / cards.length;
      final withControversies = cards.where((c) => c.hasControversies).length;

      // Count by nivel
      final nivelCounts = <String, int>{};
      for (final c in cards) {
        nivelCounts[c.nivel] = (nivelCounts[c.nivel] ?? 0) + 1;
      }

      // Worst nivel
      String worstNivel = 'Pasa raspando';
      if (nivelCounts.containsKey('Alerta maxima')) worstNivel = 'Alerta maxima';
      else if (nivelCounts.containsKey('Bandera roja')) worstNivel = 'Bandera roja';
      else if (nivelCounts.containsKey('Mucho floro')) worstNivel = 'Mucho floro';
      else if (nivelCounts.containsKey('Dudoso')) worstNivel = 'Dudoso';

      stats.add({
        'partido': entry.key,
        'candidates': cards,
        'count': cards.length,
        'avgFloro': avgFloro,
        'withControversies': withControversies,
        'nivelCounts': nivelCounts,
        'worstNivel': worstNivel,
      });
    }

    // Sort by average floro descending
    stats.sort((a, b) => (b['avgFloro'] as double).compareTo(a['avgFloro'] as double));
    return stats;
  }

  /// Get unique cargo types
  List<String> get cargoTypes {
    return _allCards.map((c) => c.cargo ?? '').toSet().where((c) => c.isNotEmpty).toList();
  }

  /// Stats
  Map<String, int> get statsByNivel {
    final stats = <String, int>{};
    for (final card in _allCards) {
      stats[card.nivel] = (stats[card.nivel] ?? 0) + 1;
    }
    return stats;
  }
}
