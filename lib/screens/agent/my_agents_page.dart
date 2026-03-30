import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/owned_agents_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/stripe_service.dart';
import 'agent_chat_page.dart';
import 'echo/echo_inbox_screen.dart';
import 'finance/kash_agent_screen.dart';
import 'hr/hr_dashboard_page.dart';

class MyAgentsPage extends StatelessWidget {
  const MyAgentsPage({Key? key}) : super(key: key);

  static const Color _volt = Color(0xFFCDFF00);
  static const Color _premium = Color(0xFFA855F7);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final activeAgents = userProvider.user?.activeAgents ?? const <String>[];

    // OwnedAgentsProvider est désormais synchronisé sur activeAgents via ProxyProvider.
    final owned = Provider.of<OwnedAgentsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'My Agents',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
          Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
        body: activeAgents.isEmpty
          ? _buildEmptyState(isDark, context)
          : _buildAgentsList(owned, isDark, context),
    );
  }

      String _agentId(String name) => name.trim().toLowerCase();

  Widget _buildEmptyState(bool isDark, BuildContext context) {
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
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFFCDFF00) : Colors.black,
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

  void _showRenameDialog(BuildContext context, OwnedAgent agent, bool isDark) {
    final controller = TextEditingController(text: agent.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: agent.agentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  agent.agentIllustration,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.smart_toy, color: agent.agentColor, size: 20),
                ),
              ),
            ),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final owned = Provider.of<OwnedAgentsProvider>(context, listen: false);
              owned.renameAgent(agent.agentName, controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Renamed to "${controller.text.trim().isEmpty ? agent.agentName : controller.text.trim()}"',
                  ),
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: agent.agentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsList(
      OwnedAgentsProvider owned, bool isDark, BuildContext context) {
    final energyBalance = context.watch<UserProvider>().energyBalance;
    final activeCount = context.watch<OwnedAgentsProvider>().count;
    final planLabel = context.watch<UserProvider>().subscriptionPlanLabel;

    return Column(
      children: [
        // ── Header cards (Energy + Subscription) ──
        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth >= 720;

              final energyCard = Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: _headerCardDecoration(isDark),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Color(0xFFF59E0B),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Portefeuille d'Énergie",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _fmtEnergy(energyBalance),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  '⚡',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _showEnergyTopupSheet(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? _volt : Colors.black,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Acheter plus'),
                    ),
                  ],
                ),
              );

              final subscriptionCard = Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: _headerCardDecoration(isDark),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _premium.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: _premium,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mon Abonnement',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            planLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        _showSubscriptionPlanSheet(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? _volt : Colors.black,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Modifier'),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: subscriptionCard),
                    const SizedBox(width: 12),
                    Expanded(child: energyCard),
                  ],
                );
              }

              return Column(
                children: [
                  subscriptionCard,
                  const SizedBox(height: 12),
                  energyCard,
                ],
              );
            },
          ),
        ),

        // ── Section title ──
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

        // ── Agent cards ──
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: owned.count,
            itemBuilder: (context, index) {
              final agent = owned.agents[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: agent.agentColor.withOpacity(0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: agent.agentColor.withOpacity(isDark ? 0.1 : 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    final id = _agentId(agent.agentName);
                    if (id == 'hera') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HrDashboardPage(),
                        ),
                      );
                      return;
                    }

                    if (id == 'echo') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EchoInboxScreen(token: null),
                        ),
                      );
                      return;
                    }

                    if (id == 'kash') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KashAgentScreen(),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AgentChatPage(agent: agent),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: agent.agentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            agent.agentIllustration,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.smart_toy, color: agent.agentColor, size: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
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
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  onSelected: (v) {
                                    if (v == "rename") {
                                      _showRenameDialog(context, agent, isDark);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: "rename",
                                      child: Text("Rename"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: agent.agentColor.withOpacity(0.12),
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
                                  _fmtEnergy(agent.energy),
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

                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  BoxDecoration _headerCardDecoration(bool isDark) {
    return BoxDecoration(
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
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static String _fmtEnergy(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }

  Future<void> _showEnergyTopupSheet(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final currentBalance = userProvider.energyBalance;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(sheetCtx).viewInsets.bottom,
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
                'Solde actuel : ${_fmtEnergy(currentBalance)} ⚡',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              _TopupOptionTile(
                leading: const Text('⚡', style: TextStyle(fontSize: 18)),
                title: 'Pack Éco (100 crédits)',
                priceLabel: r'$10',
                accent: _volt,
                onTap: () => _handleTopup(
                  rootContext: context,
                  sheetContext: sheetCtx,
                  packId: 'energy_eco',
                ),
              ),
              const SizedBox(height: 12),
              _TopupOptionTile(
                leading: const Text('⚡⚡', style: TextStyle(fontSize: 18)),
                title: 'Pack Boost (500 crédits)',
                priceLabel: r'$35',
                accent: _volt,
                onTap: () => _handleTopup(
                  rootContext: context,
                  sheetContext: sheetCtx,
                  packId: 'energy_boost',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleTopup({
    required BuildContext rootContext,
    required BuildContext sheetContext,
    required String packId,
  }) async {
    // 1) Close bottom sheet first
    Navigator.pop(sheetContext);

    try {
      final success = await StripeService.makePayment(packId: packId);
      if (!rootContext.mounted) return;

      if (success) {
        await rootContext.read<UserProvider>().refreshUser();
        if (!rootContext.mounted) return;

        ScaffoldMessenger.of(rootContext).showSnackBar(
          const SnackBar(
            content: Text('Énergie créditée !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showSubscriptionPlanSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(sheetCtx).viewInsets.bottom,
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
                'Mettre à jour mon offre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _SubscriptionOptionTile(
                leading: const Text('🏆', style: TextStyle(fontSize: 18)),
                title: 'Basic Plan',
                priceLabel: r'$59/mois',
                description: '3 Agents IA inclus',
                accent: _volt,
                isHighlighted: false,
                onTap: () => _handleSubscriptionChange(
                  rootContext: context,
                  sheetContext: sheetCtx,
                  packId: 'basic_plan',
                ),
              ),
              const SizedBox(height: 12),
              _SubscriptionOptionTile(
                leading: const Text('👑', style: TextStyle(fontSize: 18)),
                title: 'Premium Plan',
                priceLabel: r'$99/mois',
                description: 'Agents IA illimités (5)',
                accent: _volt,
                isHighlighted: true,
                onTap: () => _handleSubscriptionChange(
                  rootContext: context,
                  sheetContext: sheetCtx,
                  packId: 'premium_plan',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubscriptionChange({
    required BuildContext rootContext,
    required BuildContext sheetContext,
    required String packId,
  }) async {
    Navigator.pop(sheetContext);

    try {
      final success = await StripeService.makePayment(packId: packId);
      if (!rootContext.mounted) return;

      if (success) {
        await rootContext.read<UserProvider>().refreshUser();
        if (!rootContext.mounted) return;

        ScaffoldMessenger.of(rootContext).showSnackBar(
          const SnackBar(
            content: Text('Abonnement mis à jour !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SubscriptionOptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String priceLabel;
  final String description;
  final Color accent;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _SubscriptionOptionTile({
    required this.leading,
    required this.title,
    required this.priceLabel,
    required this.description,
    required this.accent,
    required this.isHighlighted,
    required this.onTap,
  });

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
            border: Border.all(
              color: isHighlighted
                  ? accent.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.08),
              width: isHighlighted ? 1.0 : 1.0,
            ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          priceLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopupOptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String priceLabel;
  final Color accent;
  final VoidCallback onTap;

  const _TopupOptionTile({
    required this.leading,
    required this.title,
    required this.priceLabel,
    required this.accent,
    required this.onTap,
  });

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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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