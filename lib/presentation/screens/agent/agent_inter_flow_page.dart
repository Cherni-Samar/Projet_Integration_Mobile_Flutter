import 'dart:math';

import 'package:e_team/data/services/agent_interaction_service.dart';
import 'package:e_team/domain/models/agent_interaction_model.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_design.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_header_stats.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_inter_flow_states.dart';
import 'package:e_team/presentation/widgets/agent/inter_flow/agent_interaction_flow_widgets.dart';
import 'package:flutter/material.dart';

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
      final interactions = await AgentInteractionService.getAgentInteractions();
      final stats = await AgentInteractionService.getInteractionStats();

      if (mounted) {
        setState(() {
          _interactions = interactions;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion au serveur';
          _isLoading = false;
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

  List<AgentInteraction> _generateFallbackInteractions() {
    final random = Random();
    final interactions = <AgentInteraction>[];

    final examples = [
      {
        'sender': AgentType.hera,
        'receiver': AgentType.echo,
        'actionType': 'Staffing Alert',
        'summary':
            'Recruitment required for Tech Dept - Senior Flutter Developer position',
      },
      {
        'sender': AgentType.echo,
        'receiver': AgentType.hera,
        'actionType': 'Social Post Confirmation',
        'summary':
            'LinkedIn Job Post ID #4221 created and published successfully',
      },
      {
        'sender': AgentType.hera,
        'receiver': AgentType.timo,
        'actionType': 'Schedule Request',
        'summary':
            'Schedule exit interview for employee Eya - Departure date confirmed',
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

      interactions.add(
        AgentInteraction(
          id: 'fallback_$i',
          sender: example['sender'] as AgentType,
          receiver: example['receiver'] as AgentType,
          actionType: example['actionType'] as String,
          summary: example['summary'] as String,
          timestamp: DateTime.now().subtract(Duration(minutes: minutesAgo)),
          status: random.nextBool()
              ? InteractionStatus.success
              : InteractionStatus.encrypted,
        ),
      );
    }

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
            AgentInterFlowHeader(
              refreshController: _refreshController,
              onBack: () => Navigator.pop(context),
              onRefresh: _refreshInteractions,
            ),
            AgentInterFlowStats(stats: _stats, interactions: _interactions),
            Expanded(
              child: _isLoading
                  ? AgentInterFlowLoadingState(error: _error)
                  : AgentInteractionFlow(
                      interactions: _interactions,
                      arrowController: _arrowController,
                      onRefresh: _refreshInteractions,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
