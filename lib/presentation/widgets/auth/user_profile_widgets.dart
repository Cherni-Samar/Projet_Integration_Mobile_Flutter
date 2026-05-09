import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/domain/models/user_model.dart';

class UserProfileLoadingScaffold extends StatelessWidget {
  final bool isDark;

  const UserProfileLoadingScaffold({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      body: Center(
        child: CircularProgressIndicator(
          color: isDark ? const Color(0xFFCDFF00) : Colors.black,
        ),
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback onBackPressed;

  const UserProfileHeader({
    super.key,
    required this.title,
    required this.isDark,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class UserProfileIdentity extends StatelessWidget {
  final User? user;
  final AppLocalizations l10n;
  final bool isDark;

  const UserProfileIdentity({
    super.key,
    required this.user,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserProfileAvatar(initial: profileInitial(user, l10n)),
        const SizedBox(height: 20),
        Text(
          user?.name ?? l10n.commonUser,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? l10n.commonEmailPlaceholder,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.5),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class UserProfileAvatar extends StatelessWidget {
  final String initial;

  const UserProfileAvatar({super.key, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class UserProfileOptionsList extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onEditProfile;
  final VoidCallback onLanguagePressed;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;
  final VoidCallback onLogoutPressed;

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
  final bool isDark;
  final String title;
  final ValueChanged<bool> onChanged;

  const UserProfileDarkModeTile({
    super.key,
    required this.isDark,
    required this.title,
    required this.onChanged,
  });

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
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const UserProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

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
  final bool isDark;
  final Widget child;

  const UserProfileTileFrame({
    super.key,
    required this.isDark,
    required this.child,
  });

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

class UserProfileLogoutDialog extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isDark;

  const UserProfileLogoutDialog({
    super.key,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        l10n.logoutDialogTitle,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        l10n.logoutDialogMessage,
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : const Color(0xFF6B7280),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            l10n.commonCancel,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
            foregroundColor: isDark ? Colors.black : const Color(0xFFCDFF00),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(l10n.profileLogout),
        ),
      ],
    );
  }
}

String profileInitial(User? user, AppLocalizations l10n) {
  final name = user?.name;
  if (name != null && name.isNotEmpty) {
    return name.substring(0, 1).toUpperCase();
  }

  final email = user?.email;
  if (email != null && email.isNotEmpty) {
    return email.substring(0, 1).toUpperCase();
  }

  return l10n.commonUserInitial;
}
