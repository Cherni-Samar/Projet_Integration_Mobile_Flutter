import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:flutter/material.dart';

class MyAgentsTheme {
  const MyAgentsTheme._();

  static const volt = Color(0xFFCDFF00);
}

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

class MyAgentCard extends StatelessWidget {
  const MyAgentCard({
    super.key,
    required this.agent,
    required this.isDark,
    required this.onTap,
    required this.onRename,
  });

  final OwnedAgent agent;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: agent.agentColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: agent.agentColor.withValues(alpha: isDark ? 0.1 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            AgentAvatar(agent: agent, size: 60, borderRadius: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AgentNameBlock(agent: agent, isDark: isDark),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        onSelected: (value) {
                          if (value == 'rename') onRename();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: agent.agentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          agent.packTitle,
                          style: TextStyle(
                            color: agent.agentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.bolt, color: agent.agentColor, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        formatAgentEnergy(agent.energy),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const ReadyBadge(),
          ],
        ),
      ),
    );
  }
}

class RenameAgentDialog extends StatelessWidget {
  const RenameAgentDialog({
    super.key,
    required this.agent,
    required this.isDark,
    required this.controller,
    required this.onSave,
  });

  final OwnedAgent agent;
  final bool isDark;
  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          AgentAvatar(agent: agent, size: 36, borderRadius: 10),
          const SizedBox(width: 12),
          Text(
            'Rename Agent',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: agent.agentName,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: agent.agentColor, width: 1.5),
          ),
          prefixIcon: Icon(Icons.edit, color: agent.agentColor, size: 20),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: agent.agentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class EnergyTopupSheet extends StatelessWidget {
  const EnergyTopupSheet({
    super.key,
    required this.currentBalance,
    required this.onSelectPack,
  });

  final int currentBalance;
  final ValueChanged<String> onSelectPack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Recharger votre Énergie',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Solde actuel : ${formatAgentEnergy(currentBalance)} ⚡',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          TopupOptionTile(
            leading: const Text('⚡', style: TextStyle(fontSize: 18)),
            title: 'Pack Éco (100 crédits)',
            priceLabel: r'$10',
            accent: MyAgentsTheme.volt,
            onTap: () => onSelectPack('energy_eco'),
          ),
          const SizedBox(height: 12),
          TopupOptionTile(
            leading: const Text('⚡⚡', style: TextStyle(fontSize: 18)),
            title: 'Pack Boost (500 crédits)',
            priceLabel: r'$35',
            accent: MyAgentsTheme.volt,
            onTap: () => onSelectPack('energy_boost'),
          ),
        ],
      ),
    );
  }
}

class TopupOptionTile extends StatelessWidget {
  const TopupOptionTile({
    super.key,
    required this.leading,
    required this.title,
    required this.priceLabel,
    required this.accent,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String priceLabel;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: DefaultTextStyle(
                  style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                  child: leading,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priceLabel,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgentAvatar extends StatelessWidget {
  const AgentAvatar({
    super.key,
    required this.agent,
    required this.size,
    required this.borderRadius,
  });

  final OwnedAgent agent;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: agent.agentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          agent.agentIllustration,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Icon(Icons.smart_toy, color: agent.agentColor, size: size / 2),
        ),
      ),
    );
  }
}

class ReadyBadge extends StatelessWidget {
  const ReadyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Ready',
        style: TextStyle(
          color: Color(0xFF10B981),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AgentNameBlock extends StatelessWidget {
  const _AgentNameBlock({required this.agent, required this.isDark});

  final OwnedAgent agent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          agent.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (agent.displayName != agent.agentName)
          Text(
            agent.agentName,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

String formatAgentEnergy(int n) {
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
  }
  return n.toString();
}
