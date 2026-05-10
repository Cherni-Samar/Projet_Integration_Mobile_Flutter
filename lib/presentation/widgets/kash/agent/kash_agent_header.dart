import 'package:flutter/material.dart';

import 'package:e_team/presentation/widgets/kash/agent/kash_agent_theme.dart';

class KashScanFab extends StatelessWidget {
  const KashScanFab({super.key, required this.isBusy, required this.onPressed});

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isBusy ? null : onPressed,
      backgroundColor: KashAgentShell.volt,
      foregroundColor: Colors.black,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.camera_alt, size: 20),
      label: const Text(
        'Scanner facture',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
      ),
    );
  }
}

class KashProfileHeader extends StatelessWidget {
  const KashProfileHeader({
    super.key,
    required this.energy,
    required this.onBack,
  });

  final int energy;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KashAgentShell.volt.withValues(alpha: 0.15),
            KashAgentShell.gold.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KashAgentShell.volt.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: KashAgentShell.volt.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 10, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const KashProfileAvatar(),
                const SizedBox(width: 16),
                Expanded(child: KashProfileCopy(energy: energy)),
                const Icon(
                  Icons.verified_rounded,
                  color: KashAgentShell.volt,
                  size: 24,
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              top: false,
              bottom: false,
              left: false,
              right: false,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black26,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: onBack,
                  tooltip: 'Retour',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KashProfileAvatar extends StatelessWidget {
  const KashProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KashAgentShell.volt.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/kash.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    KashAgentShell.volt.withValues(alpha: 0.6),
                    KashAgentShell.gold.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.black,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}

class KashProfileCopy extends StatelessWidget {
  const KashProfileCopy({super.key, required this.energy});

  final int energy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kash Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Financial Analysis Agent',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: KashAgentShell.volt.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: KashAgentShell.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, size: 14, color: KashAgentShell.gold),
                  const SizedBox(width: 4),
                  Text(
                    '$energy',
                    style: const TextStyle(
                      color: KashAgentShell.volt,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
