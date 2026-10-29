import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:expence/src/features/expenses/domain/entities/expense.dart';
import 'package:expence/src/features/expenses/domain/entities/expense_category.dart';
import 'package:expence/src/features/expenses/domain/entities/payment_method.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.expense});
  final Expense? expense;
  bool get isEditing => expense != null;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _categoryId;
  late DateTime _date;
  late PaymentMethod _paymentMethod;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _categoryId = e?.categoryId ?? ExpenseCategory.all.first.id;
    _date = e?.date ?? DateTime.now();
    _paymentMethod = e?.paymentMethod ?? PaymentMethod.cash;
    if (e != null) {
      _amountController.text = e.amount.toString();
      _noteController.text = e.note;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    final provider = context.read<ExpenseProvider>();
    final expense = Expense(
      id: widget.expense?.id ?? provider.newId(),
      amount: amount,
      categoryId: _categoryId,
      date: _date,
      note: _noteController.text.trim(),
      paymentMethod: _paymentMethod,
    );
    if (widget.isEditing) {
      await provider.updateExpense(expense);
    } else {
      await provider.addExpense(expense);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Expense' : 'New Expense'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                await provider.deleteExpense(widget.expense!.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, const Color(0xFF7C3AED)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      provider.currency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        autofocus: !widget.isEditing,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategory.all.map((c) {
              final selected = _categoryId == c.id;
              return GestureDetector(
                onTap: () => setState(() => _categoryId = c.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? c.color.withValues(alpha: 0.16)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? c.color
                          : theme.dividerColor.withValues(alpha: 0.5),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        c.icon,
                        size: 16,
                        color: selected ? c.color : theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? c.color : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Date',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 12),
                  Text(DateFormat('EEEE, d MMMM yyyy').format(_date)),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: theme.hintColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Payment Method',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentMethod.values.map((m) {
              return ChoiceChip(
                avatar: Icon(m.icon, size: 16),
                label: Text(m.label),
                selected: _paymentMethod == m,
                onSelected: (_) => setState(() => _paymentMethod = m),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Note (optional)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'What was this for?'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _save,
            child: Text(widget.isEditing ? 'Update Expense' : 'Save Expense'),
          ),
        ),
      ),
    );
  }
}
