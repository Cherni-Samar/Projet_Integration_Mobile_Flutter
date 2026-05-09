import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/widgets/auth/edit_profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPasswordFields = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    // Vérifier les mots de passe si modification
    if (_showPasswordFields) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authPasswordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await _authService.updateUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        currentPassword: _showPasswordFields
            ? _currentPasswordController.text
            : null,
        newPassword: _showPasswordFields ? _newPasswordController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authProfileUpdatedSnack),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
      appBar: EditProfileAppBar(
        l10n: l10n,
        isDark: isDark,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditProfileAvatar(user: widget.user, isDark: isDark),
                const SizedBox(height: 40),
                EditProfileTextField(
                  label: l10n.authNameLabel,
                  hintText: l10n.authEnterYourNameHint,
                  icon: Icons.person_outline,
                  isDark: isDark,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authNameRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                EditProfileTextField(
                  label: l10n.authEmailLabel,
                  hintText: l10n.authEnterYourEmailHint,
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.authEmailRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.authEmailInvalid;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),
                EditProfilePasswordToggle(
                  title: l10n.authChangePassword,
                  value: _showPasswordFields,
                  onChanged: (value) =>
                      setState(() => _showPasswordFields = value),
                  isDark: isDark,
                ),

                if (_showPasswordFields) ...[
                  const SizedBox(height: 20),
                  EditProfileTextField(
                    label: l10n.authCurrentPassword,
                    hintText: l10n.authEnterCurrentPasswordHint,
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    suffixIcon: EditProfileVisibilityButton(
                      isObscured: _obscureCurrentPassword,
                      isDark: isDark,
                      onPressed: () {
                        setState(
                          () => _obscureCurrentPassword =
                              !_obscureCurrentPassword,
                        );
                      },
                    ),
                    validator: (value) {
                      if (_showPasswordFields &&
                          (value == null || value.isEmpty)) {
                        return l10n.authCurrentPasswordRequired;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  EditProfileTextField(
                    label: l10n.authNewPassword,
                    hintText: l10n.authEnterNewPasswordHint,
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    suffixIcon: EditProfileVisibilityButton(
                      isObscured: _obscureNewPassword,
                      isDark: isDark,
                      onPressed: () {
                        setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        );
                      },
                    ),
                    validator: (value) {
                      if (_showPasswordFields &&
                          (value == null || value.length < 6)) {
                        return l10n.authPasswordMin6;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  EditProfileTextField(
                    label: l10n.authConfirmNewPassword,
                    hintText: l10n.authConfirmNewPasswordHint,
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: EditProfileVisibilityButton(
                      isObscured: _obscureConfirmPassword,
                      isDark: isDark,
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    validator: (value) {
                      if (_showPasswordFields &&
                          value != _newPasswordController.text) {
                        return l10n.authPasswordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 40),
                EditProfileUpdateButton(
                  l10n: l10n,
                  isLoading: _isLoading,
                  onPressed: _updateProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
