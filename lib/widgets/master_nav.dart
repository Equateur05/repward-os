import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import '../services/app_state.dart';

class MasterNav extends StatelessWidget {
  const MasterNav({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isMerchant = appState.currentView == 'merchant';

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.slate800.withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavButton(
              icon: FontAwesomeIcons.chartPie,
              label: appState.t('navDashboard'),
              active: isMerchant,
              onTap: () => appState.setView('merchant'),
            ),
            _NavButton(
              icon: FontAwesomeIcons.mobileScreen,
              label: appState.t('navCustomer'),
              active: !isMerchant,
              onTap: () => appState.setView('customer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? Colors.white : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 12,
              color: active ? AppColors.slate900 : AppColors.slate400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.slate900 : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
