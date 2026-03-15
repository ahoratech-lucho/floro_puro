import 'package:flutter/material.dart';
import '../data/card_repository.dart';
import '../utils/constants.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  final CardRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCargo;
  bool _onlyInteresting = false;

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final cargoTypes = repo.cargoTypes;
    final totalCards = repo.totalCards;
    final interestingCount = repo.interestingCards.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Logo / Title
              const Text(
                '🔍',
                style: TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 12),
              const Text(
                'RADAR DEL FLORO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Elecciones Perú 2026',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip('$totalCards candidatos', Colors.blue),
                  const SizedBox(width: 12),
                  _statChip('$interestingCount sospechosos', Colors.amber),
                ],
              ),
              const SizedBox(height: 32),

              // Filter: Cargo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtrar por cargo',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip('Todos', null),
                        ...cargoTypes.map((c) => _filterChip(c, c)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Toggle: Solo sospechosos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solo los sospechosos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Candidatos con controversias verificadas',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _onlyInteresting,
                      onChanged: (v) => setState(() => _onlyInteresting = v),
                      activeColor: Colors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Play button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    '¡DETECTAR FLORO!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Desliza para juzgar a cada candidato',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),

              // Credits
              Text(
                'Datos: JNE Voto Informado + fuentes periodísticas',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Proyecto satírico e informativo',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? cargo) {
    final selected = _selectedCargo == cargo;
    return GestureDetector(
      onTap: () => setState(() => _selectedCargo = cargo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Colors.red.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.red.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.red[200] : Colors.grey[400],
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _startGame() {
    final cards = widget.repository.selectRound(
      count: cardsPerRound,
      cargoFilter: _selectedCargo,
      onlyInteresting: _onlyInteresting,
    );

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay cartas con ese filtro'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(cards: cards),
      ),
    );
  }
}
