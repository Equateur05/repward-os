import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/theme.dart';
import '../../services/app_state.dart';

class MerchantSidebar extends StatelessWidget {
  const MerchantSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final width = MediaQuery.of(context).size.width >= 1024 ? 288.0 : 256.0;

    return ClipRRect(
      child: BackdropFilter(
        // .glass: backdrop-filter: blur(24px) saturate(180%)
        filter: ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          inner: ColorFilter.matrix(<double>[
            1.8, 0, 0, 0, 0, // Red
            0, 1.8, 0, 0, 0, // Green
            0, 0, 1.8, 0, 0, // Blue
            0, 0, 0, 1, 0,   // Alpha
          ]),
        ),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            // .glass: background: rgba(30,41,59,0.5)
            color: AppColors.glassBackground,
            border: Border(
              // .glass: border: 1px solid rgba(255,255,255,0.08)
              right: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.brand, AppColors.brandDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.award, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Repward',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'OS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandLight,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Nav items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _NavItem(
                        icon: FontAwesomeIcons.chartLine,
                        label: appState.t('tabAnalytics'),
                        tabId: 'analytics',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.inbox,
                        label: appState.t('tabTriage'),
                        tabId: 'triage',
                        badge: appState.unrespondedCount > 0 ? '${appState.unrespondedCount}' : null,
                        badgeColor: AppColors.danger,
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.qrcode,
                        label: appState.t('tabPortal'),
                        tabId: 'portal',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.clockRotateLeft,
                        label: appState.t('tabHistory'),
                        tabId: 'history',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.plug,
                        label: appState.t('tabIntegrations'),
                        tabId: 'integrations',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.circleNotch,
                        label: appState.t('tabFortune'),
                        tabId: 'fortune',
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.users,
                        label: appState.t('tabTeam'),
                        tabId: 'team',
                      ),
                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          color: AppColors.glassBorder,
                          height: 1,
                        ),
                      ),
                      _NavItem(
                        icon: FontAwesomeIcons.gear,
                        label: appState.t('tabSettings'),
                        tabId: 'settings',
                      ),
                      const Spacer(),
                      // Reputation Score
                      _ReputationScore(),
                      const SizedBox(height: 16),
                      // Account card
                      _AccountCard(),
                      const SizedBox(height: 16),
                    ],
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tabId;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.tabId,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final active = appState.currentTab == tabId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => appState.setTab(tabId),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: active ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Center(
                    child: FaIcon(
                      icon,
                      size: 14,
                      color: active ? Colors.white : AppColors.slate400,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? Colors.white : AppColors.slate400,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor ?? Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws an SVG-style arc for the reputation score,
/// matching the HTML's SVG circle with stroke-dasharray.
class _ReputationArcPainter extends CustomPainter {
  final double score; // 0.0 to 1.0
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  _ReputationArcPainter({
    required this.score,
    required this.trackColor,
    required this.arcColor,
    this.strokeWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track (full circle background)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Arc (score progress) - starts from top (-90 degrees)
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * math.pi * score;
    canvas.drawArc(rect, -math.pi / 2, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(_ReputationArcPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _ReputationScore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final score = appState.reputationScore;
    final scoreNorm = appState.reputationScoreNormalized;
    final label = appState.reputationLabel;
    final badge = appState.reputationBadge;

    // Color based on score
    Color scoreColor;
    if (score >= 75) {
      scoreColor = AppColors.success;
    } else if (score >= 50) {
      scoreColor = AppColors.warning;
    } else if (score > 0) {
      scoreColor = AppColors.danger;
    } else {
      scoreColor = AppColors.slate500;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Score circle - custom painted SVG-style arc
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _ReputationArcPainter(
                score: scoreNorm,
                trackColor: AppColors.slate800,
                arcColor: scoreColor,
                strokeWidth: 3.0,
              ),
              child: Center(
                child: Text(
                  score > 0 ? '$score' : '--',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.trophy, size: 8, color: AppColors.brandLight),
              const SizedBox(width: 4),
              Text(
                badge,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final initials = appState.merchant.businessName.isNotEmpty
        ? appState.merchant.businessName.substring(0, appState.merchant.businessName.length >= 2 ? 2 : 1).toUpperCase()
        : 'CR';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.brand, AppColors.brandDark],
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.merchant.businessName.isNotEmpty
                          ? appState.merchant.businessName
                          : 'Mon Commerce',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Plan ${appState.merchant.plan.isNotEmpty ? appState.merchant.plan[0].toUpperCase() + appState.merchant.plan.substring(1) : "Gratuit"}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Usage bar — REAL DATA
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: appState.usageRatio,
              backgroundColor: AppColors.slate800,
              valueColor: AlwaysStoppedAnimation(
                appState.usageRatio >= 0.9 ? AppColors.danger : AppColors.brand,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            appState.responseLimit < 0
                ? '${appState.responsesThisMonth} r\u00E9ponses IA ce mois (illimit\u00E9)'
                : '${appState.responsesThisMonth}/${appState.responseLimit} r\u00E9ponses IA ce mois',
            style: TextStyle(
              fontSize: 10,
              color: appState.usageRatio >= 0.9 ? AppColors.danger : AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
