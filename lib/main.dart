import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence/src/app/spendwise_app.dart';
import 'package:expence/src/core/data/local_storage_service.dart';
import 'package:expence/src/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';
import 'package:expence/src/features/settings/data/repositories/settings_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  final provider = ExpenseProvider(
    expenseRepository: ExpenseRepositoryImpl(storage),
    settingsRepository: SettingsRepositoryImpl(storage),
  );
  await provider.init();
  runApp(
    ChangeNotifierProvider.value(value: provider, child: const SpendWiseApp()),
  );
}
