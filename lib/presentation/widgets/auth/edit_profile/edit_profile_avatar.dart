import 'package:flutter/material.dart';

import 'package:e_team/domain/models/user_model.dart';
import 'package:e_team/presentation/widgets/auth/edit_profile/edit_profile_helpers.dart';

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
