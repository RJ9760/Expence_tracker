import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence/src/core/widgets/app_card.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _currencies = ['₹', '\$', '€', '£', '¥', '₦', 'R'];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_rounded),
                  title: const Text('Monthly Budget'),
                  subtitle: Text(
                    p.monthlyBudget > 0 ? p.money(p.monthlyBudget) : 'Not set',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _editBudget(context, p),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.attach_money_rounded),
                  title: const Text('Currency'),
                  subtitle: Text(p.currency),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _pickCurrency(context, p),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark Mode'),
                  value: p.darkMode,
                  onChanged: p.setDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Clear All Data',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmClear(context, p),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'SpendWise v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editBudget(BuildContext context, ExpenseProvider p) async {
    final controller = TextEditingController(
      text: p.monthlyBudget > 0 ? p.monthlyBudget.toStringAsFixed(0) : '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '${p.currency} ',
            hintText: '0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, double.tryParse(controller.text) ?? 0),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) await p.setMonthlyBudget(result);
  }

  Future<void> _pickCurrency(BuildContext context, ExpenseProvider p) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Currency'),
        children: _currencies
            .map(
              (c) => RadioListTile<String>(
                value: c,
                groupValue: p.currency,
                title: Text(c),
                onChanged: (v) => Navigator.pop(context, v),
              ),
            )
            .toList(),
      ),
    );
    if (result != null) await p.setCurrency(result);
  }

  Future<void> _confirmClear(BuildContext context, ExpenseProvider p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will permanently delete every expense. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await p.clearAllData();
  }
}
