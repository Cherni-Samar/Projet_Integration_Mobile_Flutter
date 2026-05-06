import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: HeraPalette.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: HeraPalette.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SubTabPill(
                    label: 'Équipe',
                    count: _active.length,
                    selected: employeeSubTab == 0,
                    onTap: () => onSubTabChanged(0),
                  ),
                ),
                Expanded(
                  child: _SubTabPill(
                    label: 'Nouveaux',
                    count: _onboarding.length,
                    selected: employeeSubTab == 1,
                    onTap: () => onSubTabChanged(1),
                  ),
                ),
                Expanded(
                  child: _SubTabPill(
                    label: 'Candidats',
                    count: candidates.length,
                    selected: employeeSubTab == 2,
                    onTap: () => onSubTabChanged(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: HeraPalette.mauve,
            child: loadingEmployees
                ? const Center(
                    child: CircularProgressIndicator(color: HeraPalette.mauve),
                  )
                : employeeSubTab == 0
                ? _ActiveList(employees: _active, onEmployeeTap: onEmployeeTap)
                : employeeSubTab == 1
                ? _OnboardingList(employees: _onboarding)
                : _CandidateList(candidates: candidates),
          ),
        ),
      ],
    );
  }
}

// ─── Private sub-tab pill ────────────────────────────────────────────────────

class _SubTabPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SubTabPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? HeraPalette.mauve : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : HeraPalette.textMuted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.2)
                      : HeraPalette.cardSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? Colors.white : HeraPalette.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Private list widgets ────────────────────────────────────────────────────

class _ActiveList extends StatelessWidget {
  final List<HeraEmployee> employees;
  final void Function(HeraEmployee) onEmployeeTap;

  const _ActiveList({required this.employees, required this.onEmployeeTap});

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const HeraEmptyState(
        icon: Icons.people_outline,
        title: 'Aucun employé actif',
        sub: 'Votre équipe est vide.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: employees.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => onEmployeeTap(employees[i]),
        child: HeraActiveCard(employee: employees[i]),
      ),
    );
  }
}

class _OnboardingList extends StatelessWidget {
  final List<HeraEmployee> employees;

  const _OnboardingList({required this.employees});

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const HeraEmptyState(
        icon: Icons.celebration,
        title: 'Aucun nouvel arrivant',
        sub: 'Tout le monde est déjà actif.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: employees.length,
      itemBuilder: (_, i) => HeraOnboardingCard(employee: employees[i]),
    );
  }
}

class _CandidateList extends StatelessWidget {
  final List<HeraCandidate> candidates;

  const _CandidateList({required this.candidates});

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const HeraEmptyState(
        icon: Icons.person_add_alt_1,
        title: 'Aucun candidat',
        sub: 'Hera attend des candidatures...',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: candidates.length,
      itemBuilder: (_, i) {
        final candidate = candidates[i];
        final score = candidate.scoreIa;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HeraPalette.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HeraPalette.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: HeraPalette.mauve.withOpacity(0.1),
                child: const Icon(
                  Icons.person_outline,
                  color: HeraPalette.mauve,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      candidate.department,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: score >= 80
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$score%',
                  style: TextStyle(
                    color: score >= 80 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
