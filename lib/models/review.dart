import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class Review {
  final dynamic id;
  final String platform;
  final String author;
  final int rating;
  final String text;
  final DateTime date;
  final String lang;
  final bool responded;
  final String? responseText;
  final String? supabaseReviewId;

  Review({
    this.id,
    required this.platform,
    required this.author,
    required this.rating,
    required this.text,
    DateTime? date,
    this.lang = 'fr',
    this.responded = false,
    this.responseText,
    this.supabaseReviewId,
  }) : date = date ?? DateTime.now();

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      platform: json['platform'] ?? 'google',
      author: json['author_name'] ?? json['author'] ?? 'Anonyme',
      rating: json['rating'] ?? 5,
      text: json['text'] ?? '',
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      lang: json['lang'] ?? 'fr',
      responded: json['responded'] ?? false,
      responseText: json['response_text'],
      supabaseReviewId: json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'author_name': author,
        'rating': rating,
        'text': text,
        'lang': lang,
        'responded': responded,
        'response_text': responseText,
      };

  IconData get platformIcon {
    switch (platform.toLowerCase()) {
      case 'google': return FontAwesomeIcons.google;
      case 'airbnb': return FontAwesomeIcons.airbnb;
      case 'facebook': return FontAwesomeIcons.facebook;
      case 'instagram': return FontAwesomeIcons.instagram;
      case 'tripadvisor': return FontAwesomeIcons.mapLocationDot;
      case 'trustpilot': return FontAwesomeIcons.star;
      case 'thefork': return FontAwesomeIcons.utensils;
      case 'booking': return FontAwesomeIcons.hotel;
      case 'expedia': return FontAwesomeIcons.plane;
      default: return FontAwesomeIcons.comment;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${(diff.inDays / 7).floor()}sem';
  }
}
