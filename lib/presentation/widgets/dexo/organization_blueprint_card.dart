import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_team/domain/models/dexo/dexo_onboarding_models.dart';

class OrganizationBlueprintCard extends StatefulWidget {
  final WorkforcePlan initialPlan;
  final Future<void> Function(WorkforcePlan plan) onConfirm;

  const OrganizationBlueprintCard({
    super.key,
    required this.initialPlan,
    required this.onConfirm,
  });

  @override
  State<OrganizationBlueprintCard> createState() =>
      _OrganizationBlueprintCardState();
}

class _OrganizationBlueprintCardState extends State<OrganizationBlueprintCard> {
  late WorkforcePlan _plan;
  bool _isSaving = false;

  static const Color _primary = Color(0xFFCDFF00);
  static const Color _dark = Color(0xFF0A0A0A);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();

    _plan = WorkforcePlan(
      departments: widget.initialPlan.departments
          .map(
            (d) => WorkforceDepartment(
              name: d.name,
              targetCount: d.targetCount,
              reason: d.reason,
            ),
          )
          .toList(),
      explanation: widget.initialPlan.explanation,
      recommendedAgents: widget.initialPlan.recommendedAgents,
    );
  }

  int get _total => _plan.departments.fold(0, (sum, d) => sum + d.targetCount);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.92,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const SizedBox(height: 14),
          Text(
            _plan.explanation,
            style: GoogleFonts.plusJakartaSans(
              color: _textMuted,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ..._plan.departments.map(
            (dept) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildRow(
                icon: _iconForDepartment(dept.name),
                label: dept.name,
                subtitle: dept.reason.isNotEmpty
                    ? dept.reason
                    : 'Required function for this company',
                value: dept.targetCount,
                onMinus: () => _changeDepartment(dept, -1),
                onPlus: () => _changeDepartment(dept, 1),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildTotalBox(),
          if (_plan.recommendedAgents.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAgentsSection(),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      await widget.onConfirm(_plan);
                      if (mounted) setState(() => _isSaving = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _dark,
                disabledBackgroundColor: _dark.withValues(alpha: 0.45),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _primary,
                      ),
                    )
                  : Text(
                      'ACTIVATE ORGANIZATION VISION',
                      style: GoogleFonts.plusJakartaSans(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.account_tree_rounded, color: _dark, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORGANIZATION BLUEPRINT',
                style: GoogleFonts.plusJakartaSans(
                  color: _dark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adjust Dexo\u2019s dynamic company structure.',
                style: GoogleFonts.plusJakartaSans(
                  color: _textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _dark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _counterButton(Icons.remove_rounded, onMinus),
          SizedBox(
            width: 38,
            child: Center(
              child: Text(
                '$value',
                style: GoogleFonts.plusJakartaSans(
                  color: _textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          _counterButton(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }

  Widget _buildTotalBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: _primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Total recommended workforce',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$_total',
            style: GoogleFonts.plusJakartaSans(
              color: _primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECOMMENDED AI AGENTS',
          style: GoogleFonts.plusJakartaSans(
            color: _dark,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ..._plan.recommendedAgents.map(
          (agent) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 0.6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: _dark, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name.isNotEmpty ? agent.name : agent.id,
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        agent.reason,
                        style: GoogleFonts.plusJakartaSans(
                          color: _textMuted,
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border, width: 0.6),
        ),
        child: Icon(icon, size: 18, color: _dark),
      ),
    );
  }

  IconData _iconForDepartment(String name) {
    final n = name.toLowerCase();

    if (n.contains('tech') || n.contains('software') || n.contains('it')) {
      return Icons.code_rounded;
    }
    if (n.contains('design') || n.contains('brand') || n.contains('ux')) {
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
    if (n.contains('legal') || n.contains('juridique')) {
      return Icons.gavel_rounded;
    }

    return Icons.business_center_rounded;
  }

  void _changeDepartment(WorkforceDepartment department, int delta) {
    setState(() {
      department.targetCount = (department.targetCount + delta).clamp(0, 99);
    });
  }
}
