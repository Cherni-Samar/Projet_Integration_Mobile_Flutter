import 'package:e_team/presentation/widgets/common/app_loading.dart';
import 'package:flutter/material.dart';

import 'package:e_team/domain/models/hera/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_shared_widgets.dart';

class HeraTeamSubTabs extends StatelessWidget {
  final int selectedIndex;
  final int activeCount;
  final int onboardingCount;
  final int candidateCount;
  final void Function(int index) onChanged;

  const HeraTeamSubTabs({
    super.key,
    required this.selectedIndex,
    required this.activeCount,
    required this.onboardingCount,
    required this.candidateCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              child: HeraTeamSubTabPill(
                label: 'Équipe',
                count: activeCount,
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            Expanded(
              child: HeraTeamSubTabPill(
                label: 'Nouveaux',
                count: onboardingCount,
                selected: selectedIndex == 1,
                onTap: () => onChanged(1),
              ),
            ),
            Expanded(
              child: HeraTeamSubTabPill(
                label: 'Candidats',
                count: candidateCount,
                selected: selectedIndex == 2,
                onTap: () => onChanged(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeraTeamSubTabPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const HeraTeamSubTabPill({
    super.key,
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
                      ? Colors.white.withValues(alpha: 0.2)
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

class HeraTeamContent extends StatelessWidget {
  final bool loading;
  final int selectedIndex;
  final List<HeraEmployee> activeEmployees;
  final List<HeraEmployee> onboardingEmployees;
  final List<HeraCandidate> candidates;
  final Future<void> Function() onRefresh;
  final void Function(HeraEmployee employee) onEmployeeTap;

  const HeraTeamContent({
    super.key,
    required this.loading,
    required this.selectedIndex,
    required this.activeEmployees,
    required this.onboardingEmployees,
    required this.candidates,
    required this.onRefresh,
    required this.onEmployeeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: HeraPalette.mauve,
        child: loading
            ? const Center(child: AppLoadingIndicator(color: HeraPalette.mauve))
            : selectedIndex == 0
            ? HeraActiveEmployeeList(
                employees: activeEmployees,
                onEmployeeTap: onEmployeeTap,
              )
            : selectedIndex == 1
            ? HeraOnboardingEmployeeList(employees: onboardingEmployees)
            : HeraCandidateList(candidates: candidates),
      ),
    );
  }
}

class HeraActiveEmployeeList extends StatelessWidget {
  final List<HeraEmployee> employees;
  final void Function(HeraEmployee) onEmployeeTap;

  const HeraActiveEmployeeList({
    super.key,
    required this.employees,
    required this.onEmployeeTap,
  });

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
      itemBuilder: (_, index) => GestureDetector(
        onTap: () => onEmployeeTap(employees[index]),
        child: HeraActiveCard(employee: employees[index]),
      ),
    );
  }
}

class HeraOnboardingEmployeeList extends StatelessWidget {
  final List<HeraEmployee> employees;

  const HeraOnboardingEmployeeList({super.key, required this.employees});

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
      itemBuilder: (_, index) => HeraOnboardingCard(employee: employees[index]),
    );
  }
}

class HeraCandidateList extends StatelessWidget {
  final List<HeraCandidate> candidates;

  const HeraCandidateList({super.key, required this.candidates});

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
      itemBuilder: (_, index) {
        final candidate = candidates[index];
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
                backgroundColor: HeraPalette.mauve.withValues(alpha: 0.1),
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
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
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
