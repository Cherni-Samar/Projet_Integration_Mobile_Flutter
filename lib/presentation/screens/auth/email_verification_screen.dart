import 'package:flutter/material.dart';
import 'dart:async';

import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/widgets/auth/email_verification/email_verification_content.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;
  String? _email;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Récupérer l'email depuis les arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['email'] != null) {
        setState(() {
          _email = args['email'];
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      _showSnackBar(l10n.authEnterAll6Digits, Colors.orange);
      return;
    }

    if (_email == null) {
      _showSnackBar(l10n.authEmailMissing, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.verifyEmail(_email!, code);

      if (success && mounted) {
        _showSnackBar(
          l10n.authEmailVerifiedSuccess,
          Colors.green,
          duration: const Duration(seconds: 2),
        );

        // ✅ Navigation vers le login après vérification de l'email
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _localizedVerificationError(e, l10n);
        if (errorMessage == l10n.authEmailAlreadyVerified) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          });
        }

        _showSnackBar(
          '❌ $errorMessage',
          Colors.red,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (_email == null) return;
    if (_resendTimer > 0) return;

    setState(() => _isResending = true);

    try {
      final success = await _authService.resendVerificationCode(_email!);

      if (success && mounted) {
        _showSnackBar(l10n.authNewCodeSent, Colors.green);

        // Réinitialiser les champs
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(l10n.authErrorWithDetails(e.toString()), Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  String _localizedVerificationError(Object error, AppLocalizations l10n) {
    final errorMessage = error.toString();

    if (errorMessage.contains('Code invalide')) {
      return l10n.authInvalidCodeCheckEmail;
    }
    if (errorMessage.contains('Code expiré')) {
      return l10n.authCodeExpiredRequestNew;
    }
    if (errorMessage.contains('déjà vérifié')) {
      return l10n.authEmailAlreadyVerified;
    }

    return errorMessage;
  }

  void _showSnackBar(
    String message,
    Color backgroundColor, {
    Duration? duration,
  }) {
    AppSnackBar.show(
      context,
      message,
      type: _snackBarTypeFor(backgroundColor),
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  AppSnackBarType _snackBarTypeFor(Color color) {
    if (color == Colors.green) return AppSnackBarType.success;
    if (color == Colors.orange) return AppSnackBarType.warning;
    if (color == Colors.red) return AppSnackBarType.error;
    return AppSnackBarType.info;
  }

  void _handleCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (index == 5 && value.isNotEmpty) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: EmailVerificationContent(
          l10n: l10n,
          email: _email,
          controllers: _controllers,
          focusNodes: _focusNodes,
          isLoading: _isLoading,
          isResending: _isResending,
          resendTimer: _resendTimer,
          onVerify: _verifyCode,
          onResend: _resendCode,
          onCodeChanged: _handleCodeChanged,
        ),
      ),
    );
  }
}
