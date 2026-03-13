import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../config/theme.dart';
import '../../../services/app_state.dart';
import '../../../models/industry.dart';
import '../../../widgets/glass_card.dart';

class PortalTab extends StatefulWidget {
  const PortalTab({super.key});

  @override
  State<PortalTab> createState() => _PortalTabState();
}

class _PortalTabState extends State<PortalTab> {
  bool _qrGenerated = false;
  String _qrData = '';

  void _generateQR() {
    final appState = context.read<AppState>();
    final token = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    setState(() {
      _qrData = 'https://repward.vercel.app/r/${appState.merchant.businessName.replaceAll(' ', '-').toLowerCase()}?t=$token';
      _qrGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final ind = appState.industry;
    final isWideXL = MediaQuery.of(context).size.width >= 1280;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            appState.t('portalTitle'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            appState.t('portalSubtitle'),
            style: TextStyle(fontSize: 12, color: AppColors.slate400),
          ),
          const SizedBox(height: 16),

          // Content
          isWideXL
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildConfig(appState, ind)),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 300,
                      child: _buildPhonePreview(appState),
                    ),
                  ],
                )
              : _buildConfig(appState, ind),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildConfig(AppState appState, Industry ind) {
    return Column(
      children: [
        // Industry badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.brand.withValues(alpha: 0.05),
            border: Border.all(color: AppColors.brand.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Text(ind.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                ind.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Défini à l'inscription",
                  style: TextStyle(fontSize: 9, color: AppColors.slate500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Rewards grid
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.brand.withValues(alpha: 0.1),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.gift, size: 10, color: AppColors.brand),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Récompense client',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ind.rewards.map((reward) {
                  final selected = appState.selectedReward == reward;
                  return GestureDetector(
                    onTap: () => appState.setReward(reward),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selected
                            ? AppColors.brand.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.03),
                        border: Border.all(
                          color: selected
                              ? AppColors.brand.withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.1),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        reward,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selected ? AppColors.brandLight : AppColors.slate300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // QR Code + Actions
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (_qrGenerated) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _generateQR,
                        icon: const FaIcon(FontAwesomeIcons.qrcode, size: 12),
                        label: const Text('Générer QR', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  if (_qrGenerated) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _qrData));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lien QR copié ! Faites une capture d\'écran du QR code pour l\'enregistrer.'),
                                backgroundColor: AppColors.brand,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const FaIcon(FontAwesomeIcons.download, size: 12),
                          label: const Text('PNG', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brandLight,
                            side: BorderSide(color: AppColors.brand.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (_qrGenerated) ...[
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.05)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.slate900.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          _qrData,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: AppColors.brandLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _qrData));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.brand.withValues(alpha: 0.2),
                          border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const FaIcon(FontAwesomeIcons.copy, size: 10, color: AppColors.brandLight),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.05)),
              const SizedBox(height: 8),
              // Kiosk + NFC
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mode Kiosque — Bientôt disponible !'),
                              backgroundColor: Color(0xFF22D3EE),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22D3EE),
                          foregroundColor: AppColors.slate900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: const Text('📱 Kiosque', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tags NFC — Commande bientôt disponible !'),
                              backgroundColor: Color(0xFFFACC15),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFACC15),
                          foregroundColor: AppColors.slate900,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: const Text('📡 NFC  49€', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhonePreview(AppState appState) {
    final ind = appState.industry;
    final theme = ind.theme;
    final bizName = appState.merchant.businessName.isNotEmpty ? appState.merchant.businessName : 'Mon Commerce';

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'APERÇU EN TEMPS RÉEL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.slate500,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // iPhone frame with real preview
        Transform.scale(
          scale: 0.82,
          alignment: Alignment.topCenter,
          child: Container(
            width: 300,
            height: 580,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              gradient: const LinearGradient(
                begin: Alignment(-0.6, -0.8),
                end: Alignment(0.6, 0.8),
                colors: [AppColors.slate800, AppColors.slate900],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.slate700, spreadRadius: 2, blurRadius: 0),
                BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 60, offset: const Offset(0, 25)),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Hero image
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  ind.img,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [theme.primary.withValues(alpha: 0.3), theme.accent.withValues(alpha: 0.2)]),
                                      ),
                                      child: Center(child: Text(ind.emoji, style: const TextStyle(fontSize: 32))),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [theme.primary.withValues(alpha: 0.3), theme.accent.withValues(alpha: 0.2)]),
                                    ),
                                    child: Center(child: Text(ind.emoji, style: const TextStyle(fontSize: 32))),
                                  ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, Colors.transparent, const Color(0xFFF8FAFC)],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Business card
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(colors: [theme.primary, theme.accent]),
                                        boxShadow: [BoxShadow(color: theme.primary.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
                                      ),
                                      child: Center(child: Text(ind.emoji, style: const TextStyle(fontSize: 16))),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(bizName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)), textAlign: TextAlign.center),
                                    const SizedBox(height: 2),
                                    Text('Merci pour votre visite !', style: TextStyle(fontSize: 10, color: const Color(0xFF0F172A).withValues(alpha: 0.5))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Reward card
                          Transform.translate(
                            offset: const Offset(0, -12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(colors: [theme.primary, theme.accent]),
                                  boxShadow: [BoxShadow(color: theme.primary.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 15))],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                      child: const Text('CADEAU IMMÉDIAT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1.5)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(appState.selectedReward, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
                                    const SizedBox(height: 6),
                                    Text('Laissez-nous 5 étoiles pour\ndébloquer votre cadeau', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.9)), textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
                // Notch
                Positioned(
                  top: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 28,
                      decoration: BoxDecoration(color: AppColors.slate900, borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
