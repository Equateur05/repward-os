import 'package:flutter/material.dart';

class IndustryInsight {
  final String emoji;
  final String label;
  final int count;
  final String severity; // high, medium, low

  const IndustryInsight({required this.emoji, required this.label, required this.count, required this.severity});

  Color get severityColor {
    switch (severity) {
      case 'high': return const Color(0xFFF43F5E);
      case 'medium': return const Color(0xFFF59E0B);
      case 'low': return const Color(0xFF10B981);
      default: return const Color(0xFF64748B);
    }
  }

  double get barWidth {
    if (count >= 15) return 1.0;
    if (count >= 10) return 0.75;
    if (count >= 5) return 0.5;
    return 0.3;
  }
}

class IndustryKPIs {
  final String reviews;
  final String timeSaved;
  final String roi;

  const IndustryKPIs({required this.reviews, required this.timeSaved, required this.roi});
}

class WinbackOption {
  final String val;
  final String label;

  const WinbackOption({required this.val, required this.label});
}

class IndustryTheme {
  final Color primary;
  final Color accent;

  const IndustryTheme({required this.primary, required this.accent});
}

class Industry {
  final String name;
  final String emoji;
  final String img;
  final List<String> rewards;
  final List<IndustryInsight> insights;
  final IndustryKPIs kpis;
  final List<WinbackOption> winbackOptions;
  final IndustryTheme theme;

  const Industry({
    required this.name,
    required this.emoji,
    required this.img,
    required this.rewards,
    required this.insights,
    required this.kpis,
    required this.winbackOptions,
    required this.theme,
  });
}

