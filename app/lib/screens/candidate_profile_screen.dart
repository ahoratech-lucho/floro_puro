import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidate_card.dart';
import '../data/image_service.dart';
import '../utils/constants.dart';
import '../widgets/radar_chart.dart';
import '../widgets/floro_meter.dart';
import '../widgets/dimension_bars.dart';
import '../widgets/source_link.dart';

/// Full candidate profile — accessible from Explorer (non-game mode)
class CandidateProfileScreen extends StatelessWidget {
  final CandidateCard card;

  const CandidateProfileScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final nivelColor = colorForNivel(card.nivel);

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
                  Expanded(
                    child: Text(
                      card.nombre,
                      style: const TextStyle(
                        color: colorTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _share(context),
                    child: const Icon(Icons.share_outlined, color: colorTextTertiary, size: 20),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Scrollable content (reuses same layout as RevealScreen)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Candidate header
                    _header(nivelColor),
                    const SizedBox(height: 16),

                    // Floro meter
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDeco(),
                      child: Column(
                        children: [
                          const Text('ÍNDICE DE FLORO',
                            style: TextStyle(color: colorTextTertiary, fontSize: 12,
                              fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          FloroMeter(score: card.indiceFloro, nivel: card.nivel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Radar + Bars — only if puntajes data exists
                    if (card.puntajes.values.any((v) => v > 0)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDeco(),
                        child: Column(
                          children: [
                            const Text('RADAR DE DIMENSIONES',
                              style: TextStyle(color: colorTextTertiary, fontSize: 12,
                                fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                            const SizedBox(height: 12),
                            Center(child: FloroRadarChart(card: card, size: 200)),
                            const SizedBox(height: 12),
                            Container(height: 0.5, color: colorDivider),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('DESGLOSE POR DIMENSIÓN',
                                style: TextStyle(color: colorTextTertiary, fontSize: 11,
                                  fontWeight: FontWeight.w700, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            DimensionBars(card: card),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Patrón
                    if (card.hasRealPatron)
                      _section(Icons.psychology_outlined, 'Patrón Detectado', colorMuchoFloro,
                        Text(card.patronDominante, style: const TextStyle(
                          color: colorTextPrimary, fontSize: 16,
                          fontWeight: FontWeight.w600, height: 1.5))),

                    // Frase candidato — usa _section() que ya funciona en Patrón
                    if (card.hasRealFrase &&
                        card.frase.trim().length > 15 &&
                        card.frase.trim() != card.fraseNarrador.trim() &&
                        RegExp(r'[a-záéíóúñA-ZÁÉÍÓÚÑ]').hasMatch(card.frase))
                      _section(Icons.format_quote_outlined, 'El Candidato Dice', colorAccentInk,
                        Text('"${card.frase.trim()}"', style: const TextStyle(
                          color: colorTextPrimary, fontSize: 15,
                          fontStyle: FontStyle.italic, height: 1.5))),

                    // Narrador
                    if (card.fraseNarrador.trim().length > 15 &&
                        RegExp(r'[a-záéíóúñA-ZÁÉÍÓÚÑ]').hasMatch(card.fraseNarrador))
                      _section(Icons.search_outlined, 'Nuestro Análisis', colorAccentRed,
                        Text('"${card.fraseNarrador.trim()}"', style: const TextStyle(
                          color: colorTextPrimary, fontSize: 15,
                          fontStyle: FontStyle.italic, height: 1.5))),

                    // Pensión
                    if (card.pensionAlimenticia == 'sí')
                      _pensionBadge(),

                    // Cambios partido
                    if (card.cambiosPartido.isNotEmpty)
                      _section(Icons.swap_horiz_outlined, 'Cambios de Partido', colorMuchoFloro,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: card.cambiosPartido.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🔄 ', style: TextStyle(fontSize: 15)),
                                Expanded(child: Text(c, style: const TextStyle(
                                  color: colorTextPrimary, fontSize: 15, height: 1.5))),
                              ],
                            ),
                          )).toList(),
                        )),

                    // Controversias
                    if (card.controversias.isNotEmpty)
                      _listSection('Controversias', Icons.warning_amber_outlined, colorAccentRed, card.controversias),
                    if (card.antecedentes.isNotEmpty)
                      _listSection('Antecedentes Penales', Icons.gavel_outlined, colorBanderaRoja, card.antecedentes),
                    if (card.procesosJudiciales.isNotEmpty)
                      _listSection('Procesos Judiciales', Icons.balance_outlined, colorAccentInk, card.procesosJudiciales),
                    if (card.senales.isNotEmpty)
                      _listSection('Señales de Alerta', Icons.flag_outlined, colorMuchoFloro, card.senales),

                    // Fuentes
                    if (card.fuentes.isNotEmpty)
                      _section(Icons.link_outlined, 'Fuentes', colorDudoso,
                        SourceLinkList(sources: card.fuentes)),

                    // JNE link
                    if (card.linkJNE != null && card.linkJNE!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity, height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _openUrl(card.linkJNE!),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('VER HOJA DE VIDA EN JNE',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorAccentInk,
                              side: BorderSide(color: colorAccentInk.withAlpha(120)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Color nivelColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageService.caricature(card.caricatureWebpId, width: 80, height: 80),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.nombre, style: const TextStyle(
                      color: colorTextPrimary, fontSize: 20,
                      fontWeight: FontWeight.w900, height: 1.2)),
                    const SizedBox(height: 4),
                    if (card.partido != null)
                      Row(children: [
                        ImageService.partyLogo(card.partido, size: 22),
                        const SizedBox(width: 6),
                        Flexible(child: Text(card.partido!,
                          style: const TextStyle(color: colorTextSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                          maxLines: 2, overflow: TextOverflow.ellipsis)),
                      ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 0.5, color: colorDivider),
          const SizedBox(height: 12),
          Row(
            children: [
              if (card.cargo != null) _badge(Icons.how_to_vote_outlined, card.cargo!),
              if (card.region != null && card.region!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _badge(Icons.location_on_outlined, card.region!),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: nivelColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: nivelColor.withAlpha(100)),
                ),
                child: Text(card.nivel.toUpperCase(), style: TextStyle(
                  color: nivelColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          if (card.totalRedFlags > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorAccentRed.withAlpha(10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '🚩 ${card.totalRedFlags} señales de alerta encontradas',
                style: const TextStyle(color: colorAccentRed, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: colorAccentInk, size: 14),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: colorAccentInk, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _section(IconData icon, String title, Color color, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title.toUpperCase(), style: TextStyle(color: color, fontSize: 13,
            fontWeight: FontWeight.w800, letterSpacing: 1)),
        ]),
        const SizedBox(height: 10),
        Container(height: 0.5, color: colorDivider),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  Widget _listSection(String title, IconData icon, Color color, List<String> items) {
    return _section(icon, title, color, Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) => Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: e.key < items.length - 1 ? 10 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color.withAlpha(100), width: 3)),
        ),
        child: Text(e.value, style: const TextStyle(
          color: colorTextPrimary, fontSize: 15, height: 1.5)),
      )).toList(),
    ));
  }


  Widget _pensionBadge() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorBanderaRoja.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorBanderaRoja, width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: colorBanderaRoja.withAlpha(30), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.child_care, color: colorBanderaRoja, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DEBE PENSIÓN ALIMENTICIA', style: TextStyle(
            color: colorBanderaRoja, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          SizedBox(height: 2),
          Text('Registrado en el REDAM', style: TextStyle(color: colorBanderaRoja, fontSize: 13)),
        ])),
      ]),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: colorBgWhite, borderRadius: BorderRadius.circular(12),
    border: Border.all(color: colorCardBorder, width: 0.5),
  );

  void _share(BuildContext context) {
    final text = '🔍 ${card.nombre} (${card.partido ?? "Independiente"})\n'
        '📊 Índice de Floro: ${card.indiceFloro}/100 · ${card.nivel}\n'
        '🚩 ${card.totalRedFlags} señales de alerta\n\n'
        '¿Conoces a tu candidato? Descúbrelo en Radar del Floro 🇵🇪\n'
        '#RadarDelFloro #Elecciones2026';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('Perfil copiado al portapapeles'),
      ]),
      backgroundColor: colorAccentInk,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}
