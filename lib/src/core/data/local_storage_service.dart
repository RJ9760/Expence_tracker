import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const expensesKey = 'expenses_v1';
  static const budgetKey = 'monthly_budget_v1';
  static const darkModeKey = 'dark_mode_v1';
  static const currencyKey = 'currency_v1';

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<double> getDouble(String key, {double fallback = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? fallback;
  }

  Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<bool> getBool(String key, {bool fallback = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? fallback;
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<List<Map<String, dynamic>>> loadJsonList(String key) async {
    final raw = await getString(key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveJsonList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    await setString(key, jsonEncode(items));
  }
}
