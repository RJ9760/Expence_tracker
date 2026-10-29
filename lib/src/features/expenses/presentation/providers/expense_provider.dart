import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:expence/src/features/expenses/domain/entities/chart_bucket.dart';
import 'package:expence/src/features/expenses/domain/entities/chart_range.dart';
import 'package:expence/src/features/expenses/domain/entities/expense.dart';
import 'package:expence/src/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expence/src/features/settings/domain/repositories/settings_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({
    required ExpenseRepository expenseRepository,
    required SettingsRepository settingsRepository,
  }) : _expenseRepository = expenseRepository,
       _settingsRepository = settingsRepository;

  final ExpenseRepository _expenseRepository;
  final SettingsRepository _settingsRepository;
  final List<Expense> _expenses = [];

  double _monthlyBudget = 0;
  bool _darkMode = false;
  String _currency = '₹';

  List<Expense> get expenses => List.unmodifiable(_expenses);
  double get monthlyBudget => _monthlyBudget;
  bool get darkMode => _darkMode;
  String get currency => _currency;

  Future<void> init() async {
    _expenses.addAll(await _expenseRepository.getExpenses());
    _sort();
    final settings = await _settingsRepository.getSettings();
    _monthlyBudget = settings.monthlyBudget;
    _darkMode = settings.darkMode;
    _currency = settings.currency;
    notifyListeners();
  }

  void _sort() => _expenses.sort((a, b) => b.date.compareTo(a.date));

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    _sort();
    await _expenseRepository.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    final i = _expenses.indexWhere((e) => e.id == expense.id);
    if (i == -1) return;
    _expenses[i] = expense;
    _sort();
    await _expenseRepository.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _expenseRepository.saveExpenses(_expenses);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double v) async {
    _monthlyBudget = v;
    await _settingsRepository.saveMonthlyBudget(v);
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await _settingsRepository.saveDarkMode(v);
    notifyListeners();
  }

  Future<void> setCurrency(String v) async {
    _currency = v;
    await _settingsRepository.saveCurrency(v);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _expenses.clear();
    await _expenseRepository.clearExpenses();
    notifyListeners();
  }

  String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';

  String money(double value) {
    final digits = value == value.roundToDouble() ? 0 : 2;
    return NumberFormat.currency(
      symbol: _currency,
      decimalDigits: digits,
    ).format(value);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double totalForDay(DateTime day) => _expenses
      .where((e) => _sameDay(e.date, day))
      .fold(0.0, (s, e) => s + e.amount);

  double totalForMonth(DateTime m) => _expenses
      .where((e) => e.date.year == m.year && e.date.month == m.month)
      .fold(0.0, (s, e) => s + e.amount);

  double totalForYear(int y) =>
      _expenses.where((e) => e.date.year == y).fold(0.0, (s, e) => s + e.amount);

  double get todayTotal => totalForDay(DateTime.now());
  double get currentMonthTotal => totalForMonth(DateTime.now());
  double get currentYearTotal => totalForYear(DateTime.now().year);
  double get budgetRemaining => _monthlyBudget - currentMonthTotal;
  double get budgetProgress => _monthlyBudget <= 0
      ? 0
      : (currentMonthTotal / _monthlyBudget).clamp(0.0, 1.0);

  List<Expense> recentTransactions({int limit = 5}) =>
      _expenses.take(limit).toList();

  List<ChartBucket> seriesFor(ChartRange range) {
    switch (range) {
      case ChartRange.daily:
        return _dailySeries();
      case ChartRange.monthly:
        return _monthlySeries();
      case ChartRange.yearly:
        return _yearlySeries();
    }
  }

  List<ChartBucket> _dailySeries({int days = 7}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      return ChartBucket(
        label: DateFormat('E').format(day),
        fullLabel: DateFormat('EEE, d MMM').format(day),
        value: totalForDay(day),
      );
    });
  }

  List<ChartBucket> _monthlySeries({int months = 12}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final m = DateTime(now.year, now.month - (months - 1 - i));
      return ChartBucket(
        label: DateFormat('MMM').format(m),
        fullLabel: DateFormat('MMMM yyyy').format(m),
        value: totalForMonth(m),
      );
    });
  }

  List<ChartBucket> _yearlySeries({int years = 5}) {
    final currentYear = DateTime.now().year;
    return List.generate(years, (i) {
      final y = currentYear - (years - 1 - i);
      return ChartBucket(
        label: '$y',
        fullLabel: 'Year $y',
        value: totalForYear(y),
      );
    });
  }

  Map<String, double> categoryTotalsForMonth(DateTime month) {
    final map = <String, double>{};
    for (final e in _expenses) {
      if (e.date.year == month.year && e.date.month == month.month) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }
}
