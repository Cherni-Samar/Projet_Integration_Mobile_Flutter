import 'package:flutter/material.dart';

import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';

class UserProfileIdentity extends StatelessWidget {
  const UserProfileIdentity({
    super.key,
    required this.user,
    required this.l10n,
    required this.isDark,
  });

  final User? user;
  final AppLocalizations l10n;
  final bool isDark;

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
  const UserProfileAvatar({super.key, required this.initial});

  final String initial;

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
