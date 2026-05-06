import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:e_team/presentation/providers/user_provider.dart';
import 'package:e_team/data/services/dexo_service.dart';

class DexoOrganizationPulseScreen extends StatefulWidget {
  const DexoOrganizationPulseScreen({super.key});

  @override
  State<DexoOrganizationPulseScreen> createState() =>
      _DexoOrganizationPulseScreenState();
}

class _DexoOrganizationPulseScreenState
    extends State<DexoOrganizationPulseScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Timer? _debounce;

  List<_DepartmentPulse> _departments = [];

  static const Color _volt = Color(0xFFCDFF00);
  static const Color _dark = Color(0xFF0A0A0A);
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF64748B);
  static const Color _green = Color(0xFF22C55E);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _red = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUser();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadFromUser() async {
    setState(() => _isLoading = true);

    await context.read<UserProvider>().refreshFromApi();

    if (!mounted) return;

    final user = context.read<UserProvider>().user;

    final settings = user?.workforceSettings ?? [];

    setState(() {
      _departments = settings
          .map(
            (s) => _DepartmentPulse(
              name: s.department,
              targetCount: s.targetCount,
              currentCount: s.currentCount,
            ),
          )
          .toList();

      _isLoading = false;
    });
  }

  void _updateTarget(_DepartmentPulse department, double value) {
    setState(() {
      department.targetCount = value.round().clamp(0, 99);
    });

    _scheduleAutoSave();
  }

  void _scheduleAutoSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 900), _saveVisionAuto);
  }

  Future<void> _saveVisionAuto() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final response = await DexoService.updateWorkforceSettings({
        'workforceSettings': _departments.map((d) {
          return {
            'department': d.name,
            'targetCount': d.targetCount,
            'currentCount': d.currentCount,
          };
        }).toList(),
      });

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Save failed');
      }

      await context.read<UserProvider>().refreshFromApi();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  int get _totalTarget => _departments.fold(0, (sum, d) => sum + d.targetCount);

  int get _totalCurrent =>
      _departments.fold(0, (sum, d) => sum + d.currentCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _dark))
                  : RefreshIndicator(
                      color: _dark,
                      onRefresh: _loadFromUser,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        children: [
                          _buildPulseHero(),
                          const SizedBox(height: 22),
                          _sectionTitle('DEPARTMENT TARGETS'),
                          const SizedBox(height: 12),
                          if (_departments.isEmpty)
                            _emptyState()
                          else
                            ..._departments.map(_departmentCard),
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
          Expanded(
            child: Text(
              'Organization Pulse',
              style: GoogleFonts.plusJakartaSans(
                color: _dark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isSaving
                ? Text(
                    'Saving...',
                    key: const ValueKey('saving'),
                    style: GoogleFonts.plusJakartaSans(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Text(
                    'Auto-saved',
                    key: const ValueKey('saved'),
                    style: GoogleFonts.plusJakartaSans(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseHero() {
    final gap = (_totalTarget - _totalCurrent).clamp(0, 999);
    final progress = _totalTarget == 0
        ? 0.0
        : (_totalCurrent / _totalTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _volt,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: _dark,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_totalCurrent / $_totalTarget workforce",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      gap == 0
                          ? "Your organization matches the current vision."
                          : "Dexo recommends $gap additional hire(s).",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(_volt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentCard(_DepartmentPulse department) {
    final gap = (department.targetCount - department.currentCount).clamp(0, 99);
    final ratio = department.targetCount == 0
        ? 1.0
        : (department.currentCount / department.targetCount).clamp(0.0, 1.0);

    final statusColor = _statusColor(ratio);
    final statusText = _statusText(ratio, gap);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.028),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _iconForDepartment(department.name),
                  color: _dark,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: _dark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${department.currentCount} current / ${department.targetCount} target',
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: _dark,
              inactiveTrackColor: _border,
              thumbColor: _volt,
              overlayColor: _volt.withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              min: 0,
              max: 30,
              divisions: 30,
              value: department.targetCount.clamp(0, 30).toDouble(),
              onChanged: (v) => _updateTarget(department, v),
            ),
          ),
          Row(
            children: [
              Text(
                '0',
                style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 10),
              ),
              const Spacer(),
              Text(
                'Drag to tune vision',
                style: GoogleFonts.plusJakartaSans(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '30',
                style: GoogleFonts.plusJakartaSans(color: _muted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              gap == 0
                  ? 'Dexo Insight: this department is balanced.'
                  : 'Dexo Insight: ${department.name} needs +$gap hire(s).',
              style: GoogleFonts.plusJakartaSans(
                color: _muted,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(double ratio) {
    if (ratio >= 1) return _green;
    if (ratio >= 0.5) return _orange;
    return _red;
  }

  String _statusText(double ratio, int gap) {
    if (ratio >= 1) return 'BALANCED';
    if (gap >= 5) return 'CRITICAL';
    return 'UNDERSTAFFED';
  }

  IconData _iconForDepartment(String name) {
    final n = name.toLowerCase();

    if (n.contains('tech') || n.contains('software') || n.contains('it')) {
      return Icons.code_rounded;
    }
    if (n.contains('design') || n.contains('ux') || n.contains('brand')) {
      return Icons.palette_rounded;
    }
    if (n.contains('marketing') ||
        n.contains('growth') ||
        n.contains('sales')) {
      return Icons.campaign_rounded;
    }
    if (n.contains('finance') ||
        n.contains('accounting') ||
        n.contains('budget')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (n.contains('operation') || n.contains('logistic')) {
      return Icons.settings_suggest_rounded;
    }
    if (n.contains('support') ||
        n.contains('client') ||
        n.contains('customer')) {
      return Icons.support_agent_rounded;
    }
    if (n.contains('rh') || n.contains('hr') || n.contains('human')) {
      return Icons.groups_rounded;
    }
    if (n.contains('admin')) {
      return Icons.admin_panel_settings_rounded;
    }

    return Icons.business_center_rounded;
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_tree_rounded, size: 44, color: _muted),
          const SizedBox(height: 12),
          Text(
            'No organization vision yet',
            style: GoogleFonts.plusJakartaSans(
              color: _dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete Dexo onboarding to generate your company departments.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _dark, size: 18),
      ),
    );
  }
}

class _DepartmentPulse {
  final String name;
  int targetCount;
  final int currentCount;

  _DepartmentPulse({
    required this.name,
    required this.targetCount,
    required this.currentCount,
  });
}
