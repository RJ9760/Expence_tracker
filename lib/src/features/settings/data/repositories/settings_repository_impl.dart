import 'package:expence/src/core/data/local_storage_service.dart';
import 'package:expence/src/features/settings/domain/entities/user_settings.dart';
import 'package:expence/src/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  Future<UserSettings> getSettings() async {
    return UserSettings(
      monthlyBudget: await _storage.getDouble(LocalStorageService.budgetKey),
      darkMode: await _storage.getBool(LocalStorageService.darkModeKey),
      currency:
          await _storage.getString(LocalStorageService.currencyKey) ?? '₹',
    );
  }

  @override
  Future<void> saveMonthlyBudget(double value) {
    return _storage.setDouble(LocalStorageService.budgetKey, value);
  }

  @override
  Future<void> saveDarkMode(bool value) {
    return _storage.setBool(LocalStorageService.darkModeKey, value);
  }

  @override
  Future<void> saveCurrency(String value) {
    return _storage.setString(LocalStorageService.currencyKey, value);
  }
}
