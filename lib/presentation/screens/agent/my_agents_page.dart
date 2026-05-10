import 'package:e_team/data/services/stripe_service.dart';
import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/screens/agent/agent_chat_page.dart';
import 'package:e_team/presentation/screens/agent/dexo/dexo_dashboard_page.dart';
import 'package:e_team/presentation/screens/agent/echo/echo_dashboard_page.dart';
import 'package:e_team/presentation/screens/agent/kash/kash_dashboard_screen.dart';
import 'package:e_team/presentation/screens/agent/timo/timo_dashboard_page.dart';
import 'package:e_team/presentation/screens/hera/hera_dashboard_page.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_list.dart';
import 'package:e_team/presentation/widgets/agent/my_agents/my_agents_sheets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAgentsPage extends StatelessWidget {
  const MyAgentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final activeAgents = userProvider.user?.activeAgents ?? const <String>[];
    final owned = context.watch<OwnedAgentsProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      owned.syncFromActiveAgents(activeAgents);
      owned.refreshEnergy();
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFFAFAFA),
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
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: activeAgents.isEmpty
          ? MyAgentsEmptyState(
              isDark: isDark,
              onGoToMarketplace: () => Navigator.pop(context),
            )
          : MyAgentsList(
              owned: owned,
              isDark: isDark,
              energyBalance: userProvider.energyBalance,
              activeCount: owned.count,
              onTopup: () => _showEnergyTopupSheet(context),
              onOpenAgent: (agent) => _openAgent(context, agent),
              onRenameAgent: (agent) {
                _showRenameDialog(context, agent, isDark);
              },
            ),
    );
  }

  String _agentId(String name) => name.trim().toLowerCase();

  void _openAgent(BuildContext context, OwnedAgent agent) {
    final id = _agentId(agent.agentName);

    if (id == 'hera') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HeraDashboardPage()),
      );
      return;
    }

    if (id == 'echo') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EchoDashboardPage(token: null)),
      );
      return;
    }

    if (id == 'dexo') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DexoDashboardPage()),
      );
      return;
    }

    if (id == 'kash') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KashDashboardScreen()),
      );
      return;
    }

    if (id == 'timo') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TimoDashboardPage()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentChatPage(agent: agent)),
    );
  }

  void _showRenameDialog(BuildContext context, OwnedAgent agent, bool isDark) {
    final controller = TextEditingController(text: agent.displayName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return RenameAgentDialog(
          agent: agent,
          isDark: isDark,
          controller: controller,
          onSave: () {
            final owned = context.read<OwnedAgentsProvider>();
            owned.renameAgent(agent.agentName, controller.text);
            Navigator.pop(dialogContext);
            _showRenamedSnackBar(context, agent, controller.text, isDark);
          },
        );
      },
    );
  }

  void _showRenamedSnackBar(
    BuildContext context,
    OwnedAgent agent,
    String name,
    bool isDark,
  ) {
    final displayName = name.trim().isEmpty ? agent.agentName : name.trim();

    AppSnackBar.info(context, 'Renamed to "$displayName"');
  }

  Future<void> _showEnergyTopupSheet(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final currentBalance = userProvider.energyBalance;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return EnergyTopupSheet(
          currentBalance: currentBalance,
          onSelectPack: (packId) => _handleTopup(
            rootContext: context,
            sheetContext: sheetContext,
            packId: packId,
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
    Navigator.pop(sheetContext);

    try {
      final success = await StripeService.makePayment(
        packId: packId,
        suggestedAgents: null,
      );
      if (!rootContext.mounted) return;

      if (success != null) {
        AppSnackBar.success(rootContext, 'Énergie créditée !');

        Navigator.pushReplacement(
          rootContext,
          MaterialPageRoute(builder: (_) => const MyAgentsPage()),
        );
      }
    } catch (e) {
      if (!rootContext.mounted) return;
      AppSnackBar.error(
        rootContext,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}
