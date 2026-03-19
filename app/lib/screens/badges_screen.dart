import 'package:flutter/material.dart';
import '../data/badge_service.dart';
import '../utils/constants.dart';

/// Badges / Achievements screen
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = BadgeService.unlockedBadges;
    final locked = BadgeService.lockedBadges;
    final total = BadgeService.totalBadges;
    final count = BadgeService.totalUnlocked;

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
                      'LOGROS',
                      style: TextStyle(
                        color: colorTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(
                    '$count/$total',
                    style: const TextStyle(
                      color: colorAccentGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Progress bar
            Container(
              color: colorBgWhite,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: colorChipDefault,
                      valueColor: const AlwaysStoppedAnimation<Color>(colorAccentGold),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count == total
                        ? '¡Todos los logros desbloqueados!'
                        : '${total - count} logros por desbloquear',
                    style: const TextStyle(
                      color: colorTextTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: colorDivider),

            // Badges grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (unlocked.isNotEmpty) ...[
                      _sectionLabel('DESBLOQUEADOS'),
                      const SizedBox(height: 8),
                      ...unlocked.map((b) => _badgeCard(b, true)),
                      const SizedBox(height: 16),
                    ],
                    if (locked.isNotEmpty) ...[
                      _sectionLabel('POR DESBLOQUEAR'),
                      const SizedBox(height: 8),
                      ...locked.map((b) => _badgeCard(b, false)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: colorTextSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _badgeCard(GameBadge badge, bool unlocked) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? colorBgWhite : colorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: unlocked ? colorAccentGold.withAlpha(80) : colorCardBorder,
          width: unlocked ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: unlocked
                  ? colorAccentGold.withAlpha(20)
                  : colorChipDefault,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                unlocked ? badge.emoji : '🔒',
                style: TextStyle(
                  fontSize: unlocked ? 24 : 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.title,
                  style: TextStyle(
                    color: unlocked ? colorTextPrimary : colorTextTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: TextStyle(
                    color: unlocked ? colorTextSecondary : colorTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: colorAccentGold, size: 20),
        ],
      ),
    );
  }
}
