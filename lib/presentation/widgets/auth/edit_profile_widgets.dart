import 'package:flutter/material.dart';

import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/domain/models/user_model.dart';

class EditProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final bool isDark;
  final VoidCallback onBackPressed;

  const EditProfileAppBar({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: onBackPressed,
      ),
      title: Text(
        l10n.authEditProfileTitle,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}

class EditProfileAvatar extends StatelessWidget {
  final User user;
  final bool isDark;

  const EditProfileAvatar({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                editProfileInitial(user),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Color(0xFFCDFF00),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool isDark;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  const EditProfileTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.isDark,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditProfileLabel(text: label, isDark: isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: editProfileInputDecoration(
            hintText: hintText,
            icon: icon,
            isDark: isDark,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class EditProfilePasswordToggle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const EditProfilePasswordToggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFCDFF00),
        ),
      ],
    );
  }
}

class EditProfileVisibilityButton extends StatelessWidget {
  final bool isObscured;
  final bool isDark;
  final VoidCallback onPressed;

  const EditProfileVisibilityButton({
    super.key,
    required this.isObscured,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off : Icons.visibility,
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.5),
      ),
      onPressed: onPressed,
    );
  }
}

class EditProfileUpdateButton extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isLoading;
  final VoidCallback onPressed;

  const EditProfileUpdateButton({
    super.key,
    required this.l10n,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                l10n.authUpdateProfileButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class EditProfileLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const EditProfileLabel({super.key, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

InputDecoration editProfileInputDecoration({
  required String hintText,
  required IconData icon,
  required bool isDark,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: isDark
          ? Colors.white.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.3),
    ),
    filled: true,
    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    prefixIcon: Icon(
      icon,
      color: isDark
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.5),
    ),
    suffixIcon: suffixIcon,
  );
}

String editProfileInitial(User user) {
  final name = user.name;
  if (name != null && name.isNotEmpty) {
    return name.substring(0, 1).toUpperCase();
  }

  return user.email.substring(0, 1).toUpperCase();
}
