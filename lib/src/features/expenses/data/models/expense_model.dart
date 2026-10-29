import 'package:expence/src/features/expenses/domain/entities/expense.dart';
import 'package:expence/src/features/expenses/domain/entities/payment_method.dart';

class ExpenseModel {
  const ExpenseModel._();

  static Expense fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as String,
    amount: (map['amount'] as num).toDouble(),
    categoryId: map['categoryId'] as String,
    date: DateTime.parse(map['date'] as String),
    note: (map['note'] as String?) ?? '',
    paymentMethod: PaymentMethod.values.firstWhere(
      (p) => p.name == map['paymentMethod'],
      orElse: () => PaymentMethod.cash,
    ),
  );

  static Map<String, dynamic> toMap(Expense expense) => {
    'id': expense.id,
    'amount': expense.amount,
    'categoryId': expense.categoryId,
    'date': expense.date.toIso8601String(),
    'note': expense.note,
    'paymentMethod': expense.paymentMethod.name,
  };
}
