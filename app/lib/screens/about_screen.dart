import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: colorTextPrimary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Acerca de Radar del Floro',
                    style: TextStyle(
                      color: colorTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colorAccentRed,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Center(
                          child: Text(
                            '?!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== QUE ES =====
                    _sectionTitle('1. ¿Qué es Radar del Floro?'),
                    _paragraph(
                      'Radar del Floro es una herramienta informativa y satírica '
                      'diseñada para que los ciudadanos peruanos conozcan mejor a '
                      'sus candidatos en las Elecciones Generales 2026. '
                      'A través de un formato de juego interactivo, presentamos '
                      'información pública sobre los candidatos para fomentar '
                      'el voto informado.',
                    ),

                    // ===== PROPOSITO =====
                    _sectionTitle('2. Propósito'),
                    _bulletList([
                      'Fomentar el voto informado entre los ciudadanos peruanos.',
                      'Hacer accesible la información pública de los candidatos de manera entretenida.',
                      'Destacar antecedentes, controversias y señales de alerta verificables.',
                      'No buscamos influir en la decisión de voto hacia ningún candidato o partido en particular.',
                    ]),

                    // ===== FUENTES =====
                    _sectionTitle('3. Fuentes de información'),
                    _paragraph(
                      'Toda la información presentada proviene de fuentes públicas y verificables:',
                    ),
                    _bulletList([
                      'JNE - Jurado Nacional de Elecciones (Voto Informado): Hojas de vida, declaraciones juradas y antecedentes oficiales.',
                      'REDAM - Registro de Deudores Alimentarios Morosos: Información sobre pensiones alimenticias.',
                      'Medios periodísticos nacionales: Reportajes e investigaciones publicadas.',
                      'Poder Judicial y Ministerio Público: Procesos judiciales de acceso público.',
                    ]),

                    // ===== IA =====
                    _sectionTitle('4. Uso de Inteligencia Artificial'),
                    _infoBox(
                      'Este aplicativo utiliza Inteligencia Artificial (Google Gemini) '
                      'para dos funciones específicas:',
                      colorAccentInk,
                    ),
                    _bulletList([
                      'Generación de caricaturas: Las imágenes de los candidatos son caricaturas generadas por IA con fines satíricos. No son fotografías reales ni pretenden ser representaciones fieles.',
                      'Recopilación de información: Se utiliza IA con acceso a búsqueda web para recopilar y resumir información pública disponible sobre cada candidato.',
                    ]),
                    _infoBox(
                      'La información generada por IA puede contener errores o '
                      'imprecisiones. Recomendamos siempre verificar la información '
                      'en las fuentes originales antes de tomar decisiones.',
                      colorMuchoFloro,
                    ),

                    // ===== INDICE DE FLORO =====
                    _sectionTitle('5. Índice de Floro y clasificaciones'),
                    _paragraph(
                      'El "Índice de Floro" y las clasificaciones (Puro Floro, '
                      'Bandera Roja, Sospechoso, Pasa Raspando) son indicadores '
                      'basados en la cantidad y gravedad de los antecedentes '
                      'públicos encontrados. Son herramientas orientativas y '
                      'no constituyen un juicio legal ni definitivo sobre ningún candidato.',
                    ),

                    // ===== NO SOMOS =====
                    _sectionTitle('6. Lo que NO somos'),
                    _bulletList([
                      'No somos un medio de comunicación oficial.',
                      'No somos una entidad del Estado ni estamos afiliados a ningún organismo electoral.',
                      'No estamos afiliados a ningún partido político.',
                      'No emitimos opiniones editoriales sobre candidatos.',
                      'No recomendamos votar por ningún candidato en particular.',
                    ]),

                    // ===== PRIVACIDAD =====
                    _sectionTitle('7. Privacidad'),
                    _paragraph(
                      'Radar del Floro no recopila datos personales de los usuarios. '
                      'No requiere registro, no almacena información de navegación '
                      'y no utiliza cookies de rastreo. Los puntajes del juego se '
                      'almacenan únicamente en el dispositivo del usuario.',
                    ),

                    // ===== SÁTIRA =====
                    _sectionTitle('8. Contenido satírico'),
                    _infoBox(
                      'Las caricaturas, frases del narrador y elementos humorísticos '
                      'son contenido satírico amparado en la libertad de expresión. '
                      'No tienen intención de difamar ni injuriar a ninguna persona. '
                      'La sátira política es una tradición democrática reconocida '
                      'constitucionalmente.',
                      colorPasaRaspando,
                    ),

                    // ===== ERRORES =====
                    _sectionTitle('9. Correcciones y errores'),
                    _paragraph(
                      'Si encuentras información incorrecta sobre algún candidato, '
                      'agradecemos que nos lo reportes. Nos comprometemos a '
                      'corregir errores verificables en el menor tiempo posible.',
                    ),

                    // ===== CONTACTO =====
                    _sectionTitle('10. Contacto'),
                    _paragraph(
                      'Para reportar errores, sugerencias o consultas:',
                    ),
                    const SizedBox(height: 8),
                    _contactButton(
                      icon: Icons.email_outlined,
                      label: 'contacto@radardelfloro.pe',
                      onTap: () => _openUrl('mailto:contacto@radardelfloro.pe'),
                    ),
                    const SizedBox(height: 16),

                    // ===== DISCLAIMER FINAL =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorTextPrimary.withAlpha(8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorDivider),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'DISCLAIMER',
                            style: TextStyle(
                              color: colorTextTertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'La información presentada en esta aplicación es de carácter '
                            'informativo y satírico. No nos hacemos responsables por '
                            'decisiones tomadas en base a esta información. '
                            'Recomendamos consultar siempre las fuentes oficiales '
                            'del JNE (votoinformado.jne.gob.pe) para obtener '
                            'información completa y actualizada sobre los candidatos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorTextTertiary,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Radar del Floro v1.0 · Elecciones 2026',
                        style: TextStyle(
                          color: colorTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: colorTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: colorTextSecondary,
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 6, color: colorTextTertiary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: colorTextSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _infoBox(String text, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorBgWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorCardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorAccentInk, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: colorAccentInk,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
