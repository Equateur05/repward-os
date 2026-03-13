import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../config/theme.dart';
import '../../../services/app_state.dart';
import '../../../widgets/glass_card.dart';

class TeamTab extends StatelessWidget {
  const TeamTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            appState.t('teamTitle'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            appState.t('teamSubtitle'),
            style: TextStyle(fontSize: 14, color: AppColors.slate400),
          ),
          const SizedBox(height: 24),

          // Coming soon card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFFACC15).withValues(alpha: 0.1),
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.trophy, size: 14, color: Color(0xFFFACC15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Classement de l\'\u00E9quipe',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 8, color: const Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            'Bient\u00F4t disponible',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      FaIcon(FontAwesomeIcons.users, size: 48, color: AppColors.slate700),
                      const SizedBox(height: 16),
                      const Text(
                        'Gestion d\'\u00E9quipe',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invitez vos collaborateurs, suivez leurs performances\net cr\u00E9ez un classement motiv\u00E9.',
                        style: TextStyle(fontSize: 13, color: AppColors.slate400, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FOMO toggle
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withValues(alpha: 0.2),
                        AppColors.success.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.bell, size: 18, color: AppColors.success),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bulles FOMO Social Proof',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '"Marie vient de laisser un avis 5\u2605" appara\u00EEt en temps r\u00E9el',
                        style: TextStyle(fontSize: 12, color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: appState.fomoEnabled,
                  onChanged: (v) => appState.setFomoEnabled(v),
                  activeThumbColor: AppColors.success,
                  activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Add member
          Opacity(
            opacity: 0.5,
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const FaIcon(FontAwesomeIcons.userPlus, size: 14),
                label: const Text('Inviter un membre', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandLight,
                  side: BorderSide(color: AppColors.brand.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
