import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence/src/app/root_shell.dart';
import 'package:expence/src/core/theme/app_theme.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = context.select<ExpenseProvider, bool>((p) => p.darkMode);
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const RootShell(),
    );
  }
}
