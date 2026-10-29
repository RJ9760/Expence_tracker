import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expence/src/app/spendwise_app.dart';
import 'package:expence/src/core/data/local_storage_service.dart';
import 'package:expence/src/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expence/src/features/expenses/presentation/providers/expense_provider.dart';
import 'package:expence/src/features/settings/data/repositories/settings_repository_impl.dart';

void main() {
  testWidgets('SpendWise home loads', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    final provider = ExpenseProvider(
      expenseRepository: ExpenseRepositoryImpl(storage),
      settingsRepository: SettingsRepositoryImpl(storage),
    );
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const SpendWiseApp(),
      ),
    );

    expect(find.text('SpendWise'), findsWidgets);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
