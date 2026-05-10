class HeraAction {
  final String id;
  final String employeeId;
  final String employeeName;
  final String actionType;
  final Map<String, dynamic> details;
  final String triggeredBy;
  final DateTime? createdAt;

  const HeraAction({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.actionType,
    required this.details,
    required this.triggeredBy,
    this.createdAt,
  });
}

class HeraEmployee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String status;
  final Map<String, dynamic> balances;
  final Map<String, dynamic>? contract;

  const HeraEmployee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    required this.balances,
    this.contract,
  });
}

class HeraLeave {
  final String id;
  final String employeeName;
  final String employeeRole;
  final String type;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;

  const HeraLeave({
    required this.id,
    required this.employeeName,
    required this.employeeRole,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
  });
}

class HeraCandidate {
  final String id;
  final String name;
  final String department;
  final int scoreIa;

  const HeraCandidate({
    required this.id,
    required this.name,
    required this.department,
    required this.scoreIa,
  });
}

class HeraStats {
  final int totalEmployees;
  final int onLeaveToday;
  final int monthlyLeaveDays;

  const HeraStats({
    required this.totalEmployees,
    required this.onLeaveToday,
    required this.monthlyLeaveDays,
  });
}
