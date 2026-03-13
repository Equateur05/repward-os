import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/merchant.dart';
import '../models/review.dart';
import '../models/industry.dart';
import '../config/constants.dart';
import '../l10n/translations.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  // Language
  String _currentLang = 'fr';
  String get currentLang => _currentLang;

  // Merchant
  Merchant _merchant = Merchant();
  Merchant get merchant => _merchant;

  // Industry
  String _currentIndustry = 'restaurant';
  String get currentIndustry => _currentIndustry;
  Industry get industry => industries[_currentIndustry] ?? industries['restaurant']!;

  // Selected reward
  String _selectedReward = 'Dessert Offert';
  String get selectedReward => _selectedReward;

  // Reviews
  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  // Response history (from Supabase)
  List<Map<String, dynamic>> _responseHistory = [];
  List<Map<String, dynamic>> get responseHistory => _responseHistory;

  // Stats loading state
  bool _statsLoaded = false;
  bool get statsLoaded => _statsLoaded;

  // ============ COMPUTED STATS (real data) ============

  /// Total reviews count
  int get totalReviews => _reviews.length;

  /// Reviews this month
  int get reviewsThisMonth {
    final now = DateTime.now();
    return _reviews.where((r) =>
        r.date.year == now.year && r.date.month == now.month).length;
  }

  /// 5-star reviews this month
  int get fiveStarThisMonth {
    final now = DateTime.now();
    return _reviews.where((r) =>
        r.rating == 5 && r.date.year == now.year && r.date.month == now.month).length;
  }

  /// Average rating (0.0 if no reviews)
  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final sum = _reviews.fold<int>(0, (s, r) => s + r.rating);
    return sum / _reviews.length;
  }

  /// Reputation score (0-100 scale based on avg rating)
  int get reputationScore {
    if (_reviews.isEmpty) return 0;
    return (averageRating * 20).round().clamp(0, 100);
  }

  /// Reputation score as 0.0-1.0
  double get reputationScoreNormalized => reputationScore / 100.0;

  /// Reputation label
  String get reputationLabel {
    if (reputationScore >= 90) return 'Excellente réputation';
    if (reputationScore >= 75) return 'Très bonne réputation';
    if (reputationScore >= 60) return 'Bonne réputation';
    if (reputationScore >= 40) return 'Réputation moyenne';
    if (reputationScore > 0) return 'Réputation à améliorer';
    return 'Aucune donnée';
  }

  /// Reputation badge
  String get reputationBadge {
    if (reputationScore >= 90) return 'Expert';
    if (reputationScore >= 75) return 'Confirmé';
    if (reputationScore >= 60) return 'Intermédiaire';
    if (reputationScore >= 40) return 'Débutant';
    return 'Nouveau';
  }

  /// Total AI responses published
  int get totalResponses => _responseHistory.length;

  /// AI responses this month
  int get responsesThisMonth {
    final now = DateTime.now();
    return _responseHistory.where((r) {
      final date = DateTime.tryParse(r['created_at']?.toString() ?? '');
      return date != null && date.year == now.year && date.month == now.month;
    }).length;
  }

  /// Response limit based on plan
  int get responseLimit {
    final plan = AppConstants.subscriptionPlans.where((p) => p.id == _merchant.plan);
    if (plan.isNotEmpty) return plan.first.limit;
    return 10; // default starter
  }

  /// Usage ratio for progress bar
  double get usageRatio {
    if (responseLimit <= 0) return 0.0; // unlimited or error
    return (responsesThisMonth / responseLimit).clamp(0.0, 1.0);
  }

  /// Time saved (estimate: 12min per AI response)
  String get timeSaved {
    final minutes = totalResponses * 12;
    if (minutes >= 60) return '${(minutes / 60).round()}h';
    return '${minutes}min';
  }

  /// Unresponded reviews count (for triage badge)
  int get unrespondedCount {
    final respondedIds = _responseHistory
        .map((r) => r['review_id']?.toString())
        .where((id) => id != null)
        .toSet();
    return _reviews.where((r) => !respondedIds.contains(r.supabaseReviewId)).length;
  }

  /// Heatmap data — review counts per day for last 30 days
  List<double> get heatmapData {
    final now = DateTime.now();
    final counts = List<int>.filled(30, 0);
    for (final r in _reviews) {
      final daysAgo = now.difference(r.date).inDays;
      if (daysAgo >= 0 && daysAgo < 30) {
        counts[daysAgo]++;
      }
    }
    final maxCount = counts.fold<int>(0, (m, c) => c > m ? c : m);
    if (maxCount == 0) return List<double>.filled(30, 0.0);
    return counts.map((c) => c / maxCount).toList().reversed.toList();
  }

  // Current view
  String _currentView = 'onboarding'; // onboarding, merchant, customer
  String get currentView => _currentView;

  // Current tab
  String _currentTab = 'analytics';
  String get currentTab => _currentTab;

  // Filter
  String _currentFilter = 'all';
  String get currentFilter => _currentFilter;

  // AI Tone
  String _aiTone = 'professional';
  String get aiTone => _aiTone;

  // Auto-Pilot
  bool _autoPilot = false;
  bool get autoPilot => _autoPilot;

  // Fortune Wheel
  bool _fortuneEnabled = false;
  bool get fortuneEnabled => _fortuneEnabled;

  // FOMO
  bool _fomoEnabled = true;
  bool get fomoEnabled => _fomoEnabled;

  // Google Maps URL
  String _googleMapsUrl = '';
  String get googleMapsUrl => _googleMapsUrl;

  // Demo
  bool _isDemoActive = false;
  bool get isDemoActive => _isDemoActive;
  int _demoRemaining = 0;
  int get demoRemaining => _demoRemaining;

  // Promo
  PromoCode? _activePromo;
  PromoCode? get activePromo => _activePromo;

  // Onboarding step
  int _onboardingStep = 1;
  int get onboardingStep => _onboardingStep;

  // Translation helper
  String t(String key) => AppTranslations.t(key, _currentLang);

  // Is RTL
  bool get isRTL => _currentLang == 'ar';

  // Initialize
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('repward_lang') ?? 'fr';

    // Check if onboarding completed
    final accountJson = prefs.getString(AppConstants.accountKey);
    if (accountJson != null) {
      try {
        final account = json.decode(accountJson);
        if (account['email'] != null && account['businessName'] != null) {
          _merchant = Merchant.fromJson(account);
          _currentIndustry = _merchant.industry;
          _selectedReward = _merchant.selectedReward ?? industries[_currentIndustry]!.rewards.first;
          _aiTone = _merchant.aiTone;
          _autoPilot = _merchant.autoPilot;
          _fortuneEnabled = _merchant.fortuneEnabled;
          _fomoEnabled = _merchant.fomoEnabled;
          _googleMapsUrl = _merchant.googleMapsUrl ?? '';
          _currentView = 'merchant';
        }
      } catch (e) {
        // Invalid data, show onboarding
      }
    }

    // Check demo
    final demoJson = prefs.getString('repward_demo');
    if (demoJson != null) {
      try {
        final demo = json.decode(demoJson);
        final expiresAt = DateTime.parse(demo['expiresAt']);
        if (expiresAt.isAfter(DateTime.now())) {
          _isDemoActive = true;
          _demoRemaining = expiresAt.difference(DateTime.now()).inMinutes;
        }
      } catch (e) {
        // Invalid demo data
      }
    }

    notifyListeners();

    // Load real data from Supabase in background
    await loadFromSupabase();
  }

  /// Load reviews + response history from Supabase
  Future<void> loadFromSupabase() async {
    if (!SupabaseService.isInitialized || SupabaseService.user == null) {
      _statsLoaded = true;
      notifyListeners();
      return;
    }

    try {
      // If we have a Supabase user but no local merchant, try loading from Supabase
      if (_currentView == 'onboarding') {
        final remoteMerchant = await SupabaseService.loadMerchant();
        if (remoteMerchant != null) {
          _merchant = remoteMerchant;
          _currentIndustry = remoteMerchant.industry;
          _selectedReward = remoteMerchant.selectedReward ?? industries[_currentIndustry]!.rewards.first;
          _aiTone = remoteMerchant.aiTone;
          _autoPilot = remoteMerchant.autoPilot;
          _fortuneEnabled = remoteMerchant.fortuneEnabled;
          _fomoEnabled = remoteMerchant.fomoEnabled;
          _googleMapsUrl = remoteMerchant.googleMapsUrl ?? '';
          _currentView = 'merchant';
          await _saveMerchant();
        }
      }

      final results = await Future.wait([
        SupabaseService.loadReviews(limit: 500),
        SupabaseService.loadResponseHistory(),
      ]);

      _reviews = results[0] as List<Review>;
      _responseHistory = results[1] as List<Map<String, dynamic>>;
      _statsLoaded = true;
      notifyListeners();
    } catch (e) {
      _statsLoaded = true;
      notifyListeners();
    }
  }

  /// Refresh stats (call after publishing a response, etc.)
  Future<void> refreshStats() async {
    await loadFromSupabase();
  }

  // Language
  void setLanguage(String lang) {
    _currentLang = lang;
    _savePreference('repward_lang', lang);
    notifyListeners();
  }

  // Onboarding
  void setOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

  // Industry
  void setIndustry(String ind) {
    _currentIndustry = ind;
    _merchant.industry = ind;
    _selectedReward = industries[ind]!.rewards.first;
    notifyListeners();
  }

  // Reward
  void setReward(String reward) {
    _selectedReward = reward;
    _merchant.selectedReward = reward;
    notifyListeners();
  }

  // View
  void setView(String view) {
    _currentView = view;
    notifyListeners();
  }

  // Tab
  void setTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  // Filter
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // AI Tone
  void setAiTone(String tone) {
    _aiTone = tone;
    _merchant.aiTone = tone;
    _saveMerchant();
    notifyListeners();
  }

  // Auto-Pilot
  void setAutoPilot(bool value) {
    _autoPilot = value;
    _merchant.autoPilot = value;
    _saveMerchant();
    notifyListeners();
  }

  // Fortune
  void setFortuneEnabled(bool value) {
    _fortuneEnabled = value;
    _merchant.fortuneEnabled = value;
    _saveMerchant();
    notifyListeners();
  }

  // FOMO
  void setFomoEnabled(bool value) {
    _fomoEnabled = value;
    _merchant.fomoEnabled = value;
    _saveMerchant();
    notifyListeners();
  }

  // Google Maps URL
  void setGoogleMapsUrl(String url) {
    _googleMapsUrl = url;
    _merchant.googleMapsUrl = url;
    _saveMerchant();
    notifyListeners();
  }

  // Complete onboarding
  Future<void> completeOnboarding(Merchant m) async {
    _merchant = m;
    _currentIndustry = m.industry;
    _selectedReward = industries[m.industry]!.rewards.first;
    _currentView = 'merchant';
    await _saveMerchant();
    notifyListeners();
  }

  // Activate demo
  Future<void> activateDemo(int durationMinutes) async {
    final expiresAt = DateTime.now().add(Duration(minutes: durationMinutes));
    _isDemoActive = true;
    _demoRemaining = durationMinutes;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('repward_demo', json.encode({
      'expiresAt': expiresAt.toIso8601String(),
      'duration': durationMinutes,
    }));
    notifyListeners();
  }

  // Validate promo code
  PromoCode? validatePromoCode(String code) {
    final upper = code.trim().toUpperCase();
    final promo = AppConstants.promoCodes[upper];
    _activePromo = promo;
    notifyListeners();
    return promo;
  }

  // Add review
  void addReview(Review review) {
    _reviews.insert(0, review);
    notifyListeners();
  }

  // Set reviews list
  void setReviews(List<Review> reviews) {
    _reviews = reviews;
    notifyListeners();
  }

  // Save merchant to SharedPreferences
  Future<void> _saveMerchant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accountKey, json.encode(_merchant.toJson()));
  }

  // Save preference
  Future<void> _savePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
