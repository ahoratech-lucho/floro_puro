import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidate_card.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import '../utils/scoring.dart';
import '../widgets/radar_chart.dart';
import '../widgets/floro_meter.dart';
import '../widgets/dimension_bars.dart';
import '../widgets/source_link.dart';

class RevealScreen extends StatelessWidget {
  final CandidateCard card;
  final PlayerChoice playerChoice;
  final int cardNumber;
  final int totalCards;
  final int streak;
  final VoidCallback onContinue;

  const RevealScreen({
    super.key,
    required this.card,
    required this.playerChoice,
    required this.cardNumber,
    required this.totalCards,
    this.streak = 0,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final ideal = idealChoice(card.respuestaIdeal);
    final isCorrect = ideal == playerChoice;
    final score = scoreChoice(card, playerChoice);
    final nivelColor = colorForNivel(card.nivel);

    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== TOP BAR: Score + Progress =====
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Score pill
                  _scorePill(score),
                  if (streak >= 3) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorAccentGold.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🔥 x$streak',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '$cardNumber de $totalCards',
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

            // ===== SCROLLABLE BOOK CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ===== CANDIDATE HEADER (big, clear) =====
                      _candidateHeader(nivelColor),
                      const SizedBox(height: 16),

                      // ===== YOUR CHOICE vs IDEAL =====
                      _choiceComparison(),
                      const SizedBox(height: 16),

                      // ===== FLORO METER =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            const Text(
                              'ÍNDICE DE FLORO',
                              style: TextStyle(
                                color: colorTextTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FloroMeter(score: card.indiceFloro, nivel: card.nivel),
                            const SizedBox(height: 16),
                            Container(height: 0.5, color: colorDivider),
                            const SizedBox(height: 12),
                            // Hexagon radar
                            Center(child: FloroRadarChart(card: card, size: 200)),
                            const SizedBox(height: 12),
                            Container(height: 0.5, color: colorDivider),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'DESGLOSE POR DIMENSIÓN',
                                style: TextStyle(
                                  color: colorTextTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DimensionBars(card: card),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== PATRÓN DOMINANTE =====
                      if (card.hasRealPatron)
                        _bookSection(
                          icon: Icons.psychology_outlined,
                          title: 'Patrón Detectado',
                          color: colorMuchoFloro,
                          child: Text(
                            card.patronDominante,
                            style: const TextStyle(
                              color: colorTextPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),

                      // ===== FRASE DEL CANDIDATO =====
                      if (card.hasRealFrase && card.frase != card.fraseNarrador)
                        _quoteSection(
                          title: 'El candidato dice',
                          quote: card.frase,
                          color: colorAccentInk,
                        ),

                      // ===== FRASE NARRADOR =====
                      if (card.fraseNarrador.isNotEmpty && card.fraseNarrador.length > 10)
                        _quoteSection(
                          title: 'Nuestro análisis',
                          quote: card.fraseNarrador,
                          color: colorAccentRed,
                        ),

                      // ===== PENSIÓN ALIMENTICIA (DESTACADO) =====
                      if (card.pensionAlimenticia == 'sí')
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorBanderaRoja.withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorBanderaRoja, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorBanderaRoja.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.child_care, color: colorBanderaRoja, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DEBE PENSIÓN ALIMENTICIA',
                                      style: TextStyle(
                                        color: colorBanderaRoja,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Registrado en el REDAM',
                                      style: TextStyle(
                                        color: colorBanderaRoja,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ===== CAMBIOS DE PARTIDO (TRÁNSFUGA) =====
                      if (card.cambiosPartido.isNotEmpty)
                        _bookSection(
                          icon: Icons.swap_horiz_outlined,
                          title: 'Cambios de Partido',
                          color: colorMuchoFloro,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: card.cambiosPartido.map((cambio) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🔄 ', style: TextStyle(fontSize: 15)),
                                  Expanded(
                                    child: Text(
                                      cambio,
                                      style: const TextStyle(
                                        color: colorTextPrimary,
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),

                      // ===== CONTROVERSIAS =====
                      if (card.controversias.isNotEmpty)
                        _bookListSection(
                          'Controversias',
                          Icons.warning_amber_outlined,
                          colorAccentRed,
                          card.controversias,
                        ),

                      // ===== ANTECEDENTES =====
                      if (card.antecedentes.isNotEmpty)
                        _bookListSection(
                          'Antecedentes Penales',
                          Icons.gavel_outlined,
                          colorBanderaRoja,
                          card.antecedentes,
                        ),

                      // ===== PROCESOS JUDICIALES =====
                      if (card.procesosJudiciales.isNotEmpty)
                        _bookListSection(
                          'Procesos Judiciales',
                          Icons.balance_outlined,
                          colorAccentInk,
                          card.procesosJudiciales,
                        ),

                      // ===== SEÑALES DE ALERTA =====
                      if (card.senales.isNotEmpty)
                        _bookListSection(
                          'Señales de Alerta',
                          Icons.flag_outlined,
                          colorMuchoFloro,
                          card.senales,
                        ),

                      // ===== FUENTES =====
                      if (card.fuentes.isNotEmpty)
                        _bookSection(
                          icon: Icons.link_outlined,
                          title: 'Fuentes',
                          color: colorDudoso,
                          child: SourceLinkList(sources: card.fuentes),
                        ),

                      // ===== JNE LINK =====
                      if (card.linkJNE != null && card.linkJNE!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () => _openUrl(card.linkJNE!),
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text(
                                'VER HOJA DE VIDA EN JNE',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorAccentInk,
                                side: BorderSide(color: colorAccentInk.withAlpha(120)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // ===== SHARE =====
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _shareCandidate(context),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text(
                              'COMPARTIR PERFIL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorAccentInk,
                              side: BorderSide(color: colorAccentInk.withAlpha(120)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // ===== FIXED BOTTOM: Continue Button =====
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(height: 0.5, color: colorDivider),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccentRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        cardNumber < totalCards
                            ? 'Siguiente candidato →'
                            : 'Ver resultados finales',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CANDIDATE HEADER =====
  Widget _candidateHeader(Color nivelColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorCardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Photo + Name row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageService.photo(
                  card.photoWebpId,
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.nombre,
                      style: const TextStyle(
                        color: colorTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (card.partido != null)
                      Row(
                        children: [
                          ImageService.partyLogo(card.partido, size: 22),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              card.partido!,
                              style: const TextStyle(
                                color: colorTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: colorDivider),
          const SizedBox(height: 12),
          // Cargo + Region + Nivel row
          Row(
            children: [
              if (card.cargo != null)
                _infoBadge(Icons.how_to_vote_outlined, card.cargo!, colorAccentInk),
              if (card.region != null && card.region!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _infoBadge(Icons.location_on_outlined, card.region!, colorAccentInk),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: nivelColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: nivelColor.withAlpha(100)),
                ),
                child: Text(
                  card.nivel.toUpperCase(),
                  style: TextStyle(
                    color: nivelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===== SCORE PILL =====
  Widget _scorePill(int score) {
    Color color;
    String text;
    IconData icon;

    if (score == 3) {
      color = colorPasaRaspando;
      text = '¡Exacto! +3';
      icon = Icons.check_circle_outline;
    } else if (score == 2) {
      color = colorDudoso;
      text = 'Casi... +2';
      icon = Icons.remove_circle_outline;
    } else if (score == 1) {
      color = colorMuchoFloro;
      text = 'Hmm... +1';
      icon = Icons.help_outline;
    } else {
      color = colorAccentRed;
      text = 'Fallaste +0';
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ===== CHOICE COMPARISON =====
  Widget _choiceComparison() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _choicePill(
              'Tu respuesta',
              choiceLabel(playerChoice),
              _colorFor(playerChoice),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.compare_arrows, color: colorTextMuted, size: 22),
          ),
          Expanded(
            child: _choicePill(
              'Respuesta ideal',
              card.respuestaIdeal,
              idealChoice(card.respuestaIdeal) != null
                  ? _colorFor(idealChoice(card.respuestaIdeal)!)
                  : colorTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _choicePill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
              color: colorTextTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ===== BOOK SECTION (generic container) =====
  Widget _bookSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 0.5, color: colorDivider),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ===== BOOK LIST SECTION (controversias, antecedentes, etc) =====
  Widget _bookListSection(
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return _bookSection(
      icon: icon,
      title: title,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final text = entry.value;
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: idx < items.length - 1 ? 10 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(8),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: color.withAlpha(100), width: 3),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: colorTextPrimary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===== QUOTE SECTION =====
  Widget _quoteSection({
    required String title,
    required String quote,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorBgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: colorCardBorder, width: 0.5),
          right: BorderSide(color: colorCardBorder, width: 0.5),
          bottom: BorderSide(color: colorCardBorder, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$quote"',
            style: const TextStyle(
              color: colorTextPrimary,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===== HELPERS =====
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: colorBgWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colorCardBorder, width: 0.5),
    );
  }

  Color _colorFor(PlayerChoice choice) {
    switch (choice) {
      case PlayerChoice.puroFloro:
        return colorAccentRed;
      case PlayerChoice.banderaRoja:
        return colorBanderaRoja;
      case PlayerChoice.sospechoso:
        return colorMuchoFloro;
      case PlayerChoice.pasaRaspando:
        return colorPasaRaspando;
    }
  }

  void _shareCandidate(BuildContext context) {
    final nivel = card.nivel;
    final numFlags = card.totalRedFlags;
    final pension = card.pensionAlimenticia == 'sí' ? ' ⚠️ Debe pensión alimenticia' : '';
    final cambios = card.cambiosPartido.isNotEmpty ? ' 🔄 Cambió de partido' : '';
    final text = '🔍 ${card.nombre} (${card.partido ?? "Independiente"})\n'
        '📊 Índice de Floro: ${card.indiceFloro}/100 · Nivel: $nivel\n'
        '🚩 $numFlags señales de alerta$pension$cambios\n\n'
        '¿Conoces a tu candidato? Descúbrelo en Radar del Floro 🇵🇪\n'
        '#RadarDelFloro #Elecciones2026';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Perfil copiado al portapapeles')),
          ],
        ),
        backgroundColor: colorAccentInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}
