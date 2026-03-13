import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/app_state.dart';
import '../../services/supabase_service.dart';
import '../../models/merchant.dart';
import '../../models/industry.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 400,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStep(context, appState),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, AppState appState) {
    switch (appState.onboardingStep) {
      case 1:
        return _LanguageStep(key: const ValueKey('step1'));
      case 2:
        return _IndustryStep(key: const ValueKey('step2'));
      case 3:
        return _AccountStep(key: const ValueKey('step3'));
      default:
        return _LanguageStep(key: const ValueKey('step1'));
    }
  }
}

// ========== STEP 1: Language Selection ==========
class _LanguageStep extends StatelessWidget {
  const _LanguageStep({super.key});

  static const _languages = [
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français'},
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español'},
    {'code': 'it', 'flag': '🇮🇹', 'name': 'Italiano'},
    {'code': 'de', 'flag': '🇩🇪', 'name': 'Deutsch'},
    {'code': 'pt', 'flag': '🇵🇹', 'name': 'Português'},
    {'code': 'nl', 'flag': '🇳🇱', 'name': 'Nederlands'},
    {'code': 'ar', 'flag': '🇸🇦', 'name': 'العربية'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brand, AppColors.brandDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.award, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to Repward',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your language',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 24),
        // Language Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: _languages.map((lang) {
            return _LanguageButton(
              flag: lang['flag']!,
              name: lang['name']!,
              onTap: () {
                appState.setLanguage(lang['code']!);
                appState.setOnboardingStep(2);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          'Free registration · No credit card required',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.slate600,
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final String name;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flag,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== STEP 2: Industry Selection ==========
class _IndustryStep extends StatelessWidget {
  const _IndustryStep({super.key});

  static const _industryList = [
    {'id': 'restaurant', 'emoji': '🍽️', 'label': 'Restaurant & Bar'},
    {'id': 'coffee', 'emoji': '☕', 'label': 'Coffee Shop'},
    {'id': 'streetfood', 'emoji': '🌮', 'label': 'Street Food'},
    {'id': 'hotel', 'emoji': '🏨', 'label': 'Hôtel & Spa'},
    {'id': 'airbnb', 'emoji': '🔑', 'label': 'Airbnb'},
    {'id': 'beauty', 'emoji': '✂️', 'label': 'Coiffure & Beauté'},
    {'id': 'retail', 'emoji': '🛍️', 'label': 'Boutique & Retail'},
    {'id': 'bakery', 'emoji': '🥐', 'label': 'Boulangerie'},
    {'id': 'gym', 'emoji': '💪', 'label': 'Sport & Fitness'},
    {'id': 'garage', 'emoji': '🔧', 'label': 'Garage & Auto'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.brand.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            appState.t('onboardStepIndustry'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.brandLight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          appState.t('onboardIndustryTitle'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          appState.t('onboardIndustrySubtitle'),
          style: TextStyle(fontSize: 14, color: AppColors.slate400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Industry Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: _industryList.map((ind) {
            return _IndustryButton(
              emoji: ind['emoji']!,
              label: ind['label']!,
              onTap: () {
                appState.setIndustry(ind['id']!);
                appState.setOnboardingStep(3);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => appState.setOnboardingStep(1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.arrowLeft, size: 12, color: AppColors.slate500),
              const SizedBox(width: 6),
              Text(
                'Retour',
                style: TextStyle(fontSize: 14, color: AppColors.slate500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndustryButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _IndustryButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            color: Colors.white.withValues(alpha: 0.03),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== STEP 3: Account Creation ==========
class _AccountStep extends StatefulWidget {
  const _AccountStep({super.key});

  @override
  State<_AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<_AccountStep> {
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();
  String? _promoStatus;
  Color? _promoStatusColor;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _validatePromo() {
    final appState = context.read<AppState>();
    final promo = appState.validatePromoCode(_promoController.text);
    setState(() {
      if (promo != null) {
        _promoStatus = promo.label;
        _promoStatusColor = AppColors.success;
      } else if (_promoController.text.trim().isNotEmpty) {
        _promoStatus = 'Code invalide';
        _promoStatusColor = AppColors.danger;
      } else {
        _promoStatus = null;
      }
    });
  }

  Future<void> _completeOnboarding() async {
    final appState = context.read<AppState>();
    final name = _nameController.text.trim();
    final business = _businessController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || business.isEmpty || email.isEmpty || password.length < 6) {
      setState(() => _error = appState.t('onboardError'));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authResponse = await SupabaseService.signUp(email: email, password: password);
      if (authResponse.user == null) {
        setState(() {
          _error = 'Erreur lors de la création du compte. Réessayez.';
          _loading = false;
        });
        return;
      }
    } catch (e) {
      // Try sign in if user already exists
      try {
        final signInResponse = await SupabaseService.signIn(email: email, password: password);
        if (signInResponse.user == null) {
          setState(() {
            _error = 'Impossible de se connecter. Vérifiez vos identifiants.';
            _loading = false;
          });
          return;
        }
      } catch (signInError) {
        setState(() {
          _error = 'Erreur de connexion : ${e.toString().contains('already registered') ? 'Email déjà utilisé avec un autre mot de passe.' : e.toString()}';
          _loading = false;
        });
        return;
      }
    }

    final merchant = Merchant(
      name: name,
      email: email,
      businessName: business,
      industry: appState.currentIndustry,
      phone: _phoneController.text.trim(),
      plan: appState.activePromo?.type == PromoType.demo ? 'demo' : 'starter',
      promoCode: _promoController.text.trim().toUpperCase(),
      createdAt: DateTime.now(),
    );

    await appState.completeOnboarding(merchant);

    try {
      await SupabaseService.saveMerchant(merchant);
    } catch (e) {
      debugPrint('saveMerchant error: $e');
    }

    if (appState.activePromo?.type == PromoType.demo) {
      await appState.activateDemo(appState.activePromo!.duration);
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final ind = industries[appState.currentIndustry]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Industry badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.brand.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ind.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                ind.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => appState.setOnboardingStep(2),
                child: FaIcon(FontAwesomeIcons.pen, size: 10, color: AppColors.brandLight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          appState.t('onboardAccountTitle'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          appState.t('onboardAccountSubtitle'),
          style: TextStyle(fontSize: 14, color: AppColors.slate400),
        ),
        const SizedBox(height: 16),
        // Form
        Row(
          children: [
            Expanded(child: _buildField(appState.t('onboardName'), _nameController, 'Jean Dupont')),
            const SizedBox(width: 12),
            Expanded(child: _buildField(appState.t('onboardBusiness'), _businessController, 'Le Gourmet')),
          ],
        ),
        const SizedBox(height: 12),
        _buildField(appState.t('onboardEmail'), _emailController, 'jean@moncommerce.fr', type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildField(appState.t('onboardPassword'), _passwordController, 'Min. 6 caractères', obscure: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildField(appState.t('onboardPhone'), _phoneController, '+33 6 12 34 56 78', type: TextInputType.phone)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.t('onboardPromo'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            hintText: 'DEMO2026',
                            hintStyle: TextStyle(color: AppColors.slate600),
                            filled: true,
                            fillColor: AppColors.slate800.withValues(alpha: 0.8),
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
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _validatePromo,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.brand.withValues(alpha: 0.2),
                            border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FaIcon(FontAwesomeIcons.tag, size: 12, color: AppColors.brandLight),
                        ),
                      ),
                    ],
                  ),
                  if (_promoStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _promoStatus!,
                        style: TextStyle(fontSize: 10, color: _promoStatusColor),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Submit
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _completeOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.rocket, size: 14, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        appState.t('onboardCTA'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => appState.setOnboardingStep(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.arrowLeft, size: 12, color: AppColors.slate500),
              const SizedBox(width: 6),
              Text('Retour', style: TextStyle(fontSize: 14, color: AppColors.slate500)),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(fontSize: 12, color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String placeholder, {TextInputType? type, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.slate500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: AppColors.slate600),
            filled: true,
            fillColor: AppColors.slate800.withValues(alpha: 0.8),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
