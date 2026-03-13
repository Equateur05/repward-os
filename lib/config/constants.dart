class AppConstants {
  static const String supabaseUrl = 'https://cratowinhtgbcxxcqgfm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyYXRvd2luaHRnYmN4eGNxZ2ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3NDQ1NzIsImV4cCI6MjA4NzMyMDU3Mn0.hXnhe04i8U6TN2wWW6lSfnNasQt2CcIwpRP1bOHQBHQ';

  static const String accountKey = 'repward_account';

  // Promo codes
  static const Map<String, PromoCode> promoCodes = {
    'DEMO2026': PromoCode(type: PromoType.demo, duration: 60, label: 'Démo 1h — Accès complet'),
    'DEMO1H': PromoCode(type: PromoType.demo, duration: 60, label: 'Démo 1h — Accès complet'),
    'DEMO30': PromoCode(type: PromoType.demo, duration: 30, label: 'Démo 30min — Accès complet'),
    'REPWARD50': PromoCode(type: PromoType.discount, discount: 50, label: '-50% sur le 1er mois'),
    'REPWARD30': PromoCode(type: PromoType.discount, discount: 30, label: '-30% sur le 1er mois'),
    'LAUNCH': PromoCode(type: PromoType.discount, discount: 20, label: '-20% offre de lancement'),
    'VIP': PromoCode(type: PromoType.demo, duration: 120, label: 'Démo VIP 2h — Accès complet'),
  };

  // Subscription plans
  static const List<SubscriptionPlan> subscriptionPlans = [
    SubscriptionPlan(
      id: 'starter',
      name: 'Starter',
      price: '9,90',
      originalPrice: '29,90',
      priceNum: 9.90,
      limit: 10,
      label: '10 réponses IA/mois',
      features: ['10 réponses IA/mois', '1 plateforme', 'QR Code basique', 'Récompenses simples'],
      promo: 'Offre 1ère année',
    ),
    SubscriptionPlan(
      id: 'pro',
      name: 'Pro',
      price: '49,90',
      originalPrice: '89,90',
      priceNum: 49.90,
      limit: 100,
      label: '100 réponses IA/mois',
      features: [
        '100 réponses IA/mois', '10 plateformes', 'QR Code personnalisé',
        'Win-Back codes promos', 'Pilote automatique', 'Analytics complets', 'Support prioritaire',
      ],
      popular: true,
      promo: 'Offre 1ère année',
    ),
    SubscriptionPlan(
      id: 'unlimited',
      name: 'Illimité',
      price: '99,90',
      originalPrice: '149,90',
      priceNum: 99.90,
      limit: -1, // Infinity
      label: 'Réponses illimitées',
      features: [
        'Réponses IA illimitées', '18 plateformes', 'Pilote automatique',
        'Win-Back illimité', 'Radar IA opérationnel', 'Support dédié 24/7', 'API personnalisée',
      ],
      promo: 'Offre 1ère année',
    ),
  ];

  // Website URL for subscription management (Spotify model — subscriptions via website only)
  static const String subscriptionWebUrl = 'https://repward.vercel.app/pricing.html';

  // AI tone options
  static const List<String> aiTones = ['professional', 'casual', 'warm', 'humor'];

  // Supported languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'Français'},
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Español'},
    {'code': 'it', 'flag': '🇮🇹', 'name': 'Italiano'},
    {'code': 'de', 'flag': '🇩🇪', 'name': 'Deutsch'},
    {'code': 'pt', 'flag': '🇵🇹', 'name': 'Português'},
    {'code': 'nl', 'flag': '🇳🇱', 'name': 'Nederlands'},
    {'code': 'ar', 'flag': '🇸🇦', 'name': 'العربية'},
  ];
}

enum PromoType { demo, discount }

class PromoCode {
  final PromoType type;
  final int duration;
  final int discount;
  final String label;

  const PromoCode({
    required this.type,
    this.duration = 0,
    this.discount = 0,
    required this.label,
  });
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String originalPrice;
  final double priceNum;
  final int limit;
  final String label;
  final List<String> features;
  final bool popular;
  final String promo;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.priceNum,
    required this.limit,
    required this.label,
    required this.features,
    this.popular = false,
    required this.promo,
  });
}
