import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppColors {
  // Slate palette
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate750 = Color(0xFF293548);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate850 = Color(0xFF172033);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Brand (Indigo)
  static const Color brand50 = Color(0xFFEEF2FF);
  static const Color brand100 = Color(0xFFE0E7FF);
  static const Color brandLight = Color(0xFF818CF8);
  static const Color brand = Color(0xFF6366F1);
  static const Color brandDark = Color(0xFF4F46E5);
  static const Color brandDarker = Color(0xFF3730A3);

  // Success (Emerald)
  static const Color successLight = Color(0xFF34D399);
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);

  // Danger (Rose)
  static const Color dangerLight = Color(0xFFFB7185);
  static const Color danger = Color(0xFFF43F5E);
  static const Color dangerDark = Color(0xFFE11D48);

  // Warning (Amber)
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);

  // Platform colors
  static const Color google = Color(0xFF4285F4);
  static const Color airbnb = Color(0xFFFF5A5F);
  static const Color booking = Color(0xFF003580);
  static const Color tripadvisor = Color(0xFF34E0A1);
  static const Color yelp = Color(0xFFFF1A1A);
  static const Color thefork = Color(0xFF5C8A47);
  static const Color ubereats = Color(0xFF06C167);
  static const Color deliveroo = Color(0xFF00CCBC);
  static const Color trustpilot = Color(0xFF00B67A);
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE1306C);
  static const Color justeat = Color(0xFFFF8000);
  static const Color expedia = Color(0xFF00008C);

  // Background mesh gradient
  static const Color bgStart = Color(0xFF0F172A);
  static const Color bgMiddle = Color(0xFF172033);
  static const Color bgEnd = Color(0xFF1A1A2E);

  // Glass effect colors
  static const Color glassBackground = Color(0x801E293B); // rgba(30,41,59,0.5)
  static const Color glassBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassCardStart = Color(0x80293548); // rgba(41,53,72,0.5)
  static const Color glassCardEnd = Color(0xB30F172A); // rgba(15,23,42,0.7)

  static Color platformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'google': return google;
      case 'airbnb': return airbnb;
      case 'booking': return booking;
      case 'tripadvisor': return tripadvisor;
      case 'yelp': return yelp;
      case 'thefork': return thefork;
      case 'ubereats': return ubereats;
      case 'deliveroo': return deliveroo;
      case 'trustpilot': return trustpilot;
      case 'facebook': return facebook;
      case 'instagram': return instagram;
      case 'justeat': return justeat;
      case 'expedia': return expedia;
      default: return brand;
    }
  }
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.slate900,
      primaryColor: AppColors.brand,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand,
        secondary: AppColors.brandLight,
        surface: AppColors.slate800,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.slate50,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      fontFamily: GoogleFonts.outfit().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.slate800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.slate900,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slate800.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandLight, width: 2),
        ),
        hintStyle: GoogleFonts.outfit(color: AppColors.slate500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class GlassDecoration {
  static BoxDecoration card({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment(-0.5, -0.5),
        end: Alignment(0.5, 0.5),
        colors: [AppColors.glassCardStart, AppColors.glassCardEnd],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassBorder),
    );
  }

  static BoxDecoration glass({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppColors.glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: AppColors.glassBorder),
    );
  }

  static BoxDecoration mesh() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-0.5, -0.5),
        end: Alignment(0.5, 0.5),
        colors: [AppColors.bgStart, AppColors.bgMiddle, AppColors.bgEnd],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.blur = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: GlassDecoration.glass(borderRadius: borderRadius),
          child: child,
        ),
      ),
    );
  }
}
