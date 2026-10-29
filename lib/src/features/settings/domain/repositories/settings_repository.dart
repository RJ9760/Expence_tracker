import 'package:expence/src/features/settings/domain/entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> saveMonthlyBudget(double value);
  Future<void> saveDarkMode(bool value);
  Future<void> saveCurrency(String value);
}
