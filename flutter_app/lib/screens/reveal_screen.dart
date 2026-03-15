import 'package:flutter/material.dart';
import '../models/candidate_card.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import '../utils/scoring.dart';
import '../widgets/radar_chart.dart';
import '../widgets/floro_meter.dart';
import '../widgets/source_link.dart';

class RevealScreen extends StatelessWidget {
  final CandidateCard card;
  final SwipeDirection playerChoice;
  final int cardNumber;
  final int totalCards;
  final VoidCallback onContinue;

  const RevealScreen({
    super.key,
    required this.card,
    required this.playerChoice,
    required this.cardNumber,
    required this.totalCards,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final ideal = idealDirection(card.respuestaIdeal);
    final isCorrect = ideal == playerChoice;
    final score = scoreSwipe(card, playerChoice);

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '$cardNumber / $totalCards',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Score feedback
            _scoreFeedback(score, isCorrect),
            const SizedBox(height: 16),

            // Candidate header with photo
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ImageService.photo(
                    card.photoWebpId,
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (card.partido != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          card.partido!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (card.cargo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          card.cargo!,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Floro meter + Radar side by side
            Row(
              children: [
                Expanded(
                  child: FloroMeter(
                    score: card.indiceFloro,
                    nivel: card.nivel,
                  ),
                ),
                Expanded(
                  child: FloroRadarChart(card: card, size: 160),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Your choice vs ideal
            _choiceComparison(),
            const SizedBox(height: 16),

            // Frase narrador
            if (card.fraseNarrador.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  card.fraseNarrador,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Controversias
            if (card.controversias.isNotEmpty)
              _section(
                'Controversias',
                Icons.warning_amber,
                Colors.red,
                card.controversias
                    .map((c) => _bulletPoint(c, Colors.red[200]!))
                    .toList(),
              ),

            // Antecedentes
            if (card.antecedentes.isNotEmpty)
              _section(
                'Antecedentes Penales',
                Icons.gavel,
                Colors.orange,
                card.antecedentes
                    .map((a) => _bulletPoint(a, Colors.orange[200]!))
                    .toList(),
              ),

            // Procesos judiciales
            if (card.procesosJudiciales.isNotEmpty)
              _section(
                'Procesos Judiciales',
                Icons.balance,
                Colors.purple,
                card.procesosJudiciales
                    .map((p) => _bulletPoint(p, Colors.purple[200]!))
                    .toList(),
              ),

            // Señales de alerta
            if (card.senales.isNotEmpty)
              _section(
                'Señales de Alerta',
                Icons.flag,
                Colors.red,
                card.senales
                    .map((b) => _bulletPoint(b, Colors.red[300]!))
                    .toList(),
              ),

            const SizedBox(height: 16),

            // Fuentes - CLICKEABLE LINKS
            if (card.fuentes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.15),
                  ),
                ),
                child: SourceLinkList(sources: card.fuentes),
              ),

            const SizedBox(height: 24),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  cardNumber < totalCards ? 'Siguiente →' : 'Ver resultados',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _scoreFeedback(int score, bool isCorrect) {
    Color bg;
    String text;
    IconData icon;

    if (score == 3) {
      bg = Colors.green;
      text = '¡Exacto! +3';
      icon = Icons.check_circle;
    } else if (score == 2) {
      bg = Colors.amber;
      text = 'Casi... +2';
      icon = Icons.remove_circle;
    } else if (score == 1) {
      bg = Colors.orange;
      text = 'Hmm... +1';
      icon = Icons.help;
    } else {
      bg = Colors.red;
      text = 'Fallaste +0';
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: bg, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: bg,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceComparison() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _choicePill('Tu respuesta', swipeLabel(playerChoice), _colorFor(playerChoice)),
        const Icon(Icons.compare_arrows, color: Colors.white24, size: 20),
        _choicePill(
          'Respuesta ideal',
          card.respuestaIdeal,
          idealDirection(card.respuestaIdeal) != null
              ? _colorFor(idealDirection(card.respuestaIdeal)!)
              : Colors.grey,
        ),
      ],
    );
  }

  Widget _choicePill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _colorFor(SwipeDirection dir) {
    switch (dir) {
      case SwipeDirection.left:
        return Colors.red;
      case SwipeDirection.right:
        return Colors.green;
      case SwipeDirection.up:
        return Colors.amber;
    }
  }

  Widget _section(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _bulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: color, fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
