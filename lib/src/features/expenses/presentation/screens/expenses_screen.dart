import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:expence/src/features/expenses/domain/entities/expense.dart';
import 'package:expence/src/features/expenses/domain/entities/expense_category.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';
import 'package:expence/src/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expence/src/features/expenses/presentation/widgets/expense_tile.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);

    final filtered = p.expenses.where((e) {
      final matchesQuery =
          _query.isEmpty ||
          e.note.toLowerCase().contains(_query.toLowerCase()) ||
          ExpenseCategory.byId(
            e.categoryId,
          ).name.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _categoryFilter == null || e.categoryId == _categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    final grouped = <String, List<Expense>>{};
    for (final e in filtered) {
      grouped.putIfAbsent(_groupLabel(e.date), () => []).add(e);
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Expenses',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search expenses…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('All', null),
                ...ExpenseCategory.all.map((c) => _filterChip(c.name, c.id)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No matching expenses',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                          child: Text(
                            entry.key,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (e) => Dismissible(
                            key: ValueKey(e.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              final removed = e;
                              p.deleteExpense(removed.id);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: const Text('Expense deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () => p.addExpense(removed),
                                    ),
                                  ),
                                );
                            },
                            child: ExpenseTile(
                              expense: e,
                              currency: p.currency,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddExpenseScreen(expense: e),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? id) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _categoryFilter == id,
        onSelected: (_) => setState(() => _categoryFilter = id),
        showCheckmark: false,
      ),
    );
  }

  String _groupLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMM yyyy').format(d);
  }
}
