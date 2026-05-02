import 'package:flutter/material.dart';
import 'package:e_team/l10n/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onMarketTap;
  final VoidCallback onAgentsTap;
  final VoidCallback onActivityTap;
  final VoidCallback onStatsTap;
  final VoidCallback onSettingsTap;

  const AppBottomNavBar({
    Key? key,
    required this.isDark,
    required this.onMarketTap,
    required this.onAgentsTap,
    required this.onActivityTap,
    required this.onStatsTap,
    required this.onSettingsTap,
  }) : super(key: key);

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    bool isDark,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive
              ? (isDark ? const Color(0xFFCDFF00) : Colors.black)
              : (isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.4)),
          size: 26,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? (isDark ? const Color(0xFFCDFF00) : Colors.black)
                : (isDark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4)),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.storefront_outlined,
            l10n.agentMarketplaceNavMarket,
            true,
            isDark,
          ),
          GestureDetector(
            onTap: onAgentsTap,
            child: _buildNavItem(
              Icons.people_outline,
              l10n.agentMarketplaceNavAgents,
              false,
              isDark,
            ),
          ),
          GestureDetector(
            onTap: onActivityTap,
            child: _buildNavItem(Icons.history, 'Activity', false, isDark),
          ),
          GestureDetector(
            onTap: onStatsTap,
            child: _buildNavItem(
              Icons.bar_chart_rounded,
              l10n.agentMarketplaceNavStats,
              false,
              isDark,
            ),
          ),
          GestureDetector(
            onTap: onSettingsTap,
            child: _buildNavItem(
              Icons.settings_outlined,
              l10n.agentMarketplaceNavSettings,
              false,
              isDark,
            ),
          ),
        ],
      ),
    );
  }
}