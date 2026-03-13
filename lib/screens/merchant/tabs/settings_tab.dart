import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../config/constants.dart';
import '../../../services/app_state.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/glass_card.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _gmapsController;

  bool _googleConnected = false;
  bool _multiEstablishments = false;
  bool _alertsEnabled = true;
  bool _fomoEnabled = true;
  bool _apiKeyVisible = false;
  String get _apiKey {
    final uid = SupabaseService.user?.id;
    if (uid == null || uid.length < 12) return 'Non connect\u00E9';
    return 'rw_${uid.substring(0, 8)}...${uid.substring(uid.length - 4)}';
  }

  String get _apiKeyFull {
    final uid = SupabaseService.user?.id;
    if (uid == null) return 'Non connect\u00E9';
    return 'rw_$uid';
  }

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _nameController = TextEditingController(text: appState.merchant.businessName);
    _emailController = TextEditingController(text: appState.merchant.email);
    _phoneController = TextEditingController(text: appState.merchant.phone);
    _gmapsController = TextEditingController(text: appState.googleMapsUrl);
    _fomoEnabled = appState.fomoEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gmapsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isWide = MediaQuery.of(context).size.width >= 1024;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            appState.t('settingsTitle'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            appState.t('settingsSubtitle'),
            style: TextStyle(fontSize: 14, color: AppColors.slate400),
          ),
          const SizedBox(height: 24),

          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAccountCard(appState)),
                    const SizedBox(width: 32),
                    Expanded(child: _buildPlansCard(appState)),
                  ],
                )
              : Column(
                  children: [
                    _buildAccountCard(appState),
                    const SizedBox(height: 24),
                    _buildPlansCard(appState),
                  ],
                ),
          const SizedBox(height: 24),

          // Language selector
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
                        color: AppColors.brand.withValues(alpha: 0.1),
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.globe, size: 14, color: AppColors.brand),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Langue', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.supportedLanguages.map((lang) {
                    final active = appState.currentLang == lang['code'];
                    return GestureDetector(
                      onTap: () => appState.setLanguage(lang['code']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: active ? AppColors.brand.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: active ? AppColors.brand.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          '${lang['flag']} ${lang['name']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: active ? AppColors.brandLight : AppColors.slate400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Google Business Profile OAuth
          _buildGoogleBusinessCard(),
          const SizedBox(height: 24),

          // Two-column layout for toggles on wide screens
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMultiEstablishmentsCard()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildAlertsCard()),
                  ],
                )
              : Column(
                  children: [
                    _buildMultiEstablishmentsCard(),
                    const SizedBox(height: 24),
                    _buildAlertsCard(),
                  ],
                ),
          const SizedBox(height: 24),

          // FOMO Social Proof
          _buildFomoCard(appState),
          const SizedBox(height: 24),

          // Widget Code
          _buildWidgetCodeCard(),
          const SizedBox(height: 24),

          // API Section
          _buildApiCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Google Business Profile OAuth ──────────────────────────────────────
  Widget _buildGoogleBusinessCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.google.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.google, size: 16, color: AppColors.google),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connecter Google Business Profile',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Synchronisez vos avis Google automatiquement',
                      style: TextStyle(fontSize: 11, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _googleConnected = !_googleConnected;
                });
              },
              icon: FaIcon(
                _googleConnected ? FontAwesomeIcons.check : FontAwesomeIcons.google,
                size: 14,
              ),
              label: Text(_googleConnected ? 'Connecte' : 'Se connecter avec Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _googleConnected
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.google,
                foregroundColor: _googleConnected ? AppColors.success : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Multi-Establishments ──────────────────────────────────────────────
  Widget _buildMultiEstablishmentsCard() {
    return GlassCard(
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
                  color: AppColors.brand.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.building, size: 14, color: AppColors.brand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Multi-Etablissements',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gerez plusieurs points de vente',
                      style: TextStyle(fontSize: 11, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _multiEstablishments,
                onChanged: (v) {
                  setState(() => _multiEstablishments = v);
                },
                activeThumbColor: AppColors.brand,
                activeTrackColor: AppColors.brand.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.warning.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.clock, size: 10, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  'Bientot disponible',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Alerts ────────────────────────────────────────────────────────────
  Widget _buildAlertsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.warningLight.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.bell, size: 14, color: AppColors.warningLight),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alertes Instantanees',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Recevez une notification a chaque nouvel avis',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400),
                ),
              ],
            ),
          ),
          Switch(
            value: _alertsEnabled,
            onChanged: (v) async {
              setState(() => _alertsEnabled = v);
              await SupabaseService.saveAlerts(v, v);
            },
            activeThumbColor: AppColors.warningLight,
            activeTrackColor: AppColors.warningLight.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  // ── FOMO Social Proof ─────────────────────────────────────────────────
  Widget _buildFomoCard(AppState appState) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.brand.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.bell, size: 14, color: AppColors.brand),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FOMO Social Proof',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  'Affichez les avis recents en popup sur votre site',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400),
                ),
              ],
            ),
          ),
          Switch(
            value: _fomoEnabled,
            onChanged: (v) {
              setState(() => _fomoEnabled = v);
              appState.setFomoEnabled(v);
            },
            activeThumbColor: AppColors.brand,
            activeTrackColor: AppColors.brand.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  // ── Widget Code ───────────────────────────────────────────────────────
  Widget _buildWidgetCodeCard() {
    const widgetCode = '<script src="https://repward.vercel.app/widget.js"></script>';
    return GlassCard(
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
                  color: AppColors.brand.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.code, size: 14, color: AppColors.brand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Widget Integrable',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Affichez vos meilleurs avis sur votre site web',
                      style: TextStyle(fontSize: 11, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.slate900.withValues(alpha: 0.8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: SelectableText(
              widgetCode,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: AppColors.successLight,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: widgetCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code copie !'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.copy, size: 12),
              label: const Text('Copier le code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandLight,
                side: BorderSide(color: AppColors.brand.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── API Section ───────────────────────────────────────────────────────
  Widget _buildApiCard() {
    return GlassCard(
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
                  color: AppColors.brand.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.terminal, size: 14, color: AppColors.brand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Repward',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Integrez Repward dans vos outils',
                      style: TextStyle(fontSize: 11, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // API Key display
          Text(
            'CLE API',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.slate400,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.slate900.withValues(alpha: 0.8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _apiKeyVisible ? _apiKeyFull : _apiKey,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: AppColors.slate300,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() => _apiKeyVisible = !_apiKeyVisible);
                  },
                  child: FaIcon(
                    _apiKeyVisible ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                    size: 12,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _apiKeyFull));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cle API copiee !'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const FaIcon(FontAwesomeIcons.copy, size: 12, color: AppColors.slate400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Regenerate + Documentation
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Régénération de clé API bientôt disponible'),
                          backgroundColor: AppColors.slate800,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 10),
                    label: const Text('Regenerer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dangerLight,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Documentation API bientôt disponible'),
                          backgroundColor: AppColors.slate800,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.book, size: 10),
                    label: const Text('Documentation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandLight,
                      side: BorderSide(color: AppColors.brand.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Account Card ──────────────────────────────────────────────────────
  Widget _buildAccountCard(AppState appState) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
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
                  color: AppColors.brand.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.building, size: 14, color: AppColors.brand),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Etablissement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField('NOM', _nameController),
          const SizedBox(height: 16),
          _buildTextField('EMAIL', _emailController, type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('TELEPHONE', _phoneController, type: TextInputType.phone),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                final appState = context.read<AppState>();
                appState.merchant.businessName = _nameController.text;
                appState.merchant.email = _emailController.text;
                appState.merchant.phone = _phoneController.text;
                await SupabaseService.saveMerchant(appState.merchant);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil sauvegard\u00E9 !'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const FaIcon(FontAwesomeIcons.floppyDisk, size: 12),
              label: const Text('Sauvegarder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          // Google Maps URL
          Text(
            'LIEN GOOGLE MAPS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.slate400,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Les clients 5\u2605 seront rediriges vers votre fiche Google',
            style: TextStyle(fontSize: 10, color: AppColors.slate500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _gmapsController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'https://g.page/mon-commerce/review',
                    hintStyle: TextStyle(color: AppColors.slate600),
                    filled: true,
                    fillColor: AppColors.slate900.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => appState.setGoogleMapsUrl(_gmapsController.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.google.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.google.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const FaIcon(FontAwesomeIcons.floppyDisk, size: 12, color: AppColors.google),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 16),
          // AI Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.success.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.robot, size: 12, color: AppColors.success),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'IA Gemini connectee',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                    Text(
                      'Reponses automatiques incluses',
                      style: TextStyle(fontSize: 10, color: AppColors.slate400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Plans Card ────────────────────────────────────────────────────────
  Widget _buildPlansCard(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  AppColors.brand.withValues(alpha: 0.2),
                  AppColors.brandDarker.withValues(alpha: 0.2),
                ],
              ),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.crown, size: 16, color: Color(0xFFFACC15)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Abonnements Repward',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: AppConstants.subscriptionPlans.map((plan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(plan: plan, currentPlan: appState.merchant.plan),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Sans engagement \u00b7 Annulable \u00e0 tout moment \u00b7 G\u00e9rez votre abonnement sur repward.vercel.app',
              style: TextStyle(fontSize: 10, color: AppColors.slate500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.slate400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate900.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brand),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String currentPlan;

  const _PlanCard({required this.plan, required this.currentPlan});

  @override
  Widget build(BuildContext context) {
    final isActive = currentPlan == plan.id;
    final isPopular = plan.popular;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isPopular
            ? AppColors.brand.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: isPopular
              ? AppColors.brand.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                plan.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (isPopular) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brand, AppColors.brandDark],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Populaire',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
              const Spacer(),
              // Promo badge
              if (plan.promo.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColors.success.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    plan.promo,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.successLight),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Price row with original price crossed out
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (plan.originalPrice.isNotEmpty) ...[
                Text(
                  '${plan.originalPrice}\u20ac',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate500,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.slate500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${plan.price}\u20ac',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isPopular ? AppColors.brandLight : Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '/mois',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.label,
            style: TextStyle(fontSize: 12, color: AppColors.slate400),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isActive ? null : () async {
                final uri = Uri.parse(AppConstants.subscriptionWebUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? AppColors.slate700
                    : (isPopular ? AppColors.brand : AppColors.slate800),
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.slate700,
                disabledForegroundColor: AppColors.slate500,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: isPopular ? 4 : 0,
                shadowColor: isPopular ? AppColors.brand.withValues(alpha: 0.4) : Colors.transparent,
              ),
              child: Text(
                isActive ? 'Plan actuel' : 'S\u2019abonner',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
