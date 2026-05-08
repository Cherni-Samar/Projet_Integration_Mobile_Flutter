import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DexoProductionTheme {
  const DexoProductionTheme._();

  static const dark = Color(0xFF0A0A0A);
  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);
  static const border = Color(0xFFE5E7EB);
  static const muted = Color(0xFF64748B);
  static const blue = Color(0xFF2563EB);
  static const green = Color(0xFF16A34A);
}

class DexoProductionHeader extends StatelessWidget {
  const DexoProductionHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          DexoProductionRoundButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Production Hub',
              style: GoogleFonts.plusJakartaSans(
                color: DexoProductionTheme.dark,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DexoProductionFilterBar extends StatelessWidget {
  const DexoProductionFilterBar({
    super.key,
    required this.selectedDocType,
    required this.selectedDateRange,
    required this.onSelectDocType,
    required this.onPickDate,
    required this.onClear,
  });

  final String selectedDocType;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String> onSelectDocType;
  final VoidCallback onPickDate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDateRange == null
        ? 'Date'
        : '${formatDexoProductionShortDate(selectedDateRange!.start)} -> ${formatDexoProductionShortDate(selectedDateRange!.end)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter outputs',
          style: GoogleFonts.plusJakartaSans(
            color: DexoProductionTheme.muted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DexoProductionFilterChip(
                label: 'All',
                selected: selectedDocType == 'all',
                onTap: () => onSelectDocType('all'),
              ),
              DexoProductionFilterChip(
                label: 'Attestation',
                selected: selectedDocType == 'attestation',
                onTap: () => onSelectDocType('attestation'),
              ),
              DexoProductionFilterChip(
                label: 'Bulletin',
                selected: selectedDocType == 'bulletin',
                onTap: () => onSelectDocType('bulletin'),
              ),
              DexoProductionFilterChip(
                label: dateLabel,
                icon: Icons.calendar_month_rounded,
                selected: selectedDateRange != null,
                onTap: onPickDate,
              ),
              if (selectedDateRange != null || selectedDocType != 'all')
                DexoProductionFilterChip(
                  label: 'Clear',
                  icon: Icons.close_rounded,
                  selected: false,
                  onTap: onClear,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DexoProductionFilterChip extends StatelessWidget {
  const DexoProductionFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? DexoProductionTheme.dark : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? DexoProductionTheme.dark
                  : DexoProductionTheme.border,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? Colors.white : DexoProductionTheme.dark,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : DexoProductionTheme.dark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DexoProductionTile extends StatelessWidget {
  const DexoProductionTile({
    super.key,
    required this.action,
    required this.onTap,
  });

  final Map<String, dynamic> action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final viewModel = DexoProductionActionViewModel.fromAction(action);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DexoProductionTheme.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.028),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DexoProductionTheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: DexoProductionTheme.dark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.docType.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoProductionTheme.dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoProductionTheme.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Requested by ${viewModel.employeeName}',
                    style: GoogleFonts.plusJakartaSans(
                      color: DexoProductionTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (viewModel.reason.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Reason: ${viewModel.reason}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: DexoProductionTheme.muted.withValues(
                          alpha: 0.85,
                        ),
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (viewModel.date != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatDexoProductionDate(viewModel.date!),
                      style: GoogleFonts.plusJakartaSans(
                        color: DexoProductionTheme.muted.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: DexoProductionTheme.muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class DexoProductionDetailsSheet extends StatelessWidget {
  const DexoProductionDetailsSheet({super.key, required this.action});

  final Map<String, dynamic> action;

  @override
  Widget build(BuildContext context) {
    final viewModel = DexoProductionActionViewModel.fromAction(action);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: DexoProductionTheme.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DexoProductionTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: DexoProductionTheme.dark,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.docType.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: DexoProductionTheme.dark,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: DexoProductionTheme.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            DexoProductionDetailRow('Employee', viewModel.employeeName),
            DexoProductionDetailRow('Email', viewModel.employeeEmail),
            DexoProductionDetailRow('Role', viewModel.role),
            DexoProductionDetailRow('Department', viewModel.department),
            DexoProductionDetailRow('Reason', viewModel.reasonOrDash),
            DexoProductionDetailRow(
              'Created at',
              viewModel.date != null
                  ? formatDexoProductionDate(viewModel.date!)
                  : '-',
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DexoProductionTheme.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Generated, archived and sent by Hera.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: DexoProductionTheme.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DexoProductionDetailRow extends StatelessWidget {
  const DexoProductionDetailRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DexoProductionTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DexoProductionTheme.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: DexoProductionTheme.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                color: DexoProductionTheme.dark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DexoProductionEmptyState extends StatelessWidget {
  const DexoProductionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DexoProductionTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DexoProductionTheme.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            size: 44,
            color: DexoProductionTheme.muted,
          ),
          const SizedBox(height: 12),
          Text(
            'No production logs found',
            style: GoogleFonts.plusJakartaSans(
              color: DexoProductionTheme.dark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing the filters or swipe down to refresh.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: DexoProductionTheme.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class DexoProductionSectionTitle extends StatelessWidget {
  const DexoProductionSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: DexoProductionTheme.dark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class DexoProductionRoundButton extends StatelessWidget {
  const DexoProductionRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: DexoProductionTheme.border),
        ),
        child: Icon(icon, color: DexoProductionTheme.dark, size: 18),
      ),
    );
  }
}

class DexoProductionActionViewModel {
  const DexoProductionActionViewModel({
    required this.docType,
    required this.filename,
    required this.employeeName,
    required this.employeeEmail,
    required this.department,
    required this.role,
    required this.reason,
    required this.date,
  });

  factory DexoProductionActionViewModel.fromAction(
    Map<String, dynamic> action,
  ) {
    final details = action['details'] is Map
        ? Map<String, dynamic>.from(action['details'])
        : <String, dynamic>{};

    final employee = action['employee_id'] is Map
        ? Map<String, dynamic>.from(action['employee_id'])
        : <String, dynamic>{};

    final dateRaw = action['created_at'] ?? action['createdAt'];

    return DexoProductionActionViewModel(
      docType:
          (details['document'] ??
                  details['doc_type'] ??
                  details['type'] ??
                  action['action_type'] ??
                  'DOCUMENT')
              .toString(),
      filename: (details['filename'] ?? 'document.pdf').toString(),
      employeeName:
          (action['employee_name'] ??
                  details['employee_name'] ??
                  employee['name'] ??
                  'System')
              .toString(),
      employeeEmail: (employee['email'] ?? '-').toString(),
      department: (employee['department'] ?? '-').toString(),
      role: (employee['role'] ?? '-').toString(),
      reason: (details['reason'] ?? '').toString(),
      date: dateRaw != null ? DateTime.tryParse(dateRaw.toString()) : null,
    );
  }

  final String docType;
  final String filename;
  final String employeeName;
  final String employeeEmail;
  final String department;
  final String role;
  final String reason;
  final DateTime? date;

  String get reasonOrDash => reason.isEmpty ? '-' : reason;
}

String formatDexoProductionShortDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

String formatDexoProductionDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year} · '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
