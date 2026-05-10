import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_shared.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_theme.dart';
import 'package:flutter/material.dart';

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
