import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_team/data/services/agent_metadata_service.dart';
import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/l10n/app_localizations.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/presentation/screens/hera/hera_dashboard_page.dart';
import 'package:e_team/presentation/utils/domain_model_color_extensions.dart';
import 'package:e_team/presentation/widgets/agent/agent_energy_pack_sheet.dart';
import 'package:e_team/presentation/widgets/agent/details/agent_details_dialogs.dart';
import 'package:e_team/presentation/widgets/agent/details/agent_details_scaffold.dart';
import 'package:e_team/presentation/widgets/common/app_snack_bar.dart';

class AgentDetailsPage extends StatefulWidget {
  // ✅ Legacy single agent (optionnel)
  final String? title;
  final Color? color;
  final String? illustration;
  final List<String>? description;
  final String? timesSaved;
  final String? price;

  // ✅ Swipe mode
  final List<Map<String, dynamic>>? agents;
  final int initialIndex;

  const AgentDetailsPage({
    super.key,

    // legacy
    this.title,
    this.color,
    this.illustration,
    this.description,
    this.timesSaved,
    this.price,

    // swipe
    this.agents,
    this.initialIndex = 0,
  });

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final PageController _pageController;
  late int _currentIndex;

  bool get _isSwipeMode => widget.agents != null && widget.agents!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      _isSwipeMode ? widget.agents!.length - 1 : 0,
    );
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double _pageValue() {
    if (!_pageController.hasClients) return _currentIndex.toDouble();
    return _pageController.page ?? _currentIndex.toDouble();
  }

  // ---------------------------
  // Agent resolving helpers
  // ---------------------------
  Map<String, dynamic> _agentAt(int index) {
    if (_isSwipeMode) return widget.agents![index];
    return {
      'name': widget.title ?? '',
      'color': widget.color ?? Colors.black,
      'icon': widget.illustration ?? '',
      'description': (widget.description ?? <String>[]).join('\n\n'),
      'stats': {'response': widget.timesSaved ?? ''},
      'price': widget.price ?? '',
    };
  }

  String _agentName(Map<String, dynamic> agent) =>
      (agent['name'] ?? '').toString();

  Color _agentColor(Map<String, dynamic> agent) =>
      colorFromValue(agent['color'], fallback: Colors.black);

  String _agentIcon(Map<String, dynamic> agent) =>
      (agent['icon'] ?? '').toString();

  List<String> _agentDescriptionLines(Map<String, dynamic> agent) {
    final desc = agent['description'];
    if (desc is List<String>) return desc;
    if (desc is String) return [desc];
    return widget.description ?? <String>[];
  }

  // ---------------------------
  // Skills
  // ---------------------------
  List<String> _getSkillsForAgent(AppLocalizations l10n, String agentName) {
    return AgentMetadataService.getSkillsForAgent(l10n, agentName);
  }

  // ---------------------------
  // Energy Costs
  // ---------------------------
  List<Map<String, dynamic>> _getEnergyCostsForAgent(String agentName) {
    return AgentMetadataService.getEnergyCostsForAgent(agentName);
  }

  List<Map<String, dynamic>> _getMultiAgentScenarios(String agentName) {
    return AgentMetadataService.getMultiAgentScenarios(agentName);
  }

  List<Map<String, dynamic>> _getEnergyPacksForAgent(String agentName) {
    return AgentMetadataService.getEnergyPacksForAgent(agentName);
  }

  String _getVersionForAgent(AppLocalizations l10n, String agentName) {
    return AgentMetadataService.getVersionForAgent(l10n, agentName);
  }

  // ---------------------------
  // Build
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (!_isSwipeMode) {
      return _buildAgentDetailsScaffold(
        context: context,
        l10n: l10n,
        isDark: isDark,
        agent: _agentAt(0),
        swipeDiff: 0.0,
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: widget.agents!.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (i) => setState(() => _currentIndex = i),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, _) {
            final page = _pageValue();
            final diff = index - page;
            return _buildAgentDetailsScaffold(
              context: context,
              l10n: l10n,
              isDark: isDark,
              agent: _agentAt(index),
              swipeDiff: diff,
            );
          },
        );
      },
    );
  }

  Widget _buildAgentDetailsScaffold({
    required BuildContext context,
    required AppLocalizations l10n,
    required bool isDark,
    required Map<String, dynamic> agent,
    required double swipeDiff,
  }) {
    final name = _agentName(agent);
    final color = _agentColor(agent);
    final icon = _agentIcon(agent);

    final userProvider = context.watch<UserProvider>();
    final agentId = name.trim().toLowerCase();
    final isActive = userProvider.isAgentActive(agentId);
    final energyCosts = _getEnergyCostsForAgent(name);
    final multiScenarios = _getMultiAgentScenarios(name);
    final skills = _getSkillsForAgent(l10n, name);

    return AgentDetailsScaffold(
      l10n: l10n,
      isDark: isDark,
      isSwipeMode: _isSwipeMode,
      swipeItemCount: widget.agents?.length ?? 0,
      currentIndex: _currentIndex,
      pageController: _pageController,
      pulseController: _animationController,
      agentName: name,
      agentColor: color,
      agentIcon: icon,
      description: _agentDescriptionLines(agent).join('\n\n'),
      version: _getVersionForAgent(l10n, name),
      isActive: isActive,
      swipeDiff: swipeDiff,
      skills: skills,
      energyCosts: energyCosts,
      multiScenarios: multiScenarios,
      onBackPressed: () => Navigator.pop(context),
      onCartPressed: () => Navigator.pushNamed(context, '/cart'),
      onSharePressed: () => _showShareSnackBar(context, l10n, isDark, name),
      onPrimaryActionPressed: () => _handlePrimaryAction(
        context: context,
        isDark: isDark,
        name: name,
        color: color,
        icon: icon,
        isActive: isActive,
      ),
    );
  }

  void _showShareSnackBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    String name,
  ) {
    AppSnackBar.info(context, l10n.agentDetailsShareSnack(name));
  }

  void _handlePrimaryAction({
    required BuildContext context,
    required bool isDark,
    required String name,
    required Color color,
    required String icon,
    required bool isActive,
  }) {
    final isHera = name.trim().toLowerCase() == 'hera';
    final canOpenDashboard = isHera && isActive;

    if (canOpenDashboard) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HeraDashboardPage()),
      );
      return;
    }

    _handleHireAgent(context, isDark, name, color, icon);
  }

  // ---------------------------
  // ✅ NOUVELLE méthode — Handle Hire Agent
  // ---------------------------
  Future<void> _handleHireAgent(
    BuildContext context,
    bool isDark,
    String name,
    Color color,
    String icon,
  ) async {
    if (name == 'Hera') {
      // 1. Loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AgentConnectionDialog(isDark: isDark),
      );

      try {
        // 2. Appelle N8N
        await HeraService.hello(username: 'Samar');

        if (!context.mounted) return;

        // 3. Ferme loading
        Navigator.pop(context);

        // 4. ✅ Navigate vers HeraDashboardPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HeraDashboardPage()),
        );
      } catch (e) {
        if (!context.mounted) return;

        // Ferme loading
        Navigator.pop(context);

        AppSnackBar.show(
          context,
          'Hera indisponible. Lance N8N sur le port 5678.',
          type: AppSnackBarType.error,
          duration: const Duration(seconds: 4),
        );
      }
      return;
    }

    // ✅ Autres agents → Energy pack sheet (inchangé)
    _showEnergyPackSheet(context, isDark, name, color, icon);
  }

  // ---------------------------
  // Energy Pack Sheet (inchangé)
  // ---------------------------
  void _showEnergyPackSheet(
    BuildContext ctx,
    bool isDark,
    String agentName,
    Color agentColor,
    String agentIcon,
  ) {
    final packs = _getEnergyPacksForAgent(agentName);
    showAgentEnergyPackSheet(
      context: ctx,
      agentName: agentName,
      agentColor: agentColor,
      agentIcon: agentIcon,
      isDark: isDark,
      energyPacks: packs,
    );
  }
}
