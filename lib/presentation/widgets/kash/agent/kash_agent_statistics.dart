import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/kash/agent/kash_agent_theme.dart';

class KashStatisticsTab extends StatelessWidget {
  const KashStatisticsTab({
    super.key,
    required this.isAnalyzing,
    required this.onPickReceipt,
  });

  final bool isAnalyzing;
  final VoidCallback onPickReceipt;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques financières',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          KashEmptyStateCard(
            isAnalyzing: isAnalyzing,
            onPickReceipt: onPickReceipt,
          ),
        ],
      ),
    );
  }
}

class KashEmptyStateCard extends StatelessWidget {
  const KashEmptyStateCard({
    super.key,
    required this.isAnalyzing,
    required this.onPickReceipt,
  });

  final bool isAnalyzing;
  final VoidCallback onPickReceipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111511),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KashAgentShell.volt.withValues(alpha: 0.15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KashAgentShell.volt.withValues(alpha: 0.05),
            KashAgentShell.gold.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  KashAgentShell.volt.withValues(alpha: 0.3),
                  KashAgentShell.gold.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: KashAgentShell.volt.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: KashAgentShell.volt,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune dépense enregistrée',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à scanner vos factures pour\nanalyser et catégoriser vos dépenses.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: KashAgentShell.volt,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              onPressed: isAnalyzing ? null : onPickReceipt,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text(
                'Scanner ma première facture',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Appuyez sur le bouton flottant pour commencer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
