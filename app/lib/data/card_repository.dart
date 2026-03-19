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

  /// Select cards for a round with guaranteed interesting cards mixed in
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
