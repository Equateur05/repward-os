import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import '../models/merchant.dart';
import '../models/review.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static User? _user;
  static Merchant? _merchant;

  static bool get isInitialized => _client != null;
  static SupabaseClient? get client => _client;
  static User? get user => _user;
  static Merchant? get merchant => _merchant;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _user = _client?.auth.currentUser;
  }

  // Auth
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client!.auth.signUp(
      email: email,
      password: password,
    );
    _user = response.user;
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
    _user = response.user;
    return response;
  }

  static Future<void> signOut() async {
    await _client?.auth.signOut();
    _user = null;
    _merchant = null;
  }

  // Merchant CRUD
  static Future<void> saveMerchant(Merchant merchant) async {
    if (_client == null || _user == null) return;
    try {
      final data = merchant.toSupabaseJson();
      data['id'] = _user!.id;
      await _client!.from('merchants').upsert(data, onConflict: 'id');
      _merchant = merchant;
    } catch (e) {
      // Silently fail, localStorage fallback in app state
    }
  }

  static Future<Merchant?> loadMerchant() async {
    if (_client == null || _user == null) return null;
    try {
      final data = await _client!
          .from('merchants')
          .select()
          .eq('id', _user!.id)
          .single();
      _merchant = Merchant.fromJson(data);
      return _merchant;
    } catch (e) {
      return null;
    }
  }

  // Reviews
  static Future<List<Review>> loadReviews({int limit = 50}) async {
    if (_client == null || _user == null) return [];
    try {
      final data = await _client!
          .from('reviews')
          .select()
          .eq('merchant_id', _user!.id)
          .order('created_at', ascending: false)
          .limit(limit);
      return (data as List).map((r) => Review.fromJson(r)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveReview(Review review) async {
    if (_client == null || _user == null) return;
    try {
      final data = review.toJson();
      data['merchant_id'] = _user!.id;
      await _client!.from('reviews').insert(data);
    } catch (e) {
      // Silently fail
    }
  }

  // Response History
  static Future<void> saveResponseHistory(Map<String, dynamic> entry) async {
    if (_client == null || _user == null) return;
    try {
      await _client!.from('response_history').insert({
        'merchant_id': _user!.id,
        'review_id': entry['supabase_review_id'],
        'author_name': entry['author'],
        'rating': entry['rating'],
        'platform': entry['platform'],
        'response_text': entry['response'],
        'published': entry['published'] ?? false,
      });
    } catch (e) {
      // Silently fail
    }
  }

  static Future<List<Map<String, dynamic>>> loadResponseHistory() async {
    if (_client == null || _user == null) return [];
    try {
      final data = await _client!
          .from('response_history')
          .select()
          .eq('merchant_id', _user!.id)
          .order('created_at', ascending: false)
          .limit(200);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  // Alerts
  static Future<void> saveAlerts(bool emailOn, bool smsOn) async {
    if (_client == null || _user == null) return;
    try {
      await _client!.from('alerts').upsert({
        'merchant_id': _user!.id,
        'email_alerts': emailOn,
        'sms_alerts': smsOn,
      }, onConflict: 'merchant_id');
    } catch (e) {
      // Silently fail
    }
  }

  // Contacts
  static Future<void> saveContact(String? phone, String? email, String source) async {
    if (_client == null || _user == null) return;
    try {
      await _client!.from('collected_contacts').insert({
        'merchant_id': _user!.id,
        'phone': phone,
        'email': email,
        'source': source,
      });
    } catch (e) {
      // Silently fail
    }
  }

  // Platforms
  static Future<void> savePlatform(String platformName, Map<String, dynamic> connectionData) async {
    if (_client == null || _user == null) return;
    try {
      await _client!.from('platforms').upsert({
        'merchant_id': _user!.id,
        'platform': platformName,
        'connected': connectionData['is_active'] ?? false,
        'account_name': connectionData['accountName'],
        'account_id': connectionData['accountId'],
        'location_id': connectionData['locationId'],
        'connected_at': connectionData['is_active'] == true ? DateTime.now().toIso8601String() : null,
      }, onConflict: 'merchant_id,platform');
    } catch (e) {
      // Silently fail
    }
  }
}
