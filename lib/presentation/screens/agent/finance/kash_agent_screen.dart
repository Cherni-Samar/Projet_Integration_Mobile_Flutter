import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/data/services/api_service.dart';
import 'package:e_team/data/services/auth_service.dart';
import 'package:e_team/core/utils/constants.dart';
import 'package:e_team/presentation/models/kash/kash_agent_models.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_composer.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_extraction_card.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_message_bubble.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_shimmer_bubble.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_header.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_navigation.dart';
import 'package:e_team/presentation/widgets/kash/agent/kash_agent_statistics.dart';

class KashAgentScreen extends StatefulWidget {
  const KashAgentScreen({super.key});

  @override
  State<KashAgentScreen> createState() => _KashAgentScreenState();
}

class _KashAgentScreenState extends State<KashAgentScreen>
    with SingleTickerProviderStateMixin {
  static const _volt = Color(0xFFCDFF00);

  final _auth = AuthService();
  final _picker = ImagePicker();

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late final AnimationController _shimmerController;

  final List<KashMessage> _messages = <KashMessage>[];

  bool _isAnalyzing = false;
  ExtractedExpense? _pendingExtraction;
  Uint8List? _pendingReceiptBytes;

  int _selectedTab = 0; // 0 = Chat, 1 = Expenses (placeholder)

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _messages.add(
      const KashMessage(
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

  Widget _buildFloatingActionButton(int energy) {
    return KashScanFab(isBusy: _isAnalyzing, onPressed: _pickReceipt);
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
      await _showAlert(
        'Énergie insuffisante',
        "Vous avez $energy d'énergie. L'analyse coûte 10 unités.",
      );
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
        KashMessage(
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
        body: {'imageBase64': base64Image},
      );

      final extractedJson = (response['data']?['extracted'] as Map?)
          ?.cast<String, dynamic>();
      final newBalance = response['data']?['energyBalance'];

      if (newBalance is num) {
        await _updateEnergyBalance(newBalance.toInt());
      }

      if (extractedJson == null) {
        throw Exception("Réponse invalide: champ 'extracted' manquant");
      }

      final extracted = ExtractedExpense.fromJson(extractedJson);

      setState(() {
        _pendingExtraction = extracted;
        _messages.add(
          KashMessage(
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
          KashMessage(
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

    //await userProvider.setUser(user.copyWith(energyBalance: newBalance));
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(KashMessage(fromUser: true, text: text));
      _messages.add(
        const KashMessage(
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
          const KashMessage(
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
      floatingActionButton: _buildFloatingActionButton(energy),
      body: SafeArea(
        child: Column(
          children: [
            // New Profile Header
            _buildProfileHeader(energy),

            // Tab Navigation
            _buildTabNavigation(),

            // Tab Content
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(int energy) {
    return KashProfileHeader(
      energy: energy,
      onBack: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildTabNavigation() {
    return KashTabNavigation(
      selectedTab: _selectedTab,
      onSelect: (index) => setState(() => _selectedTab = index),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _selectedTab,
      children: [
        // Chat Tab
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: _messages.length + (_isAnalyzing ? 1 : 0),
                itemBuilder: (context, index) {
                  final isLoadingRow =
                      _isAnalyzing && index == _messages.length;
                  if (isLoadingRow) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: KashShimmerBubble(
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
                  return KashMessageBubble(msg: msg);
                },
              ),
            ),

            if (_pendingExtraction != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: KashExtractionCard(
                  extracted: _pendingExtraction!,
                  receiptBytes: _pendingReceiptBytes,
                  onConfirm: _confirmAndSave,
                ),
              ),

            KashComposer(
              controller: _textController,
              isBusy: _isAnalyzing,
              onSend: _sendText,
              onPickPhoto: _pickReceipt,
            ),
          ],
        ),

        // Statistics Tab with Empty State
        _buildStatisticsTab(),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return KashStatisticsTab(
      isAnalyzing: _isAnalyzing,
      onPickReceipt: _pickReceipt,
    );
  }
}
