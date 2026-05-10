import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';

class UserProfileOptionsList extends StatelessWidget {
  const UserProfileOptionsList({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onToggleTheme,
    required this.onEditProfile,
    required this.onLanguagePressed,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    required this.onLogoutPressed,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onEditProfile;
  final VoidCallback onLanguagePressed;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        UserProfileDarkModeTile(
          isDark: isDark,
          title: l10n.profileDarkMode,
          onChanged: (_) => onToggleTheme(),
        ),
        UserProfileOptionTile(
          icon: Icons.person_outline,
          title: l10n.profileEditProfile,
          onTap: onEditProfile,
          isDark: isDark,
        ),
        UserProfileOptionTile(
          icon: Icons.language,
          title: l10n.profileLanguage,
          onTap: onLanguagePressed,
          isDark: isDark,
        ),
        UserProfileOptionTile(
          icon: Icons.description_outlined,
          title: l10n.profileTerms,
          onTap: onTermsPressed,
          isDark: isDark,
        ),
        UserProfileOptionTile(
          icon: Icons.privacy_tip_outlined,
          title: l10n.profilePrivacy,
          onTap: onPrivacyPressed,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        UserProfileOptionTile(
          icon: Icons.logout,
          title: l10n.profileLogout,
          onTap: onLogoutPressed,
          isDestructive: true,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class UserProfileDarkModeTile extends StatelessWidget {
  const UserProfileDarkModeTile({
    super.key,
    required this.isDark,
    required this.title,
    required this.onChanged,
  });

  final bool isDark;
  final String title;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return UserProfileTileFrame(
      isDark: isDark,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFCDFF00).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? const Color(0xFFCDFF00) : Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFCDFF00),
          activeTrackColor: const Color(0xFFCDFF00).withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class UserProfileOptionTile extends StatelessWidget {
  const UserProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return UserProfileTileFrame(
      isDark: isDark,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive
                ? Colors.red
                : isDark
                ? Colors.white
                : Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? Colors.red
                : isDark
                ? Colors.white
                : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.5)
              : isDark
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.3),
          size: 18,
        ),
      ),
    );
  }
}

class UserProfileTileFrame extends StatelessWidget {
  const UserProfileTileFrame({
    super.key,
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
