import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/theme.dart';
import '../../services/app_state.dart';
import '../../widgets/master_nav.dart';
import 'sidebar.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/triage_tab.dart';
import 'tabs/portal_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/integrations_tab.dart';
import 'tabs/fortune_tab.dart';
import 'tabs/team_tab.dart';
import 'tabs/settings_tab.dart';

class MerchantDashboard extends StatelessWidget {
  const MerchantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.bgStart,
      body: Stack(
        children: [
          // Background mesh: linear-gradient(135deg, #0f172a 0%, #172033 50%, #1a1a2e 100%)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0, -1.0), // 135deg: top-left
                end: Alignment(1.0, 1.0),     // to bottom-right
                colors: [
                  AppColors.bgStart,  // #0f172a at 0%
                  AppColors.bgMiddle, // #172033 at 50%
                  AppColors.bgEnd,    // #1a1a2e at 100%
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Radial overlay 1: radial-gradient(ellipse 80% 50% at 50% -20%, rgba(99,102,241,0.12), transparent)
          // Brand/indigo glow at top-center
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -1.4), // 50% -20% => top center, above viewport
                  radius: 1.0,
                  colors: [
                    AppColors.brand.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                  // Ellipse 80% wide, 50% tall
                  focal: const Alignment(0.0, -1.4),
                  focalRadius: 0.0,
                ),
              ),
            ),
          ),
          // Radial overlay 2: radial-gradient(ellipse 60% 40% at 80% 50%, rgba(16,185,129,0.06), transparent)
          // Success/green glow at right-center
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.6, 0.0), // 80% 50% => right-center
                  radius: 0.8,
                  colors: [
                    AppColors.success.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Main layout
          Row(
            children: [
              // Desktop Sidebar
              if (isWide) const MerchantSidebar(),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Top nav area (mobile)
                    if (!isWide) const SizedBox(height: 70),
                    // Tab content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 16,
                          vertical: isWide ? 32 : 16,
                        ),
                        child: _buildCurrentTab(appState),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Master nav (floating top)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(child: MasterNav()),
          ),
          // Mobile bottom nav
          if (!isWide)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MobileBottomNav(),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(AppState appState) {
    switch (appState.currentTab) {
      case 'analytics':
        return const AnalyticsTab();
      case 'triage':
        return const TriageTab();
      case 'portal':
        return const PortalTab();
      case 'history':
        return const HistoryTab();
      case 'integrations':
        return const IntegrationsTab();
      case 'fortune':
        return const FortuneTab();
      case 'team':
        return const TeamTab();
      case 'settings':
        return const SettingsTab();
      default:
        return const AnalyticsTab();
    }
  }
}

class _MobileBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.slate900.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MobileNavItem(
              icon: FontAwesomeIcons.chartLine,
              label: 'Analyses',
              tabId: 'analytics',
              currentTab: appState.currentTab,
              onTap: () => appState.setTab('analytics'),
            ),
            _MobileNavItem(
              icon: FontAwesomeIcons.inbox,
              label: 'Messages',
              tabId: 'triage',
              currentTab: appState.currentTab,
              badge: appState.unrespondedCount,
              onTap: () => appState.setTab('triage'),
            ),
            _MobileNavItem(
              icon: FontAwesomeIcons.qrcode,
              label: 'QR',
              tabId: 'portal',
              currentTab: appState.currentTab,
              onTap: () => appState.setTab('portal'),
            ),
            _MobileNavItem(
              icon: FontAwesomeIcons.plug,
              label: 'Integr.',
              tabId: 'integrations',
              currentTab: appState.currentTab,
              onTap: () => appState.setTab('integrations'),
            ),
            _MobileNavItem(
              icon: FontAwesomeIcons.gear,
              label: 'Compte',
              tabId: 'settings',
              currentTab: appState.currentTab,
              onTap: () => appState.setTab('settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tabId;
  final String currentTab;
  final int? badge;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.tabId,
    required this.currentTab,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = tabId == currentTab;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                FaIcon(
                  icon,
                  size: 16,
                  color: active ? AppColors.brand : AppColors.slate500,
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.brand : AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
