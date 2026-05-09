import 'package:flutter/material.dart';

import 'package:e_team/data/services/hera_service.dart';
import 'package:e_team/presentation/widgets/dexo/dashboard/dexo_dashboard_widgets.dart';
import 'dexo_production_screen.dart';
import 'dexo_organization_pulse_screen.dart';

class DexoDashboardPage extends StatefulWidget {
  final String? token;

  const DexoDashboardPage({super.key, this.token});

  @override
  State<DexoDashboardPage> createState() => _DexoDashboardPageState();
}

class _DexoDashboardPageState extends State<DexoDashboardPage> {
  bool _isLoading = true;
  bool _isAiThinking = true;
  String _dailyReport = '';

  @override
  void initState() {
    super.initState();
    _loadBriefing();
  }

  Future<void> _loadBriefing() async {
    setState(() {
      _isLoading = true;
      _isAiThinking = true;
    });

    try {
      final result = await HeraService.getDexoCheckup();

      if (!mounted) return;

      setState(() {
        _dailyReport =
            result['report'] ?? 'No strategic briefing available yet.';
        _isLoading = false;
        _isAiThinking = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _dailyReport = 'Dexo could not load the executive briefing.';
        _isLoading = false;
        _isAiThinking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DexoDashboardColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            DexoDashboardHeader(onBackPressed: () => Navigator.pop(context)),
            Expanded(
              child: DexoDashboardList(
                isLoading: _isLoading,
                isAiThinking: _isAiThinking,
                dailyReport: _dailyReport,
                onRefresh: _loadBriefing,
                onRefreshBriefing: _loadBriefing,
                onOrganizationPulsePressed: () =>
                    _pushPage(const DexoOrganizationPulseScreen()),
                onProductionHubPressed: () =>
                    _pushPage(const DexoProductionScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pushPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
