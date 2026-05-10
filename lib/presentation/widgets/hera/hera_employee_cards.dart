import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:e_team/domain/models/hera/hera_models.dart';
import 'package:e_team/presentation/widgets/hera/hera_common_widgets.dart';
import 'package:e_team/presentation/widgets/hera/hera_palette.dart';

class HeraActiveCard extends StatelessWidget {
  final HeraEmployee employee;

  const HeraActiveCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    String getBalance(String type) {
      final data = employee.balances[type];
      if (data is! Map) return '0/0';
      return '${data['remaining'] ?? 0}/${data['total'] ?? 0}';
    }

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
            backgroundColor: HeraPalette.mauve.withValues(alpha: 0.15),
            child: Text(
              employee.name.isNotEmpty ? employee.name[0] : '?',
              style: const TextStyle(
                color: HeraPalette.mauve,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    color: HeraPalette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  employee.role.isEmpty ? 'Employé' : employee.role,
                  style: const TextStyle(
                    color: HeraPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniBadge(
                      icon: Icons.beach_access,
                      value: getBalance('annual'),
                    ),
                    const SizedBox(width: 6),
                    _MiniBadge(
                      icon: Icons.medical_services,
                      value: getBalance('sick'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: HeraPalette.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniBadge({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HeraPalette.cardSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: HeraPalette.textMuted),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: HeraPalette.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HeraOnboardingCard extends StatelessWidget {
  final HeraEmployee employee;

  const HeraOnboardingCard({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    String? rawDate;
    final contract = employee.contract;
    if (contract != null) rawDate = contract['start']?.toString();

    String dateText = 'Date non définie';
    String countdown = '';

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final start = DateTime.parse(rawDate);
        dateText = DateFormat('d MMMM yyyy', 'fr_FR').format(start);
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final diff = start.difference(today).inDays;
        if (diff == 0) {
          countdown = 'Arrive aujourd\'hui';
        } else if (diff == 1) {
          countdown = 'Arrive demain';
        } else if (diff > 0) {
          countdown = 'Dans $diff jours';
        } else {
          countdown = 'Arrivé';
        }
      } catch (_) {
        dateText = 'Format date invalide';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HeraPalette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HeraPalette.mauve.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: HeraPalette.mauve.withValues(alpha: 0.1),
                child: Text(
                  employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: HeraPalette.mauve,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${employee.role} · ${employee.department}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const HeraBadge(label: 'NOUVEAU', color: HeraPalette.mauve),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date de début prévue',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (countdown.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HeraPalette.mauve.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      countdown,
                      style: const TextStyle(
                        color: HeraPalette.mauve,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
