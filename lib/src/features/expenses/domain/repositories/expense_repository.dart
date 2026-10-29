import 'package:expence/src/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> saveExpenses(List<Expense> expenses);
  Future<void> clearExpenses();
}