final Map<String, Industry> industries = {
  'restaurant': const Industry(
    name: 'Restaurant & Bar',
    emoji: '🍽️',
    img: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&q=80&auto=format',
    rewards: ['Dessert Offert', 'Café Gourmand Offert', 'Apéritif Maison', 'Digestif Offert', "-10% sur l'addition", 'Entrée Offerte'],
    insights: [
      IndustryInsight(emoji: '🍽️', label: 'Plat froid', count: 12, severity: 'high'),
      IndustryInsight(emoji: '⏳', label: 'Service lent', count: 8, severity: 'medium'),
      IndustryInsight(emoji: '🔊', label: 'Bruit ambiant', count: 4, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+112', timeSaved: '24h', roi: '1 850 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir (Excuses simples)'),
      WinbackOption(val: 'dessert', label: '🍰 Dessert offert'),
      WinbackOption(val: 'drink', label: '🍹 Boisson ou Apéritif offert'),
      WinbackOption(val: 'discount', label: "📉 -10% sur l'addition"),
      WinbackOption(val: 'entree', label: '🥗 Entrée offerte prochaine visite'),
    ],
    theme: IndustryTheme(primary: Color(0xFF6366F1), accent: Color(0xFF818CF8)),
  ),
  'coffee': const Industry(
    name: 'Coffee Shop & Salon de Thé',
    emoji: '☕',
    img: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=600&q=80&auto=format',
    rewards: ['Cookie Artisanal Offert', 'Shot de Vanille Gratuit', '2ème Café Offert', 'Lait Végétal Offert', 'Muffin du Jour', 'Smoothie Offert'],
    insights: [
      IndustryInsight(emoji: '🎵', label: 'Musique trop forte', count: 5, severity: 'medium'),
      IndustryInsight(emoji: '📶', label: 'WiFi capricieux', count: 4, severity: 'medium'),
      IndustryInsight(emoji: '🔌', label: 'Manque prises élec.', count: 2, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+84', timeSaved: '16h', roi: '1 240 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir (Excuses simples)'),
      WinbackOption(val: 'coffee', label: '☕ Café de spécialité offert'),
      WinbackOption(val: 'cookie', label: '🍪 Pâtisserie offerte'),
      WinbackOption(val: 'smoothie', label: '🥤 Smoothie offert'),
    ],
    theme: IndustryTheme(primary: Color(0xFF8B5CF6), accent: Color(0xFFA78BFA)),
  ),
  'streetfood': const Industry(
    name: 'Street Food & Fast Food',
    emoji: '🌮',
    img: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80&auto=format',
    rewards: ['Boisson Offerte', 'Frites Cheddar XL', 'Menu Upgrader Gratuit', 'Sauce Spéciale Maison', 'Dessert du Jour', 'Extra Garniture'],
    insights: [
      IndustryInsight(emoji: '🍟', label: 'Frites froides', count: 11, severity: 'high'),
      IndustryInsight(emoji: '📋', label: 'Commande incomplète', count: 6, severity: 'medium'),
      IndustryInsight(emoji: '⏰', label: "Temps d'attente", count: 3, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+156', timeSaved: '12h', roi: '890 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'drink', label: '🥤 Boisson offerte'),
      WinbackOption(val: 'fries', label: '🍟 Frites offertes'),
      WinbackOption(val: 'upgrade', label: '⬆️ Menu Upgrader gratuit'),
    ],
    theme: IndustryTheme(primary: Color(0xFFF97316), accent: Color(0xFFFB923C)),
  ),
  'hotel': const Industry(
    name: 'Hôtel & Spa',
    emoji: '🏨',
    img: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&q=80&auto=format',
    rewards: ['Late Check-out 14h', 'Accès Spa Gratuit', 'Surclassement Chambre', 'Petit-Déjeuner Offert', 'Bouteille de Vin en Chambre', 'Transfert Aéroport', 'Minibar Offert', 'Massage 30min'],
    insights: [
      IndustryInsight(emoji: '🔊', label: 'Bruit couloirs', count: 22, severity: 'high'),
      IndustryInsight(emoji: '🥐', label: 'Petit-déj incomplet', count: 15, severity: 'high'),
      IndustryInsight(emoji: '❄️', label: 'Climatisation bruyante', count: 6, severity: 'medium'),
    ],
    kpis: IndustryKPIs(reviews: '+45', timeSaved: '32h', roi: '4 500 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'upgrade', label: '🗝️ Surclassement prochaine visite'),
      WinbackOption(val: 'breakfast', label: '🥐 Petit-déjeuner offert'),
      WinbackOption(val: 'wine', label: '🍷 Bouteille de vin en chambre'),
      WinbackOption(val: 'spa', label: '🧖 Accès Spa 1h offert'),
    ],
    theme: IndustryTheme(primary: Color(0xFF8B5CF6), accent: Color(0xFFA78BFA)),
  ),
  'airbnb': const Industry(
    name: 'Airbnb & Conciergerie',
    emoji: '🔑',
    img: 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=600&q=80&auto=format',
    rewards: ['Late Check-out 13h', '-15% Prochain Séjour', 'Panier de Bienvenue Local', 'Bouteille de Vin Régional', 'Guide Touristique Perso', 'Ménage Offert', 'Early Check-in'],
    insights: [
      IndustryInsight(emoji: '🧹', label: 'Poussière SdB', count: 10, severity: 'high'),
      IndustryInsight(emoji: '🔊', label: 'Bruit rue', count: 3, severity: 'low'),
      IndustryInsight(emoji: '📶', label: 'WiFi lent', count: 2, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+28', timeSaved: '18h', roi: '2 100 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'discount', label: '📉 -15% Prochain Séjour'),
      WinbackOption(val: 'latecheckout', label: '⏰ Late Check-out offert'),
      WinbackOption(val: 'wine', label: '🍷 Bouteille de vin régional'),
      WinbackOption(val: 'basket', label: '🧺 Panier local de bienvenue'),
    ],
    theme: IndustryTheme(primary: Color(0xFFEC4899), accent: Color(0xFFF472B6)),
  ),
  'beauty': const Industry(
    name: 'Coiffure & Beauté',
    emoji: '✂️',
    img: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600&q=80&auto=format',
    rewards: ['Soin Profond Offert', 'Massage Crânien 15min', '-15% Produits Boutique', 'Échantillons Premium', 'Brushing Express Offert', 'Masque Capillaire'],
    insights: [
      IndustryInsight(emoji: '⏰', label: 'Retard sur rdv', count: 8, severity: 'high'),
      IndustryInsight(emoji: '✂️', label: 'Coupe trop courte', count: 3, severity: 'medium'),
      IndustryInsight(emoji: '🧴', label: 'Produits manquants', count: 2, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+62', timeSaved: '8h', roi: '950 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'care', label: '💆‍♀️ Soin profond offert'),
      WinbackOption(val: 'discount', label: '🛍️ -15% sur boutique'),
      WinbackOption(val: 'brushing', label: '💇‍♀️ Brushing offert'),
    ],
    theme: IndustryTheme(primary: Color(0xFF10B981), accent: Color(0xFF34D399)),
  ),
  'retail': const Industry(
    name: 'Boutique & Retail',
    emoji: '🛍️',
    img: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&q=80&auto=format',
    rewards: ['-10% Immédiat', 'Tote Bag Exclusif', 'Statut VIP Fidélité', 'Cadeau Surprise', 'Livraison Offerte', 'Emballage Cadeau Premium'],
    insights: [
      IndustryInsight(emoji: '👕', label: 'Manque de tailles', count: 14, severity: 'high'),
      IndustryInsight(emoji: '🏪', label: 'Attente en caisse', count: 9, severity: 'medium'),
      IndustryInsight(emoji: '💡', label: 'Éclairage cabines', count: 3, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+95', timeSaved: '10h', roi: '1 600 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'discount', label: '📉 -10% prochaine visite'),
      WinbackOption(val: 'gift', label: '🎁 Cadeau surprise offert'),
      WinbackOption(val: 'shipping', label: '📦 Livraison offerte'),
    ],
    theme: IndustryTheme(primary: Color(0xFF3B82F6), accent: Color(0xFF60A5FA)),
  ),
  'bakery': const Industry(
    name: 'Boulangerie & Pâtisserie',
    emoji: '🥐',
    img: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80&auto=format',
    rewards: ['Viennoiserie Offerte', 'Café Offert', 'Pain Spécial du Jour', 'Pâtisserie au Choix', 'Macaron Offert', 'Carte Fidélité x2'],
    insights: [
      IndustryInsight(emoji: '🧑‍🤝‍🧑', label: "File d'attente", count: 9, severity: 'high'),
      IndustryInsight(emoji: '🚫', label: 'Rupture produits', count: 5, severity: 'medium'),
      IndustryInsight(emoji: '💰', label: 'Prix élevés', count: 3, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+130', timeSaved: '10h', roi: '980 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'pastry', label: '🥐 Viennoiserie offerte'),
      WinbackOption(val: 'coffee', label: '☕ Café offert'),
    ],
    theme: IndustryTheme(primary: Color(0xFFD97706), accent: Color(0xFFFBBF24)),
  ),
  'gym': const Industry(
    name: 'Salle de Sport & Fitness',
    emoji: '💪',
    img: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&q=80&auto=format',
    rewards: ['Séance Coaching Offerte', '1 Semaine Offerte', 'Boisson Protéinée', 'Serviette Branded', 'Cours Collectif VIP', 'Assessment Gratuit'],
    insights: [
      IndustryInsight(emoji: '🏋️', label: 'Machines occupées', count: 15, severity: 'high'),
      IndustryInsight(emoji: '🧹', label: 'Propreté vestiaires', count: 7, severity: 'medium'),
      IndustryInsight(emoji: '🎵', label: 'Musique trop forte', count: 3, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+72', timeSaved: '14h', roi: '1 100 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'session', label: '🏋️ Séance coaching offerte'),
      WinbackOption(val: 'week', label: '📅 1 semaine offerte'),
    ],
    theme: IndustryTheme(primary: Color(0xFFEF4444), accent: Color(0xFFF87171)),
  ),
  'garage': const Industry(
    name: 'Garage & Auto',
    emoji: '🔧',
    img: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80&auto=format',
    rewards: ['Diagnostic Gratuit', 'Lavage Intérieur Offert', '-10% Prochaine Révision', 'Contrôle Pression Pneus', 'Liquide Lave-Glace Offert', 'Désodorisant Offert'],
    insights: [
      IndustryInsight(emoji: '⏳', label: 'Délais trop longs', count: 18, severity: 'high'),
      IndustryInsight(emoji: '📋', label: 'Devis imprécis', count: 8, severity: 'medium'),
      IndustryInsight(emoji: '📱', label: 'Communication', count: 4, severity: 'low'),
    ],
    kpis: IndustryKPIs(reviews: '+38', timeSaved: '20h', roi: '2 200 €'),
    winbackOptions: [
      WinbackOption(val: 'none', label: 'Ne rien offrir'),
      WinbackOption(val: 'diag', label: '🔍 Diagnostic gratuit'),
      WinbackOption(val: 'wash', label: '🧽 Lavage intérieur offert'),
      WinbackOption(val: 'discount', label: '📉 -10% prochaine révision'),
    ],
    theme: IndustryTheme(primary: Color(0xFF64748B), accent: Color(0xFF94A3B8)),
  ),
};

List<String> getRewardsByStars(String industry, int stars) {
  final Map<String, Map<int, List<String>>> rewardMap = {
    'restaurant': {
      5: ['Dessert Offert', 'Café Gourmand Offert', 'Apéritif Maison', 'Digestif Offert', "-10% sur l'addition", 'Entrée Offerte'],
      4: ['Un Café Offert', 'Amuse-bouche Offert'],
      3: ['Un Sourire et Merci'], 2: [], 1: [],
    },
    'coffee': {
      5: ['Cookie Artisanal Offert', 'Shot de Vanille Gratuit', '2ème Café Offert', 'Lait Végétal Offert', 'Muffin du Jour', 'Smoothie Offert'],
      4: ['Shot de Sirop Offert', 'Cookie Offert'],
      3: ['Un Merci Chaleureux'], 2: [], 1: [],
    },
    'streetfood': {
      5: ['Boisson Offerte', 'Frites Cheddar XL', 'Menu Upgrader Gratuit', 'Sauce Spéciale Maison', 'Dessert du Jour', 'Extra Garniture'],
      4: ['Boisson Small Offerte', 'Sauce Premium'],
      3: ['Merci pour votre visite'], 2: [], 1: [],
    },
    'hotel': {
      5: ['Late Check-out 14h', 'Accès Spa Gratuit', 'Surclassement Chambre', 'Petit-Déjeuner Offert', 'Bouteille de Vin en Chambre', 'Transfert Aéroport', 'Minibar Offert', 'Massage 30min'],
      4: ['Late Check-out 12h', 'Café de Bienvenue'],
      3: ['Remerciement personnalisé'], 2: [], 1: [],
    },
    'airbnb': {
      5: ['Late Check-out 13h', '-15% Prochain Séjour', 'Panier de Bienvenue Local', 'Bouteille de Vin Régional', 'Guide Touristique Perso', 'Ménage Offert', 'Early Check-in'],
      4: ['Café & Croissants', '-5% Prochain Séjour'],
      3: ['Guide local offert'], 2: [], 1: [],
    },
    'beauty': {
      5: ['Soin Profond Offert', 'Massage Crânien 15min', '-15% Produits Boutique', 'Échantillons Premium', 'Brushing Express Offert', 'Masque Capillaire'],
      4: ['Échantillon Soin', '-5% Boutique'],
      3: ['Conseil personnalisé'], 2: [], 1: [],
    },
    'retail': {
      5: ['-10% Immédiat', 'Tote Bag Exclusif', 'Statut VIP Fidélité', 'Cadeau Surprise', 'Livraison Offerte', 'Emballage Cadeau Premium'],
      4: ['-5% Prochain Achat', 'Petit Cadeau'],
      3: ['Merci de votre fidélité'], 2: [], 1: [],
    },
    'bakery': {
      5: ['Viennoiserie Offerte', 'Café Offert', 'Pain Spécial du Jour', 'Pâtisserie au Choix', 'Macaron Offert', 'Carte Fidélité x2'],
      4: ['Mini Viennoiserie', 'Café Offert'],
      3: ['Sourire du boulanger'], 2: [], 1: [],
    },
    'gym': {
      5: ['Séance Coaching Offerte', '1 Semaine Offerte', 'Boisson Protéinée', 'Serviette Branded', 'Cours Collectif VIP', 'Assessment Gratuit'],
      4: ['Boisson Offerte', '1 Jour Invité'],
      3: ['Merci sportif'], 2: [], 1: [],
    },
    'garage': {
      5: ['Diagnostic Gratuit', 'Lavage Intérieur Offert', '-10% Prochaine Révision', 'Contrôle Pression Pneus', 'Liquide Lave-Glace Offert', 'Désodorisant Offert'],
      4: ['Contrôle Niveaux Gratuit', 'Café Offert'],
      3: ['Remerciement'], 2: [], 1: [],
    },
  };

  final map = rewardMap[industry] ?? rewardMap['restaurant']!;
  return map[stars] ?? [];
}
