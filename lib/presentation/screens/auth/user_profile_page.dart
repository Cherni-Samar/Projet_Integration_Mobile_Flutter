import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/screens/auth/edit_profile_screen.dart';
import 'package:e_team/presentation/screens/settings/language_settings_screen.dart';
import 'package:e_team/presentation/screens/settings/privacy_policy_screen.dart';
import 'package:e_team/presentation/screens/settings/terms_and_conditions_screen.dart';
import 'package:e_team/presentation/widgets/auth/user_profile_widgets.dart';

class UserProfilePage extends StatefulWidget {
  final User? user;

  const UserProfilePage({super.key, this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getSavedUser() as User?;
      if (mounted) {
        setState(() {
          _currentUser = user ?? widget.user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentUser = widget.user;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => UserProfileLogoutDialog(
        l10n: l10n,
        isDark: context.watch<ThemeProvider>().isDarkMode,
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return UserProfileLoadingScaffold(isDark: isDark);
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              title: l10n.profileTitle,
              isDark: isDark,
              onBackPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            UserProfileIdentity(user: _currentUser, l10n: l10n, isDark: isDark),
            const SizedBox(height: 30),
            Expanded(
              child: UserProfileOptionsList(
                l10n: l10n,
                isDark: isDark,
                onToggleTheme: themeProvider.toggleTheme,
                onEditProfile: () => _openEditProfile(l10n),
                onLanguagePressed: () =>
                    _pushPage(const LanguageSettingsScreen()),
                onTermsPressed: () =>
                    _pushPage(const TermsAndConditionsScreen()),
                onPrivacyPressed: () => _pushPage(const PrivacyPolicyScreen()),
                onLogoutPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pushPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Future<void> _openEditProfile(AppLocalizations l10n) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileUserDataNotAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _currentUser!),
      ),
    );

    if (result == true && mounted) {
      await _loadUserData();
      if (!context.mounted) return;
      _showProfileUpdatedSnackBar(l10n);
    }
  }

  void _showProfileUpdatedSnackBar(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(l10n.profileUpdatedSuccessfully),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
