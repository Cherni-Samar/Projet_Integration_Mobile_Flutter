import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import '/data/services/agent_interaction_service.dart';
import '/domain/models/agent_interaction_model.dart';

// ═══════════════════════════════════════════════════════════════
// 🎨 AGENT INTER-FLOW - WHITE SAAS PREMIUM DESIGN
// ═══════════════════════════════════════════════════════════════

class AgentInterFlowDesignSystem {
  // White SaaS Theme Colors
  static const Color bg = Color(0xFFFFFFFF);           // Fond blanc pur
  static const Color card = Color(0xFFFFFFFF);         // Cartes blanches
  static const Color border = Color(0xFFF1F5F9);       // Bordures ultra-fines gris-bleu
  static const Color textPrimary = Color(0xFF0F172A);  // Texte principal
  static const Color textSecondary = Color(0xFF64748B); // Texte secondaire
  static const Color textMuted = Color(0xFF94A3B8);    // Texte atténué
  
  // Agent Identity Colors (Pastels)
  static const Color heraGreen = Color(0xFFE8F5E8);    // Hera - Vert pastel
  static const Color echoViolet = Color(0xFFF3E8FF);   // Echo - Violet pastel
  static const Color timoOrange = Color(0xFFFFF4E6);   // Timo - Orange pastel
  static const Color dexoBlue = Color(0xFFE6F3FF);     // Dexo - Bleu pastel
  static const Color kashTeal = Color(0xFFE6FFFA);     // Kash - Teal pastel
  
  // Agent Icon Colors (Vifs)
  static const Color heraGreenIcon = Color(0xFF10B981);
  static const Color echoVioletIcon = Color(0xFF8B5CF6);
  static const Color timoOrangeIcon = Color(0xFFFF9800);
  static const Color dexoBlueIcon = Color(0xFF3B82F6);
  static const Color kashTealIcon = Color(0xFF06B6D4);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);      // Vert succès
  static const Color encrypted = Color(0xFF8B5CF6);    // Violet pour encrypted
  static const Color shadowLight = Color(0x08000000);  // Ombre ultra-légère
}

class AgentInteractionUi {
  static Map<AgentType, Map<String, dynamic>> get agentConfig => {
    AgentType.hera: {
      'name': 'HERA',
      'icon': Icons.people_outline,
      'bgColor': AgentInterFlowDesignSystem.heraGreen,
      'iconColor': AgentInterFlowDesignSystem.heraGreenIcon,
    },
    AgentType.echo: {
      'name': 'ECHO',
      'icon': Icons.campaign_outlined,
      'bgColor': AgentInterFlowDesignSystem.echoViolet,
      'iconColor': AgentInterFlowDesignSystem.echoVioletIcon,
    },
    AgentType.timo: {
      'name': 'TIMO',
      'icon': Icons.schedule_outlined,
      'bgColor': AgentInterFlowDesignSystem.timoOrange,
      'iconColor': AgentInterFlowDesignSystem.timoOrangeIcon,
    },
    AgentType.dexo: {
      'name': 'DEXO',
      'icon': Icons.admin_panel_settings_outlined,
      'bgColor': AgentInterFlowDesignSystem.dexoBlue,
      'iconColor': AgentInterFlowDesignSystem.dexoBlueIcon,
    },
    AgentType.kash: {
      'name': 'KASH',
      'icon': Icons.account_balance_outlined,
      'bgColor': AgentInterFlowDesignSystem.kashTeal,
      'iconColor': AgentInterFlowDesignSystem.kashTealIcon,
    },
  };
}

