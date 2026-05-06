import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:e_team/presentation/models/timo/timo_task_view_model.dart';
import 'package:e_team/presentation/widgets/timo/timo_design_system.dart';

class TimoHeader extends StatelessWidget {
  final AnimationController pulseController;
  final VoidCallback onBack;

  const TimoHeader({
    super.key,
    required this.pulseController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TimoDesignSystem.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TimoDesignSystem.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TimoDesignSystem.border, width: 0.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              color: TimoDesignSystem.textPrimary,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TimoDesignSystem.other, width: 2),
              boxShadow: [
                BoxShadow(
                  color: TimoDesignSystem.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/images/krono.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TimoDesignSystem.other.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.timer_rounded,
                      color: TimoDesignSystem.other,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIMO COMMAND CENTER',
                  style: GoogleFonts.plusJakartaSans(
                    color: TimoDesignSystem.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: TimoDesignSystem.neonGreen.withValues(
                              alpha: 0.4 + 0.6 * pulseController.value,
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SCHEDULING ENGINE ONLINE',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFF9800),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
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
}

class TimoNavigation extends StatelessWidget {
  final List<(IconData, String)> tabs;
  final int selected;
  final ValueChanged<int> onSelect;

  const TimoNavigation({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TimoDesignSystem.other, const Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.other.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = selected == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.$1,
                        color: Colors.white,
                        size: isSelected ? 20 : 18,
                      ),
                      const SizedBox(height: 4),
                      if (isSelected)
                        Text(
                          tab.$2,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Container(
                          height: 2,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TimoStatsCard extends StatelessWidget {
  final int interviews;
  final int onboardings;
  final int offboardings;
  final int done;
  final int total;

  const TimoStatsCard({
    super.key,
    required this.interviews,
    required this.onboardings,
    required this.offboardings,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TimoDesignSystem.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TimoStatItem(
                  value: '$interviews',
                  label: 'INTERVIEWS',
                  color: TimoDesignSystem.interview,
                  icon: Icons.record_voice_over_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: TimoDesignSystem.border),
              Expanded(
                child: TimoStatItem(
                  value: '$onboardings',
                  label: 'ONBOARDINGS',
                  color: TimoDesignSystem.onboarding,
                  icon: Icons.person_add_alt_1_rounded,
                ),
              ),
              Container(width: 1, height: 50, color: TimoDesignSystem.border),
              Expanded(
                child: TimoStatItem(
                  value: '$offboardings',
                  label: 'OFFBOARDINGS',
                  color: TimoDesignSystem.offboarding,
                  icon: Icons.exit_to_app_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Complétés',
                style: GoogleFonts.plusJakartaSans(
                  color: TimoDesignSystem.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total',
                style: GoogleFonts.plusJakartaSans(
                  color: pct > 0.7
                      ? TimoDesignSystem.success
                      : TimoDesignSystem.other,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: TimoDesignSystem.border,
              valueColor: AlwaysStoppedAnimation(
                pct > 0.7 ? TimoDesignSystem.success : TimoDesignSystem.other,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimoStatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const TimoStatItem({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: TimoDesignSystem.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: TimoDesignSystem.textMuted,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class TimoTaskCard extends StatelessWidget {
  final TimoTask task;

  const TimoTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TimoDesignSystem.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isDone
              ? TimoDesignSystem.success.withValues(alpha: 0.25)
              : task.color.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: TimoDesignSystem.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: task.isDone
                  ? TimoDesignSystem.success.withValues(alpha: 0.12)
                  : task.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              task.isDone ? Icons.task_alt_rounded : task.icon,
              color: task.isDone ? TimoDesignSystem.success : task.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.employeeName,
                  style: GoogleFonts.plusJakartaSans(
                    color: task.isDone
                        ? TimoDesignSystem.textMuted
                        : TimoDesignSystem.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    decorationColor: TimoDesignSystem.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                if (task.deadline != null)
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: TimoDesignSystem.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'dd MMM • HH:mm',
                          'fr_FR',
                        ).format(task.deadline!),
                        style: GoogleFonts.plusJakartaSans(
                          color: TimoDesignSystem.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.typeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: task.color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (task.isDone) ...[
                const SizedBox(height: 6),
                Icon(
                  Icons.verified_rounded,
                  color: TimoDesignSystem.success,
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class TimoLegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const TimoLegendChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class TimoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;

  const TimoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: TimoDesignSystem.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: TimoDesignSystem.border, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: TimoDesignSystem.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: TimoDesignSystem.other.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: TimoDesignSystem.other, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: TimoDesignSystem.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
