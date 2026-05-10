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
