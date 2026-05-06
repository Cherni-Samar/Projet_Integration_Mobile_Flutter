import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:e_team/data/services/hera_service.dart';
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

  static const Color _dexoBlue = Color(0xFF2563EB);
  static const Color _dexoBlueDark = Color(0xFF1E40AF);
  static const Color _dark = Color(0xFF0A0A0A);
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _blueSurface = Color(0xFFEFF6FF);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF64748B);
  static const Color _green = Color(0xFF22C55E);

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
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: _dexoBlue,
                onRefresh: _loadBriefing,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
                  children: [
                    _buildBrainCard(),
                    const SizedBox(height: 18),
                    _buildExecutiveBriefingCard(),
                    const SizedBox(height: 26),
                    _sectionTitle('DEXO COMMAND CENTER'),
                    const SizedBox(height: 12),
                    _menuCard(
                      context,
                      title: 'Organization Pulse',
                      subtitle:
                          'Adjust workforce targets and detect staffing gaps.',
                      icon: Icons.account_tree_rounded,
                      isPrimary: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DexoOrganizationPulseScreen(),
                          ),
                        );
                      },
                    ),
                    _menuCard(
                      context,
                      title: 'Production Hub',
                      subtitle:
                          'Documents, generated outputs and execution logs.',
                      icon: Icons.factory_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DexoProductionScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          _roundButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _blueSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _dexoBlue.withValues(alpha: 0.18)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/dexo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.psychology_rounded,
                  color: _dexoBlue,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEXO BRAIN',
                  style: GoogleFonts.plusJakartaSans(
                    color: _dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'STRATEGIC SUPERVISION ACTIVE',
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrainCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_dexoBlue, _dexoBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _dexoBlue.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Strategic layer online",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Dexo monitors your organization, detects workforce drift and supervises execution.",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveBriefingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _blueSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: _dexoBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Executive Briefing',
                  style: GoogleFonts.plusJakartaSans(
                    color: _dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadBriefing,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: _dexoBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading || _isAiThinking)
            const LinearProgressIndicator(color: _dexoBlue)
          else
            Text(
              _dailyReport.replaceAll('*', '').trim(),
              style: GoogleFonts.plusJakartaSans(
                color: _muted,
                fontSize: 13,
                height: 1.65,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isPrimary ? _blueSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isPrimary ? _dexoBlue : _border,
                width: isPrimary ? 1.4 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPrimary ? _dexoBlue : Colors.black).withValues(
                    alpha: isPrimary ? 0.08 : 0.035,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPrimary ? _dexoBlue : _surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : _dark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: _dark,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: _muted,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isPrimary ? _dexoBlue : _dark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: _dark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: _dark, size: 18),
      ),
    );
  }
}
