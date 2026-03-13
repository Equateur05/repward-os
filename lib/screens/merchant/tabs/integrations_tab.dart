import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../config/theme.dart';
import '../../../services/app_state.dart';
import '../../../widgets/glass_card.dart';

class IntegrationsTab extends StatefulWidget {
  const IntegrationsTab({super.key});

  @override
  State<IntegrationsTab> createState() => _IntegrationsTabState();
}

class _IntegrationsTabState extends State<IntegrationsTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            appState.t('integrationsTitle'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            appState.t('integrationsSubtitle'),
            style: TextStyle(fontSize: 14, color: AppColors.slate400),
          ),
          const SizedBox(height: 24),

          // Chrome extension banner with shimmer
          _buildChromeBanner(),
          const SizedBox(height: 32),

          // Section 1: Direct API
          _buildSectionHeader(
            'Connexion directe API',
            'Lecture + Réponse automatique — Repward gère tout pour vous',
            AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildAPIGrid(),
          const SizedBox(height: 32),

          // Section 2: Chrome Extension
          _buildSectionHeader(
            'Via Extension Chrome',
            "L'IA vous assistera directement sur le site",
            AppColors.brand,
            comingSoon: true,
          ),
          const SizedBox(height: 16),
          _buildExtensionGrid(),
          const SizedBox(height: 32),

          // Section 3: Manual
          _buildSectionHeader(
            'Méthode Manuelle',
            "Toujours disponible, pour n'importe quelle plateforme",
            AppColors.warning,
          ),
          const SizedBox(height: 16),
          _buildManualSection(appState),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildChromeBanner() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.brand.withValues(alpha: 0.2),
                AppColors.brandDarker.withValues(alpha: 0.2),
              ],
            ),
            border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              // Shimmer overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment(-1.0 + 2.0 * _shimmerController.value, -0.3),
                        end: Alignment(0.0 + 2.0 * _shimmerController.value, 0.3),
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                ),
              ),
              // Content
              child!,
            ],
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.chrome, size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Extension Chrome Repward',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Couvre 5 plateformes d\'un coup : Airbnb, Booking, TripAdvisor, TheFork, Expedia',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brandLight),
                ),
                const SizedBox(height: 4),
                Text(
                  'L\'extension détecte automatiquement vos avis et injecte un bouton Répondre avec IA directement sur chaque plateforme.',
                  style: TextStyle(fontSize: 12, color: AppColors.slate300),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 12, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  'Bientôt disponible',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color, {bool comingSoon = false}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: color.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        if (comingSoon) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Bientôt',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAPIGrid() {
    final platforms = [
      _PlatformData('Google Business', 'OAuth 2.0 — Avis Google Maps', FontAwesomeIcons.google, AppColors.google),
      _PlatformData('Trustpilot', 'OAuth 2.0 — Avis vérifiés', FontAwesomeIcons.star, AppColors.trustpilot),
      _PlatformData('Facebook', 'OAuth 2.0 via Meta — Pages', FontAwesomeIcons.facebook, AppColors.facebook),
      _PlatformData('Instagram', 'Via Facebook Business', FontAwesomeIcons.instagram, AppColors.instagram, disabled: true),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        if (isNarrow) {
          return Column(
            children: platforms.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPlatformCard(p),
            )).toList(),
          );
        }
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: platforms.map((p) => _buildPlatformCard(p)).toList(),
        );
      },
    );
  }

  Widget _buildPlatformCard(_PlatformData p) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          left: BorderSide(color: p.color, width: 4),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: FaIcon(p.icon, size: 16, color: p.color)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(p.subtitle, style: TextStyle(fontSize: 10, color: AppColors.slate400)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.slate700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Non connecté',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.slate400),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: p.disabled ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connexion ${p.name} bientôt disponible. Utilisez la méthode manuelle en attendant.'),
                      backgroundColor: AppColors.brand,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                icon: FaIcon(p.icon, size: 12),
                label: Text(p.disabled ? 'Activé via Facebook' : 'Se connecter', style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.disabled ? AppColors.slate800 : p.color.withValues(alpha: 0.2),
                  foregroundColor: p.disabled ? AppColors.slate500 : p.color,
                  side: BorderSide(color: p.disabled ? Colors.white.withValues(alpha: 0.05) : p.color.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtensionGrid() {
    final platforms = [
      {'name': 'Airbnb', 'sub': 'Locations & Expériences', 'icon': FontAwesomeIcons.airbnb, 'color': AppColors.airbnb},
      {'name': 'Booking.com', 'sub': 'Hébergements', 'icon': FontAwesomeIcons.hotel, 'color': const Color(0xFF003580)},
      {'name': 'TripAdvisor', 'sub': 'Voyages & Hôtels', 'icon': FontAwesomeIcons.mapLocationDot, 'color': AppColors.tripadvisor},
      {'name': 'TheFork', 'sub': 'Réservations resto', 'icon': FontAwesomeIcons.utensils, 'color': AppColors.thefork},
      {'name': 'Expedia', 'sub': 'Voyages & Séjours', 'icon': FontAwesomeIcons.plane, 'color': const Color(0xFF00008C)},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: platforms.map((p) {
        final color = p['color'] as Color;
        return SizedBox(
          width: 200,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: Colors.white.withValues(alpha: 0.08),
            child: Opacity(
              opacity: 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: FaIcon(p['icon'] as IconData, size: 16, color: color)),
                  ),
                  const SizedBox(height: 12),
                  Text(p['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(p['sub'] as String, style: TextStyle(fontSize: 10, color: AppColors.slate400)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.slate900.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '→ Copier la réponse\n    IA et collez-la',
                      style: TextStyle(fontSize: 10, color: AppColors.slate300),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManualSection(AppState appState) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.paste, size: 20, color: AppColors.warning),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Copiez-collez un avis depuis n\'importe quelle plateforme',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Utilisez le bouton « + Ajouter un avis manuellement » dans le Hub Messagerie.',
                  style: TextStyle(fontSize: 10, color: AppColors.slate400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () => appState.setTab('triage'),
            icon: const FaIcon(FontAwesomeIcons.plus, size: 10),
            label: const Text('Ajouter un avis', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformData {
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool disabled;

  _PlatformData(this.name, this.subtitle, this.icon, this.color, {this.disabled = false});
}
