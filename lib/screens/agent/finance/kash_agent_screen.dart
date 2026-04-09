import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';

class KashAgentScreen extends StatefulWidget {
  const KashAgentScreen({super.key});

  @override
  State<KashAgentScreen> createState() => _KashAgentScreenState();
}

class _KashAgentScreenState extends State<KashAgentScreen>
    with SingleTickerProviderStateMixin {
  static const _volt = Color(0xFFCDFF00);
  static const _gold = Color(0xFFFFD54F);

  final _auth = AuthService();
  final _picker = ImagePicker();

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late final AnimationController _shimmerController;

  final List<_KashMsg> _messages = <_KashMsg>[];

  bool _isAnalyzing = false;
  _ExtractedExpense? _pendingExtraction;
  Uint8List? _pendingReceiptBytes;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _messages.add(
      const _KashMsg(
        fromUser: false,
        text: "Je suis Kash. Envoie-moi un reçu pour l'analyser.",
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 220,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _showAlert(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111511),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: _volt)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _getToken() async {
    return _auth.getToken();
  }

  Future<void> _pickReceipt() async {
    if (_isAnalyzing) return;

    final energy = context.read<UserProvider>().energyBalance;
    if (energy < 10) {
      await _showAlert('Énergie insuffisante',
          "Vous avez $energy d'énergie. L'analyse coûte 10 unités.");
      return;
    }

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      _pendingExtraction = null;
      _pendingReceiptBytes = bytes;
      _messages.add(
        _KashMsg(
          fromUser: true,
          text: 'Reçu sélectionné',
          imageBytes: bytes,
        ),
      );
      _isAnalyzing = true;
    });
    await _scrollToBottom();

    try {
      final token = await _getToken();

      final response = await ApiService.post(
        endpoint: ApiConstants.kashAnalyze,
        token: token,
        body: {
          'imageBase64': base64Image,
        },
      );

      final extractedJson =
          (response['data']?['extracted'] as Map?)?.cast<String, dynamic>();
      final newBalance = response['data']?['energyBalance'];

      if (newBalance is num) {
        await _updateEnergyBalance(newBalance.toInt());
      }

      if (extractedJson == null) {
        throw Exception("Réponse invalide: champ 'extracted' manquant");
      }

      final extracted = _ExtractedExpense.fromJson(extractedJson);

      setState(() {
        _pendingExtraction = extracted;
        _messages.add(
          _KashMsg(
            fromUser: false,
            text:
                'Analyse terminée.\nMontant: ${extracted.amount} ${extracted.currency}\nFournisseur: ${extracted.vendor}\nCatégorie: ${extracted.category}',
          ),
        );
      });
      await _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          _KashMsg(
            fromUser: false,
            text: "Erreur d'analyse: ${e.toString()}",
          ),
        );
      });
      await _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _updateEnergyBalance(int newBalance) async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    if (user == null) return;

    await userProvider.setUser(user.copyWith(energyBalance: newBalance));
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_KashMsg(fromUser: true, text: text));
      _messages.add(
        const _KashMsg(
          fromUser: false,
          text:
              "Pour analyser une dépense, appuie sur l'icône Photo et sélectionne un reçu.",
        ),
      );
    });

    _textController.clear();
    _scrollToBottom();
  }

  Future<void> _confirmAndSave() async {
    final extracted = _pendingExtraction;
    if (extracted == null) return;

    try {
      final token = await _getToken();

      final response = await ApiService.post(
        endpoint: ApiConstants.kashAddExpense,
        token: token,
        body: {
          'amount': extracted.amount,
          'currency': extracted.currency,
          'vendor': extracted.vendor,
          'category': extracted.category,
          'description': extracted.description,
          'date': extracted.dateIso,
          'isSubscription': false,
        },
      );

      final newBalance = response['data']?['energyBalance'];
      if (newBalance is num) {
        await _updateEnergyBalance(newBalance.toInt());
      }

      setState(() {
        _messages.add(
          const _KashMsg(
            fromUser: false,
            text: 'Dépense enregistrée avec succès.',
          ),
        );
        _pendingExtraction = null;
        _pendingReceiptBytes = null;
      });
      await _scrollToBottom();
    } catch (e) {
      await _showAlert('Erreur', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<UserProvider>().energyBalance;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E0B),
      body: SafeArea(
        child: Column(
          children: [
            _Header(energy: energy),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: _messages.length + (_isAnalyzing ? 1 : 0),
                itemBuilder: (context, index) {
                  final isLoadingRow = _isAnalyzing && index == _messages.length;
                  if (isLoadingRow) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: _ShimmerBubble(
                        controller: _shimmerController,
                        child: const Text(
                          "Kash analyse votre document...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }

                  final msg = _messages[index];
                  return _MessageBubble(msg: msg);
                },
              ),
            ),

            if (_pendingExtraction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: _ExtractionCard(
                  extracted: _pendingExtraction!,
                  receiptBytes: _pendingReceiptBytes,
                  onConfirm: _confirmAndSave,
                ),
              ),

            _Composer(
              controller: _textController,
              isBusy: _isAnalyzing,
              onSend: _sendText,
              onPickPhoto: _pickReceipt,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  static const _volt = Color(0xFFCDFF00);
  static const _gold = Color(0xFFFFD54F);

  final int energy;

  const _Header({required this.energy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF111511),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF111511),
            child: ClipOval(
              child: Image.asset(
                'assets/images/kash.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kash',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Agent Financier',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111511),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _volt.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 16, color: _gold),
                const SizedBox(width: 6),
                Text(
                  '$energy',
                  style: const TextStyle(
                    color: _volt,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  static const _volt = Color(0xFFCDFF00);

  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback onSend;
  final VoidCallback onPickPhoto;

  const _Composer({
    required this.controller,
    required this.isBusy,
    required this.onSend,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F130F),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isBusy,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF111511),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _volt, width: 1.2),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: isBusy ? null : onPickPhoto,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF111511),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _volt.withOpacity(0.25)),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                color: isBusy ? Colors.white30 : _volt,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: isBusy ? null : onSend,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _volt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.send, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  static const _volt = Color(0xFFCDFF00);
  static const _gold = Color(0xFFFFD54F);

  final _KashMsg msg;

  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final fromUser = msg.fromUser;
    final bg = fromUser ? const Color(0xFF121A12) : const Color(0xFF111511);
    final border = fromUser ? _volt.withOpacity(0.25) : Colors.white.withOpacity(0.06);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment:
                  fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    color: fromUser ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                if (msg.imageBytes != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: _gold.withOpacity(0.25)),
                      ),
                      child: Image.memory(
                        msg.imageBytes!,
                        width: 180,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExtractionCard extends StatelessWidget {
  static const _volt = Color(0xFFCDFF00);
  static const _gold = Color(0xFFFFD54F);

  final _ExtractedExpense extracted;
  final Uint8List? receiptBytes;
  final VoidCallback onConfirm;

  const _ExtractionCard({
    required this.extracted,
    required this.receiptBytes,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111511),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _volt.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: _gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Données extraites',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${extracted.amount} ${extracted.currency}',
                style: const TextStyle(
                  color: _volt,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (receiptBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(
                receiptBytes!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (receiptBytes != null) const SizedBox(height: 10),
          _kv('Fournisseur', extracted.vendor),
          _kv('Catégorie', extracted.category),
          _kv('Date', extracted.dateIso),
          if (extracted.description.isNotEmpty)
            _kv('Description', extracted.description),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _volt,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onConfirm,
              child: const Text(
                'Confirmer et Enregistrer',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              k,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBubble extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _ShimmerBubble({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111511),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: ShaderMask(
              shaderCallback: (rect) {
                final dx = rect.width * (t * 2 - 0.5);
                return LinearGradient(
                  begin: Alignment(-1 + (dx / rect.width), 0),
                  end: Alignment(1 + (dx / rect.width), 0),
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.65),
                    Colors.white.withOpacity(0.15),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _KashMsg {
  final bool fromUser;
  final String text;
  final Uint8List? imageBytes;

  const _KashMsg({
    required this.fromUser,
    required this.text,
    this.imageBytes,
  });
}

class _ExtractedExpense {
  final double amount;
  final String currency;
  final String vendor;
  final String category;
  final String dateIso;
  final String description;

  const _ExtractedExpense({
    required this.amount,
    required this.currency,
    required this.vendor,
    required this.category,
    required this.dateIso,
    required this.description,
  });

  factory _ExtractedExpense.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    final amount = (amountRaw is num) ? amountRaw.toDouble() : double.parse('$amountRaw');

    return _ExtractedExpense(
      amount: amount,
      currency: (json['currency'] ?? '').toString(),
      vendor: (json['vendor'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      dateIso: (json['date'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}
