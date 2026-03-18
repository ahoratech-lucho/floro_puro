import 'package:flutter/material.dart';
import '../utils/constants.dart';

class InstructionScreen extends StatelessWidget {
  final VoidCallback onStart;

  const InstructionScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Header icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorAccentRed.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorAccentRed.withAlpha(80)),
                ),
                child: const Icon(Icons.radar, color: colorAccentRed, size: 36),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Detecta malas prácticas\nantes de que te vendan floro',
                style: TextStyle(
                  color: colorTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Instructions card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorBgWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorCardBorder, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CÓMO JUGAR',
                      style: TextStyle(
                        color: colorTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _step(
                      '1',
                      'Lee el perfil',
                      'Revisa los datos del candidato: cargo, controversias, antecedentes.',
                      Icons.article_outlined,
                    ),
                    _step(
                      '2',
                      'Elige tu veredicto',
                      'Clasifícalo según tu instinto político.',
                      Icons.touch_app_outlined,
                    ),
                    _step(
                      '3',
                      'Descubre la verdad',
                      'Compara tu respuesta con nuestro análisis y fuentes verificadas.',
                      Icons.fact_check_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4 options legend
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorBgWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorCardBorder, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TUS OPCIONES',
                      style: TextStyle(
                        color: colorTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _optionRow(Icons.close_rounded, colorAccentRed, 'Puro Floro',
                        'Definitivamente turbio'),
                    _optionRow(Icons.flag_rounded, colorBanderaRoja, 'Bandera Roja',
                        'Señales graves de alerta'),
                    _optionRow(Icons.help_outline_rounded, colorMuchoFloro,
                        'Sospechoso', 'Algo no cuadra'),
                    _optionRow(Icons.check_rounded, colorPasaRaspando,
                        'Pasa Raspando', 'Parece limpio... por ahora'),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccentRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ACTIVAR RADAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorAccentRed,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: colorTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: colorTextTertiary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionRow(IconData icon, Color color, String label, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                color: colorTextTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
