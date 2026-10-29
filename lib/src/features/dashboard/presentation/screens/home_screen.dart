import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence/src/core/widgets/app_card.dart';
import 'package:expence/src/features/expenses/domain/entities/chart_range.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';
import 'package:expence/src/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expence/src/features/expenses/presentation/widgets/expense_bar_chart.dart';
import 'package:expence/src/features/expenses/presentation/widgets/expense_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ChartRange _range = ChartRange.monthly;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back 👋',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SpendWise',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _BudgetCard(provider: p),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Today',
                  value: p.money(p.todayTotal),
                  icon: Icons.today_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'This Month',
                  value: p.money(p.currentMonthTotal),
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFFA855F7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'This Year',
                  value: p.money(p.currentYearTotal),
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Spending Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: SegmentedButton<ChartRange>(
              segments: const [
                ButtonSegment(value: ChartRange.daily, label: Text('Daily')),
                ButtonSegment(
                  value: ChartRange.monthly,
                  label: Text('Monthly'),
                ),
                ButtonSegment(value: ChartRange.yearly, label: Text('Yearly')),
              ],
              selected: {_range},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _range = s.first),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
            child: ExpenseBarChart(
              buckets: p.seriesFor(_range),
              currency: p.currency,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recent Transactions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (p.expenses.isEmpty)
            AppCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      size: 48,
                      color: theme.hintColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Add Expense" to get started',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: p
                    .recentTransactions(limit: 6)
                    .map(
                      (e) => ExpenseTile(
                        expense: e,
                        currency: p.currency,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddExpenseScreen(expense: e),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.provider});
  final ExpenseProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBudget = provider.monthlyBudget > 0;
    final progress = provider.budgetProgress;
    final over = provider.currentMonthTotal > provider.monthlyBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: over
              ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
              : [theme.colorScheme.primary, const Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: (over ? Colors.red : theme.colorScheme.primary).withValues(
              alpha: 0.35,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spent this month',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            provider.money(provider.currentMonthTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (hasBudget) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  over
                      ? 'Over by ${provider.money(provider.currentMonthTotal - provider.monthlyBudget)}'
                      : '${provider.money(provider.budgetRemaining)} left',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Budget ${provider.money(provider.monthlyBudget)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'Set a monthly budget in Settings →',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
