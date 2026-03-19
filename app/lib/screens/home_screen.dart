import 'package:flutter/material.dart';
import '../data/card_repository.dart';
import '../data/score_service.dart';
import '../data/badge_service.dart';
import '../data/theme_service.dart';
import '../data/sound_service.dart';
import '../main.dart' show themeService;
import '../utils/constants.dart';
import 'instruction_screen.dart';
import 'game_screen.dart';
import 'about_screen.dart';
import 'explore_screen.dart';
import 'ranking_screen.dart';
import 'stats_screen.dart';
import 'badges_screen.dart';
import 'compare_screen.dart';

const int cardsQuickMode = 5;

class HomeScreen extends StatefulWidget {
  final CardRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCargo = 'PRESIDENTE'; // Default to Presidentes
  String? _selectedRegion;
  bool _onlyInteresting = false;

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final cargoTypes = repo.cargoTypes;
    final regionTypes = repo.regionTypesForCargo(_selectedCargo);
    final totalCards = repo.totalCards;
    final interestingCount = repo.interestingCards.length;

    return Scaffold(
      backgroundColor: colorBgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ===== NEWSPAPER MASTHEAD — fixed top =====
            Container(
              width: double.infinity,
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  Container(height: 2, color: colorTextPrimary),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EDICIÓN ESPECIAL',
                        style: TextStyle(
                          color: colorTextTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const Text(
                        'PERÚ 2026',
                        style: TextStyle(
                          color: colorTextTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RADAR DEL FLORO',
                    style: TextStyle(
                      color: colorTextPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(height: 1, color: colorTextPrimary),
                  const SizedBox(height: 2),
                  Container(height: 3, color: colorTextPrimary),
                ],
              ),
            ),

            // ===== SCROLLABLE CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // Subtitle
                    const Text(
                      'Guía satírica para detectar el floro político',
                      style: TextStyle(
                        color: colorTextSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ===== HERO — big red CTA area =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      decoration: BoxDecoration(
                        color: colorAccentRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          // ?! logo
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Center(
                              child: Text(
                                '?!',
                                style: TextStyle(
                                  color: colorAccentRed,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            '¿Puedes detectar\nel floro político?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalCards candidatos investigados · $interestingCount con alertas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // PLAY BUTTONS ROW
                          Row(
                            children: [
                              // NORMAL MODE
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => _startGame(cardsPerRound),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: colorAccentRed,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_arrow_rounded, size: 22),
                                        SizedBox(width: 4),
                                        Text(
                                          'DETECTAR FLORO',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // QUICK MODE
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () => _startGame(cardsQuickMode),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withAlpha(40),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: Colors.white54),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.bolt_rounded, size: 18),
                                        SizedBox(width: 4),
                                        Text(
                                          'RÁPIDO',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$cardsPerRound cartas          $cardsQuickMode cartas',
                            style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Hint
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_outlined, color: colorTextMuted, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Clasifica a cada candidato según tu instinto',
                          style: TextStyle(color: colorTextMuted, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ===== HOW IT WORKS — 4 options =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorCardBorder, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '4 VEREDICTOS',
                            style: TextStyle(
                              color: colorTextSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _howStep('✗', 'PURO\nFLORO', colorAccentRed, 'Turbio')),
                              Container(width: 0.5, height: 50, color: colorDivider),
                              Expanded(child: _howStep('⚑', 'BANDERA\nROJA', colorBanderaRoja, 'Grave')),
                              Container(width: 0.5, height: 50, color: colorDivider),
                              Expanded(child: _howStep('?', 'SOSPE-\nCHOSO', colorMuchoFloro, 'Dudoso')),
                              Container(width: 0.5, height: 50, color: colorDivider),
                              Expanded(child: _howStep('✓', 'PASA\nRASPANDO', colorPasaRaspando, 'Limpio')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ===== FILTER BY CARGO =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorBgWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorCardBorder, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.how_to_vote_outlined,
                                  color: colorTextSecondary, size: 15),
                              SizedBox(width: 6),
                              Text(
                                'FILTRAR POR CARGO',
                                style: TextStyle(
                                  color: colorTextSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _cargoChip('Todos', null),
                              ...cargoTypes.map((c) => _cargoChip(c, c)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ===== FILTER BY REGION (Diputado or Senador) =====
                    if ((_selectedCargo == 'DIPUTADO' || _selectedCargo == 'SENADOR') && regionTypes.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorBgWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorCardBorder, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    color: colorTextSecondary, size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'FILTRAR POR REGIÓN',
                                  style: TextStyle(
                                    color: colorTextSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _regionChip('Todas', null),
                                ...regionTypes.map((r) => _regionChip(r, r)),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // ===== SOSPECHOSOS TOGGLE =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _onlyInteresting
                            ? colorAccentRedLight
                            : colorBgWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _onlyInteresting
                              ? colorAccentRed.withAlpha(80)
                              : colorCardBorder,
                          width: _onlyInteresting ? 1 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.gpp_maybe_outlined,
                            color: _onlyInteresting
                                ? colorAccentRed
                                : colorTextTertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Solo los sospechosos',
                                  style: TextStyle(
                                    color: _onlyInteresting
                                        ? colorAccentRed
                                        : colorTextPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  'Con controversias verificadas',
                                  style: TextStyle(
                                    color: colorTextTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _onlyInteresting,
                            onChanged: (v) =>
                                setState(() => _onlyInteresting = v),
                            activeColor: colorAccentRed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ===== EXPLORE / RANKING / STATS BUTTONS =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorBgWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorCardBorder, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.apps_outlined, color: colorTextSecondary, size: 15),
                              SizedBox(width: 6),
                              Text(
                                'EXPLORAR',
                                style: TextStyle(
                                  color: colorTextSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _navButton(
                            icon: Icons.search_outlined,
                            label: 'Explorador de Candidatos',
                            subtitle: 'Busca y consulta cualquier candidato',
                            color: colorAccentInk,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ExploreScreen(repository: widget.repository)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _navButton(
                                  icon: Icons.emoji_events_outlined,
                                  label: 'Ranking',
                                  subtitle: 'Top floreros',
                                  color: colorAccentRed,
                                  compact: true,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => RankingScreen(repository: widget.repository)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _navButton(
                                  icon: Icons.bar_chart_outlined,
                                  label: 'Estadísticas',
                                  subtitle: 'Datos generales',
                                  color: colorDudoso,
                                  compact: true,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => StatsScreen(repository: widget.repository)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _navButton(
                                  icon: Icons.compare_arrows_outlined,
                                  label: 'Comparador',
                                  subtitle: 'Cara a cara',
                                  color: const Color(0xFF6C5CE7),
                                  compact: true,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => CompareScreen(repository: widget.repository)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _navButton(
                                  icon: Icons.military_tech_outlined,
                                  label: 'Logros',
                                  subtitle: '${BadgeService.totalUnlocked}/${BadgeService.totalBadges}',
                                  color: colorAccentGold,
                                  compact: true,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const BadgesScreen()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ===== PLAYER STATS (only if has played) =====
                    if (ScoreService.hasPlayed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorBgWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorCardBorder, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.emoji_events_outlined,
                                    color: colorAccentGold, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'TUS ESTADÍSTICAS',
                                  style: TextStyle(
                                    color: colorTextSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _statCard(
                                  '${ScoreService.bestPercent}%',
                                  'Mejor score',
                                  colorPasaRaspando,
                                ),
                                const SizedBox(width: 8),
                                _statCard(
                                  '🔥 ${ScoreService.bestStreak}',
                                  'Mejor racha',
                                  colorAccentGold,
                                ),
                                const SizedBox(width: 8),
                                _statCard(
                                  '${ScoreService.totalGames}',
                                  'Partidas',
                                  colorAccentInk,
                                ),
                              ],
                            ),
                            if (ScoreService.bestTitle.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Mejor rango: "${ScoreService.bestTitle}"',
                                style: const TextStyle(
                                  color: colorTextTertiary,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (ScoreService.hasPlayed) const SizedBox(height: 14),

                    // ===== DARK MODE TOGGLE =====
                    // ===== SETTINGS ROW =====
                    Row(
                      children: [
                        // Dark mode toggle
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              themeService.toggle();
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: colorBgWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorCardBorder, width: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    themeService.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                    color: colorTextTertiary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    themeService.isDark ? 'Modo claro' : 'Modo oscuro',
                                    style: const TextStyle(
                                      color: colorTextTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sound toggle
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              SoundService.toggle();
                              if (SoundService.enabled) SoundService.playTap();
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: colorBgWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colorCardBorder, width: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    SoundService.enabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                                    color: colorTextTertiary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    SoundService.enabled ? 'Sonido ON' : 'Sonido OFF',
                                    style: const TextStyle(
                                      color: colorTextTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ===== FOOTER =====
                    Container(height: 0.5, color: colorDivider),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_outlined,
                            color: colorPasaRaspando, size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          'Datos: JNE Voto Informado + fuentes periodísticas',
                          style: TextStyle(color: colorTextTertiary, fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Proyecto satírico e informativo · No somos medio de comunicación',
                      style: TextStyle(color: colorTextMuted, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: colorTextMuted, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Acerca de · Términos y condiciones',
                            style: TextStyle(
                              color: colorTextMuted,
                              fontSize: 9,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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

  Widget _howStep(String arrow, String label, Color color, String desc) {
    return Column(
      children: [
        Text(
          arrow,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: const TextStyle(
            color: colorTextMuted,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _cargoChip(String label, String? cargo) {
    final selected = _selectedCargo == cargo;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCargo = cargo;
        // Reset region when changing cargo (only diputados/senadores have regions)
        if (cargo != 'DIPUTADO' && cargo != 'SENADOR') _selectedRegion = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colorChipSelected : colorChipDefault,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? colorChipSelected : colorCardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: selected ? Colors.white : colorTextSecondary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _regionChip(String label, String? region) {
    final selected = _selectedRegion == region;
    return GestureDetector(
      onTap: () => setState(() => _selectedRegion = region),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colorAccentRed : colorChipDefault,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? colorAccentRed : colorCardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : colorTextSecondary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: colorTextTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: compact ? 18 : 22),
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colorTextPrimary,
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorTextTertiary,
                      fontSize: compact ? 9 : 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withAlpha(120), size: 18),
          ],
        ),
      ),
    );
  }

  void _startGame(int count) {
    final cards = widget.repository.selectRound(
      count: count,
      cargoFilter: _selectedCargo,
      regionFilter: _selectedRegion,
      onlyInteresting: _onlyInteresting,
    );

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('No hay cartas con ese filtro'),
            ],
          ),
          backgroundColor: colorAccentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InstructionScreen(
          onStart: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(cards: cards),
              ),
            );
          },
        ),
      ),
    );
  }
}
