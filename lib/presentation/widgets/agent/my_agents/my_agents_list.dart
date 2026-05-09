import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agent_card.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_theme.dart';
import 'package:flutter/material.dart';

class MyAgentsEmptyState extends StatelessWidget {
  const MyAgentsEmptyState({
    super.key,
    required this.isDark,
    required this.onGoToMarketplace,
  });

  final bool isDark;
  final VoidCallback onGoToMarketplace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No agents yet',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase energy packs to activate agents',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onGoToMarketplace,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? MyAgentsTheme.volt : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go to Marketplace'),
          ),
        ],
      ),
    );
  }
}

class MyAgentsList extends StatelessWidget {
  const MyAgentsList({
    super.key,
    required this.owned,
    required this.isDark,
    required this.energyBalance,
    required this.activeCount,
    required this.onTopup,
    required this.onOpenAgent,
    required this.onRenameAgent,
  });

  final OwnedAgentsProvider owned;
  final bool isDark;
  final int energyBalance;
  final int activeCount;
  final VoidCallback onTopup;
  final ValueChanged<OwnedAgent> onOpenAgent;
  final ValueChanged<OwnedAgent> onRenameAgent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyAgentsEnergyWallet(
          isDark: isDark,
          energyBalance: energyBalance,
          onTopup: onTopup,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$activeCount Agents Actifs',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: owned.count,
            itemBuilder: (context, index) {
              final agent = owned.agents[index];
              return MyAgentCard(
                agent: agent,
                isDark: isDark,
                onTap: () => onOpenAgent(agent),
                onRename: () => onRenameAgent(agent),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MyAgentsEnergyWallet extends StatelessWidget {
  const MyAgentsEnergyWallet({
    super.key,
    required this.isDark,
    required this.energyBalance,
    required this.onTopup,
  });

  final bool isDark;
  final int energyBalance;
  final VoidCallback onTopup;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF252525)]
              : [Colors.white, const Color(0xFFF5F5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Portefeuille d'Énergie",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatAgentEnergy(energyBalance),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text(
                        '⚡',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onTopup,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? MyAgentsTheme.volt : Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Acheter plus'),
          ),
        ],
      ),
    );
  }
}
