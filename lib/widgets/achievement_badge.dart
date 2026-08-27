import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String id;
  final double size;
  final double opacity;

  const AchievementBadge({
    super.key,
    required this.id,
    this.size = 56,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        achievementBadgeAsset(id),
        width: size,
        height: size * 1.17,
      ),
    );
  }
}

String achievementBadgeAsset(String id) {
  switch (id) {
    case 'first_scan':
      return 'assets/images/badges/badge_first_scan.svg';
    case 'scan_master':
      return 'assets/images/badges/badge_scan_master.svg';
    case 'protein_king':
      return 'assets/images/badges/badge_protein_king.svg';
    case 'streak_7':
      return 'assets/images/badges/badge_streak_7.svg';
    case 'calo_champ':
      return 'assets/images/badges/badge_calo_champ.svg';
    case 'legend':
      return 'assets/images/badges/badge_legend.svg';
    default:
      return 'assets/images/badges/badge_first_scan.svg';
  }
}
