import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

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
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
    String code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authEnterAll6Digits),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authEmailMissing),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔵 Vérification du code...');
      print('📧 Email: $_email');
      print('🔢 Code: $code');

      final success = await _authService.verifyEmail(_email!, code);

      print('✅ Résultat: $success');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authEmailVerifiedSuccess),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ Navigation vers le chatbot d'onboarding
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/onboarding-welcome',  // ✅ Changé de /login à /onboarding-chatbot
            arguments: {'email': _email!},  // ✅ Passez l'email
          );
        }

      }
    } catch (e) {
      print('❌ Erreur: $e');

      if (mounted) {
        String errorMessage = e.toString();

        if (errorMessage.contains('Code invalide')) {
          errorMessage = l10n.authInvalidCodeCheckEmail;
        } else if (errorMessage.contains('Code expiré')) {
          errorMessage = l10n.authCodeExpiredRequestNew;
        } else if (errorMessage.contains('déjà vérifié')) {
          errorMessage = l10n.authEmailAlreadyVerified;
          // Rediriger vers le login
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
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
      print('🔵 Renvoi du code...');

      final success = await _authService.resendVerificationCode(_email!);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authNewCodeSent),
            backgroundColor: Colors.green,
          ),
        );

        // Réinitialiser les champs
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        _startTimer();
      }
    } catch (e) {
      print('❌ Erreur: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.authErrorWithDetails(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDFF00).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 50,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),

              // Title
              Text(
                l10n.authVerifyYourEmailTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                l10n.authWeSentCodeTo,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _email ?? l10n.authYourEmailPlaceholder,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA855F7),
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                      (index) => _OTPBox(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (index == 5 && value.isNotEmpty) {
                        _verifyCode();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: const Color(0xFFCDFF00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFCDFF00),
                      ),
                    ),
                  )
                      : Text(
                    l10n.authVerifyEmailButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authDidntReceiveCode,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (_resendTimer > 0)
                    Text(
                      l10n.authResendInSeconds(_resendTimer),
                      style: const TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _isResending ? null : _resendCode,
                      child: _isResending
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(
                        l10n.authResendCode,
                        style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OTPBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focusNode.hasFocus
              ? const Color(0xFFCDFF00)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}