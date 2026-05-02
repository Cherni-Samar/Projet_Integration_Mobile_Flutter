import '../../../domain/models/kash/kash_expense_model.dart';
import '../../../domain/models/kash/kash_budget_model.dart';
import '../../../domain/models/kash/kash_reminder_model.dart';
import '../../../domain/models/kash/kash_staffing_analysis_model.dart';

import '../../dtos/kash/kash_expense_dto.dart';
import '../../dtos/kash/kash_budget_dto.dart';
import '../../dtos/kash/kash_reminder_dto.dart';
class KashMapper {
  static KashExpense toExpense(KashExpenseDTO dto) {
    return KashExpense(
      id: dto.id,
      amount: dto.amount,
      currency: dto.currency,
      vendor: dto.vendor,
      category: dto.category,
      description: dto.description,
      date: dto.date,
    );
  }

  static KashBudget toBudget(KashBudgetDTO dto) {
    return KashBudget(
      id: dto.id,
      category: dto.category,
      limit: dto.limit,
      spent: dto.spent,
      currency: dto.currency,
    );
  }

  static KashReminder toReminder(KashReminderDTO dto) {
    return KashReminder(
      id: dto.id,
      title: dto.title,
      amount: dto.amount,
      currency: dto.currency,
      dueDate: dto.dueDate,
      status: dto.status,
      notes: dto.notes,
    );
  }
}