import 'package:expence/src/core/data/local_storage_service.dart';
import 'package:expence/src/features/expenses/data/models/expense_model.dart';
import 'package:expence/src/features/expenses/domain/entities/expense.dart';
import 'package:expence/src/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  Future<List<Expense>> getExpenses() async {
    final maps = await _storage.loadJsonList(LocalStorageService.expensesKey);
    return maps.map(ExpenseModel.fromMap).toList();
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) {
    return _storage.saveJsonList(
      LocalStorageService.expensesKey,
      expenses.map(ExpenseModel.toMap).toList(),
    );
  }

  @override
  Future<void> clearExpenses() {
    return _storage.remove(LocalStorageService.expensesKey);
  }
}
