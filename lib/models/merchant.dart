class Merchant {
  String name;
  String email;
  String businessName;
  String industry;
  String phone;
  String plan;
  String? promoCode;
  String? googleMapsUrl;
  bool autoPilot;
  bool fortuneEnabled;
  bool fomoEnabled;
  String aiTone;
  String? voiceInstruction;
  String? selectedReward;
  DateTime? createdAt;

  Merchant({
    this.name = '',
    this.email = '',
    this.businessName = '',
    this.industry = 'restaurant',
    this.phone = '',
    this.plan = 'starter',
    this.promoCode,
    this.googleMapsUrl,
    this.autoPilot = false,
    this.fortuneEnabled = false,
    this.fomoEnabled = true,
    this.aiTone = 'professional',
    this.voiceInstruction,
    this.selectedReward,
    this.createdAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      name: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      businessName: json['businessName'] ?? json['business_name'] ?? '',
      industry: json['industry'] ?? 'restaurant',
      phone: json['phone'] ?? '',
      plan: json['plan'] ?? 'starter',
      promoCode: json['promoCode'] ?? json['promo_code'],
      googleMapsUrl: json['googleMapsUrl'] ?? json['google_maps_url'],
      autoPilot: json['autoPilot'] ?? json['auto_pilot'] ?? false,
      fortuneEnabled: json['fortuneEnabled'] ?? json['fortune_enabled'] ?? false,
      fomoEnabled: json['fomoEnabled'] ?? json['fomo_enabled'] ?? true,
      aiTone: json['aiTone'] ?? json['ai_tone'] ?? 'professional',
      voiceInstruction: json['voiceInstruction'] ?? json['voice_instruction'],
      selectedReward: json['selectedReward'] ?? json['selected_reward'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'businessName': businessName,
        'industry': industry,
        'phone': phone,
        'plan': plan,
        'promoCode': promoCode,
        'googleMapsUrl': googleMapsUrl,
        'autoPilot': autoPilot,
        'fortuneEnabled': fortuneEnabled,
        'fomoEnabled': fomoEnabled,
        'aiTone': aiTone,
        'voiceInstruction': voiceInstruction,
        'selectedReward': selectedReward,
      };

  Map<String, dynamic> toSupabaseJson() => {
        'full_name': name,
        'email': email,
        'business_name': businessName,
        'industry': industry,
        'phone': phone,
        'plan': plan,
        'promo_code': promoCode,
        'google_maps_url': googleMapsUrl,
        'auto_pilot': autoPilot,
        'fortune_enabled': fortuneEnabled,
        'fomo_enabled': fomoEnabled,
        'ai_tone': aiTone,
        'voice_instruction': voiceInstruction,
        'selected_reward': selectedReward,
      };
}
