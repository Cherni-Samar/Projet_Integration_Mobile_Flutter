import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/team/hera_team_widgets.dart';

/// Team tab — active employees, onboarding, and candidates.
/// All state and API calls live in [_HeraDashboardPageState].
class HeraTeamTab extends StatelessWidget {
  final List<HeraEmployee> employees;
  final List<HeraCandidate> candidates;
  final bool loadingEmployees;
  final int employeeSubTab;
  final Future<void> Function() onRefresh;
  final void Function(int index) onSubTabChanged;
  final void Function(HeraEmployee emp) onEmployeeTap;

  const HeraTeamTab({
    super.key,
    required this.employees,
    required this.candidates,
    required this.loadingEmployees,
    required this.employeeSubTab,
    required this.onRefresh,
    required this.onSubTabChanged,
    required this.onEmployeeTap,
  });

  List<HeraEmployee> get _active => employees
      .where((e) => e.status == 'active' || e.status == 'offboarding')
      .toList();

  List<HeraEmployee> get _onboarding =>
      employees.where((e) => e.status == 'onboarding').toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeraTeamSubTabs(
          selectedIndex: employeeSubTab,
          activeCount: _active.length,
          onboardingCount: _onboarding.length,
          candidateCount: candidates.length,
          onChanged: onSubTabChanged,
        ),
        HeraTeamContent(
          loading: loadingEmployees,
          selectedIndex: employeeSubTab,
          activeEmployees: _active,
          onboardingEmployees: _onboarding,
          candidates: candidates,
          onRefresh: onRefresh,
          onEmployeeTap: onEmployeeTap,
        ),
      ],
    );
  }
}
