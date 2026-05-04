import 'package:flutter_test/flutter_test.dart';
import 'package:e_team/domain/models/hera_models.dart';

void main() {
  group('domain/models/HeraAction', () {
    test('constructs correctly with createdAt null', () {
      const action = HeraAction(
        id: 'a1',
        employeeId: 'emp1',
        employeeName: 'Ali',
        actionType: 'approve_leave',
        details: {'leaveId': 'l1', 'days': 2},
        triggeredBy: 'manager',
      );

      expect(action.id, 'a1');
      expect(action.employeeId, 'emp1');
      expect(action.employeeName, 'Ali');
      expect(action.actionType, 'approve_leave');
      expect(action.details['days'], 2);
      expect(action.triggeredBy, 'manager');
      expect(action.createdAt, isNull);
    });

    test('constructs correctly with createdAt provided', () {
      final dt = DateTime(2026, 1, 1, 12, 0);
      final action = HeraAction(
        id: 'a2',
        employeeId: 'emp2',
        employeeName: 'Samar',
        actionType: 'update_contract',
        details: const {'contract': 'CDD'},
        triggeredBy: 'admin',
        createdAt: dt,
      );

      expect(action.createdAt, dt);
    });
  });

  group('domain/models/HeraEmployee', () {
    test('constructs correctly with contract null', () {
      const emp = HeraEmployee(
        id: 'e1',
        name: 'Hana',
        email: 'hana@mail.com',
        role: 'Developer',
        department: 'IT',
        status: 'active',
        balances: {'leaveDays': 12},
      );

      expect(emp.id, 'e1');
      expect(emp.department, 'IT');
      expect(emp.balances['leaveDays'], 12);
      expect(emp.contract, isNull);
    });

    test('constructs correctly with contract provided', () {
      const emp = HeraEmployee(
        id: 'e2',
        name: 'Omar',
        email: 'omar@mail.com',
        role: 'HR',
        department: 'HR',
        status: 'active',
        balances: {'leaveDays': 20},
        contract: {'type': 'CDI', 'start': '2025-01-01'},
      );

      expect(emp.contract, isNotNull);
      expect(emp.contract!['type'], 'CDI');
    });
  });

  group('domain/models/HeraLeave', () {
    test('constructs correctly', () {
      final leave = HeraLeave(
        id: 'l1',
        employeeName: 'Meriem',
        employeeRole: 'Designer',
        type: 'annual',
        status: 'pending',
        startDate: DateTime(2026, 5, 10),
        endDate: DateTime(2026, 5, 12),
        days: 3,
        reason: 'vacation',
      );

      expect(leave.id, 'l1');
      expect(leave.days, 3);
      expect(leave.status, 'pending');
      expect(leave.startDate.isBefore(leave.endDate), true);
    });
  });

  group('domain/models/HeraCandidate', () {
    test('constructs correctly', () {
      const c = HeraCandidate(
        id: 'c1',
        name: 'Nour',
        department: 'IT',
        scoreIa: 87,
      );

      expect(c.scoreIa, 87);
      expect(c.department, 'IT');
    });
  });

  group('domain/models/HeraStats', () {
    test('constructs correctly', () {
      const s = HeraStats(
        totalEmployees: 50,
        onLeaveToday: 2,
        monthlyLeaveDays: 14,
      );

      expect(s.totalEmployees, 50);
      expect(s.onLeaveToday, 2);
      expect(s.monthlyLeaveDays, 14);
    });
  });
}
