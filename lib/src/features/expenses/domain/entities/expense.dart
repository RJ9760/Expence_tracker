import 'package:expence/src/features/expenses/domain/entities/payment_method.dart';

class Expense {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;
  final PaymentMethod paymentMethod;

  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
    this.paymentMethod = PaymentMethod.cash,
  });
}
