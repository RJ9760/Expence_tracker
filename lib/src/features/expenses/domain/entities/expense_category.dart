import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ExpenseCategory> all = [
    ExpenseCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFEF4444),
    ),
    ExpenseCategory(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF3B82F6),
    ),
    ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFA855F7),
    ),
    ExpenseCategory(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFF59E0B),
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFEC4899),
    ),
    ExpenseCategory(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFF10B981),
    ),
    ExpenseCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF06B6D4),
    ),
    ExpenseCategory(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF8B5CF6),
    ),
    ExpenseCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.local_grocery_store_rounded,
      color: Color(0xFF84CC16),
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.category_rounded,
      color: Color(0xFF64748B),
    ),
  ];

  static ExpenseCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.last);
}
