import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/theme.dart';
import '../../services/app_state.dart';
import '../../models/industry.dart';
import '../../widgets/master_nav.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  int _currentStep = 0; // 0: welcome, 1: rate, 2: reward, 3: thanks
  int _selectedRating = 0;

  void _selectRating(int rating) {
    setState(() {
      _selectedRating = rating;
      _currentStep = 2;
    });
  }

  void _claimReward() {
    setState(() => _currentStep = 3);
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      _selectedRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final ind = appState.industry;
    final theme = ind.theme;

    return Scaffold(
      backgroundColor: AppColors.slate950,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primary.withValues(alpha: 0.15),
                  AppColors.slate950,
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Master nav
                const SizedBox(height: 16),
                const MasterNav(),
                const SizedBox(height: 32),
                // Phone frame
                Expanded(
                  child: Center(
                    child: _buildIPhoneFrame(appState, ind, theme),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIPhoneFrame(AppState appState, Industry ind, IndustryTheme theme) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 650),
      decoration: BoxDecoration(
        // Gradient background simulating the CSS:
        // background: linear-gradient(145deg, #1e293b, #0f172a)
        borderRadius: BorderRadius.circular(44),
        gradient: const LinearGradient(
          begin: Alignment(-0.6, -0.8), // ~145deg
          end: Alignment(0.6, 0.8),
          colors: [
            AppColors.slate800, // #1e293b
            AppColors.slate900, // #0f172a
          ],
        ),
        boxShadow: [
          // 0 0 0 2px #334155 (outline ring)
          BoxShadow(
            color: AppColors.slate700,
            spreadRadius: 2,
            blurRadius: 0,
          ),
          // 0 25px 60px rgba(0,0,0,0.6) (drop shadow)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 60,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      // padding: 10px matching CSS
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          // Inner screen: borderRadius 34, background #f8fafc
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.slate50, // #f8fafc
              child: SingleChildScrollView(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStep(appState, ind, theme),
                ),
              ),
            ),
          ),
          // Inset glow: inset 0 0 0 1px rgba(255,255,255,0.05)
          // Simulated with a ring overlay on the screen
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // Notch: position absolute top 14px, centered, 120px wide, 28px tall
          Positioned(
            top: 4, // 14px from outer frame top - 10px padding = 4px inside screen
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.slate900, // #0f172a
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(AppState appState, Industry ind, IndustryTheme theme) {
    final primaryColor = theme.primary;
    final accentColor = theme.accent;
    final bizName = appState.merchant.businessName.isNotEmpty ? appState.merchant.businessName : 'Mon Commerce';

    switch (_currentStep) {
      case 0:
        return _WelcomeStep(
          key: const ValueKey('welcome'),
          emoji: ind.emoji,
          bizName: bizName,
          primaryColor: primaryColor,
          accentColor: accentColor,
          reward: appState.selectedReward,
          onStart: () => setState(() => _currentStep = 1),
          lang: appState.currentLang,
          appState: appState,
        );
      case 1:
        return _RatingStep(
          key: const ValueKey('rating'),
          primaryColor: primaryColor,
          onRate: _selectRating,
          appState: appState,
        );
      case 2:
        return _RewardStep(
          key: const ValueKey('reward'),
          rating: _selectedRating,
          industry: appState.currentIndustry,
          primaryColor: primaryColor,
          accentColor: accentColor,
          appState: appState,
          onClaim: _claimReward,
        );
      case 3:
        return _ThanksStep(
          key: const ValueKey('thanks'),
          primaryColor: primaryColor,
          appState: appState,
          onReset: _reset,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WelcomeStep extends StatelessWidget {
  final String emoji;
  final String bizName;
  final Color primaryColor;
  final Color accentColor;
  final String reward;
  final VoidCallback onStart;
  final String lang;
  final AppState appState;

  const _WelcomeStep({
    super.key,
    required this.emoji,
    required this.bizName,
    required this.primaryColor,
    required this.accentColor,
    required this.reward,
    required this.onStart,
    required this.lang,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final ind = appState.industry;
    return Column(
      children: [
        // Hero image from Unsplash (matches HTML version)
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                ind.img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: primaryColor.withValues(alpha: 0.2),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 48))),
                ),
              ),
              // Gradient overlay from bottom
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFFF8FAFC),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content overlapping the image
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Transform.translate(
            offset: const Offset(0, -32),
            child: Column(
              children: [
                // Business card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      // Emoji icon with gradient bg
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [primaryColor, accentColor]),
                          boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 25, offset: const Offset(0, 10))],
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bizName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appState.t('customerWelcome'),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A).withValues(alpha: 0.5)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Reward card with gradient background (matches HTML)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, accentColor],
                    ),
                    boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 20))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'CADEAU IMMÉDIAT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        reward,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Laissez-nous 5 étoiles pour\ndébloquer votre cadeau',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Rating section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    children: [
                      const Text('Votre avis nous aide !', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text('Touchez les étoiles pour nous noter', style: TextStyle(fontSize: 11, color: const Color(0xFF0F172A).withValues(alpha: 0.4))),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: onStart,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FaIcon(FontAwesomeIcons.solidStar, size: 32, color: const Color(0xFFE2E8F0)),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E8F0),
                            foregroundColor: const Color(0xFF94A3B8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: const Color(0xFFE2E8F0),
                            disabledForegroundColor: const Color(0xFF94A3B8),
                          ),
                          child: const Text('Sélectionnez vos étoiles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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

class _RatingStep extends StatelessWidget {
  final Color primaryColor;
  final Function(int) onRate;
  final AppState appState;

  const _RatingStep({
    super.key,
    required this.primaryColor,
    required this.onRate,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appState.t('customerRateTitle'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            appState.t('customerRateSubtitle'),
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F172A).withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => onRate(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FaIcon(
                      FontAwesomeIcons.solidStar,
                      size: 40,
                      color: const Color(0xFFFACC15).withValues(alpha: 0.35),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardStep extends StatelessWidget {
  final int rating;
  final String industry;
  final Color primaryColor;
  final Color accentColor;
  final AppState appState;
  final VoidCallback onClaim;

  const _RewardStep({
    super.key,
    required this.rating,
    required this.industry,
    required this.primaryColor,
    required this.accentColor,
    required this.appState,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final rewards = getRewardsByStars(industry, rating);
    final code = '${industry.toUpperCase().substring(0, min(3, industry.length))}-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stars display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FaIcon(
                  FontAwesomeIcons.solidStar,
                  size: 20,
                  color: i < rating
                      ? const Color(0xFFFACC15)
                      : const Color(0xFF0F172A).withValues(alpha: 0.15),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            rating >= 4 ? appState.t('customerThanks5') : appState.t('customerThanksLow'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Reward card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.08),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                FaIcon(FontAwesomeIcons.gift, size: 28, color: primaryColor),
                const SizedBox(height: 12),
                Text(
                  rewards.isNotEmpty ? rewards.first : appState.selectedReward,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Code
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: const Color(0xFF0F172A),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appState.t('customerShowCode'),
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                appState.t('customerClaimReward'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThanksStep extends StatelessWidget {
  final Color primaryColor;
  final AppState appState;
  final VoidCallback onReset;

  const _ThanksStep({
    super.key,
    required this.primaryColor,
    required this.appState,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            appState.t('customerFinalThanks'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            appState.t('customerFinalSubtitle'),
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0F172A).withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: onReset,
            child: Text(
              'Recommencer',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