extension AgentInteractionUiX on AgentInteraction {
  Color get statusColor {
    switch (status) {
      case InteractionStatus.success:
        return AgentInterFlowDesignSystem.success;
      case InteractionStatus.encrypted:
        return AgentInterFlowDesignSystem.encrypted;
      case InteractionStatus.pending:
        return AgentInterFlowDesignSystem.textMuted;
      case InteractionStatus.failed:
        return Colors.red;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// 🏠 AGENT INTER-FLOW PAGE
// ═══════════════════════════════════════════════════════════════

class AgentInterFlowPage extends StatefulWidget {
  const AgentInterFlowPage({super.key});

  @override
  State<AgentInterFlowPage> createState() => _AgentInterFlowPageState();
}

class _AgentInterFlowPageState extends State<AgentInterFlowPage>
    with TickerProviderStateMixin {
  
  List<AgentInteraction> _interactions = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String? _error;
  late AnimationController _refreshController;
  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    
    _refreshController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _loadInteractions();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  Future<void> _loadInteractions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      print('🔄 Chargement des interactions depuis le backend...');
      
      // ✅ CHARGEMENT DYNAMIQUE DEPUIS LE BACKEND
      final interactions = await AgentInteractionService.getAgentInteractions();
      final stats = await AgentInteractionService.getInteractionStats();
      
      print('✅ Reçu ${interactions.length} interactions du backend');
      
      if (mounted) {
        setState(() {
          _interactions = interactions;
          _stats = stats;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('❌ Erreur lors du chargement des interactions: $e');
      
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion au serveur';
          _isLoading = false;
          // Fallback vers des données simulées en cas d'erreur
          _interactions = _generateFallbackInteractions();
          _stats = {
            'total': _interactions.length,
            'successful': (_interactions.length * 0.7).round(),
            'encrypted': (_interactions.length * 0.3).round(),
            'pending': 0,
            'failed': 0,
          };
        });
      }
    }
  }

  // ✅ FALLBACK - Données simulées en cas d'erreur de connexion
  List<AgentInteraction> _generateFallbackInteractions() {
    print('⚠️ Utilisation des données de fallback (simulées)');
    
    final random = Random();
    final interactions = <AgentInteraction>[];
    
    // Exemples d'échanges réalistes pour le fallback
    final examples = [
      {
        'sender': AgentType.hera,
        'receiver': AgentType.echo,
        'actionType': 'Staffing Alert',
        'summary': 'Recruitment required for Tech Dept - Senior Flutter Developer position',
      },
      {
        'sender': AgentType.echo,
        'receiver': AgentType.hera,
        'actionType': 'Social Post Confirmation',
        'summary': 'LinkedIn Job Post ID #4221 created and published successfully',
      },
      {
        'sender': AgentType.hera,
        'receiver': AgentType.timo,
        'actionType': 'Schedule Request',
        'summary': 'Schedule exit interview for employee Eya - Departure date confirmed',
      },
      {
        'sender': AgentType.dexo,
        'receiver': AgentType.hera,
        'actionType': 'Document Generation',
        'summary': 'Payslip PDF generated for March 2024, ready for delivery',
      },
      {
        'sender': AgentType.timo,
        'receiver': AgentType.echo,
        'actionType': 'Event Notification',
        'summary': 'Team meeting scheduled - Social media strategy review',
      },
    ];

    for (int i = 0; i < 8; i++) {
      final example = examples[random.nextInt(examples.length)];
      final minutesAgo = random.nextInt(120) + 1;
      
      interactions.add(AgentInteraction(
        id: 'fallback_$i',
        sender: example['sender'] as AgentType,
        receiver: example['receiver'] as AgentType,
        actionType: example['actionType'] as String,
        summary: example['summary'] as String,
        timestamp: DateTime.now().subtract(Duration(minutes: minutesAgo)),
        status: random.nextBool() 
            ? InteractionStatus.success 
            : InteractionStatus.encrypted,
      ));
    }

    // Trier par timestamp décroissant
    interactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return interactions;
  }

  Future<void> _refreshInteractions() async {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    
    await _loadInteractions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgentInterFlowDesignSystem.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfessionalHeader(),
            _buildSystemStats(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildInteractionFlow(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🏗️ PROFESSIONAL HEADER
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildProfessionalHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AgentInterFlowDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgentInterFlowDesignSystem.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AgentInterFlowDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton de retour
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AgentInterFlowDesignSystem.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgentInterFlowDesignSystem.border, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              color: AgentInterFlowDesignSystem.textPrimary,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          
          // Icône système
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AgentInterFlowDesignSystem.encrypted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.hub_outlined,
              color: AgentInterFlowDesignSystem.encrypted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Titre et sous-titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM ACTIVITY',
                  style: GoogleFonts.plusJakartaSans(
                    color: AgentInterFlowDesignSystem.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live Inter-Agent Exchange Logs',
                  style: GoogleFonts.plusJakartaSans(
                    color: AgentInterFlowDesignSystem.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton Refresh
          GestureDetector(
            onTap: _refreshInteractions,
            child: AnimatedBuilder(
              animation: _refreshController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshController.value * 2 * pi,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AgentInterFlowDesignSystem.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AgentInterFlowDesignSystem.success.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AgentInterFlowDesignSystem.success,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 📊 SYSTEM STATS
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildSystemStats() {
    final totalInteractions = _stats['total'] ?? _interactions.length;
    final successfulInteractions = _stats['successful'] ?? _interactions.where((i) => i.status == InteractionStatus.success).length;
    final encryptedInteractions = _stats['encrypted'] ?? _interactions.where((i) => i.status == InteractionStatus.encrypted).length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AgentInterFlowDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgentInterFlowDesignSystem.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AgentInterFlowDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatMetric(
              'TOTAL EXCHANGES',
              totalInteractions.toString(),
              Icons.swap_horiz_rounded,
              AgentInterFlowDesignSystem.textPrimary,
            ),
          ),
          Container(width: 1, height: 40, color: AgentInterFlowDesignSystem.border),
          Expanded(
            child: _buildStatMetric(
              'SUCCESSFUL',
              successfulInteractions.toString(),
              Icons.check_circle_outline,
              AgentInterFlowDesignSystem.success,
            ),
          ),
          Container(width: 1, height: 40, color: AgentInterFlowDesignSystem.border),
          Expanded(
            child: _buildStatMetric(
              'ENCRYPTED',
              encryptedInteractions.toString(),
              Icons.security_outlined,
              AgentInterFlowDesignSystem.encrypted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: AgentInterFlowDesignSystem.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: AgentInterFlowDesignSystem.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 INTERACTION FLOW
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildInteractionFlow() {
    if (_interactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshInteractions,
      color: AgentInterFlowDesignSystem.encrypted,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _interactions.length,
        itemBuilder: (context, index) {
          return _buildInteractionCard(_interactions[index], index);
        },
      ),
    );
  }

  Widget _buildInteractionCard(AgentInteraction interaction, int index) {
    final senderConfig = AgentInteractionUi.agentConfig[interaction.sender]!;
    final receiverConfig = AgentInteractionUi.agentConfig[interaction.receiver]!;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AgentInterFlowDesignSystem.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AgentInterFlowDesignSystem.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: AgentInterFlowDesignSystem.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec agents et flèche
            Row(
              children: [
                // Agent émetteur
                _buildAgentAvatar(
                  senderConfig['name'],
                  senderConfig['icon'],
                  senderConfig['bgColor'],
                  senderConfig['iconColor'],
                ),
                
                const SizedBox(width: 16),
                
                // Flèche animée
                Expanded(
                  child: _buildAnimatedArrow(),
                ),
                
                const SizedBox(width: 16),
                
                // Agent récepteur
                _buildAgentAvatar(
                  receiverConfig['name'],
                  receiverConfig['icon'],
                  receiverConfig['bgColor'],
                  receiverConfig['iconColor'],
                ),
                
                const SizedBox(width: 16),
                
                // Badge de statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: interaction.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: interaction.statusColor.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    interaction.statusLabel,
                    style: GoogleFonts.plusJakartaSans(
                      color: interaction.statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Type d'action
            Text(
              interaction.actionType.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: AgentInterFlowDesignSystem.encrypted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Résumé du message
            Text(
              interaction.summary,
              style: GoogleFonts.plusJakartaSans(
                color: AgentInterFlowDesignSystem.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: AgentInterFlowDesignSystem.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  interaction.timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                    color: AgentInterFlowDesignSystem.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentAvatar(String name, IconData icon, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withOpacity(0.2), width: 0.5),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            color: AgentInterFlowDesignSystem.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedArrow() {
    return AnimatedBuilder(
      animation: _arrowController,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AgentInterFlowDesignSystem.encrypted.withOpacity(0.3),
                      AgentInterFlowDesignSystem.encrypted.withOpacity(0.8),
                      AgentInterFlowDesignSystem.encrypted.withOpacity(0.3),
                    ],
                    stops: [
                      0.0,
                      _arrowController.value,
                      1.0,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              color: AgentInterFlowDesignSystem.encrypted.withOpacity(0.6 + 0.4 * _arrowController.value),
              size: 16,
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🔄 LOADING & EMPTY STATES
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AgentInterFlowDesignSystem.encrypted,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            _error != null ? _error! : 'Scanning network activity...',
            style: GoogleFonts.plusJakartaSans(
              color: _error != null 
                  ? Colors.red 
                  : AgentInterFlowDesignSystem.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              'Using fallback data',
              style: GoogleFonts.plusJakartaSans(
                color: AgentInterFlowDesignSystem.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AgentInterFlowDesignSystem.encrypted.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hub_outlined,
              size: 64,
              color: AgentInterFlowDesignSystem.encrypted.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Network Quiet',
            style: GoogleFonts.plusJakartaSans(
              color: AgentInterFlowDesignSystem.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No inter-agent exchanges detected',
            style: GoogleFonts.plusJakartaSans(
              color: AgentInterFlowDesignSystem.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
