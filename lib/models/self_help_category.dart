import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SelfHelpCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const SelfHelpCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

const List<SelfHelpCategory> selfHelpCategories = [
  SelfHelpCategory(
    id: 'rights_at_work',
    title: 'Your Rights at Work',
    icon: Icons.shield_outlined,
    color: AppColors.navyBlue,
  ),
  SelfHelpCategory(
    id: 'money_savings',
    title: 'Money & Savings',
    icon: Icons.savings_outlined,
    color: AppColors.orange,
  ),
  SelfHelpCategory(
    id: 'insurance',
    title: 'Insurance Made Simple',
    icon: Icons.health_and_safety_outlined,
    color: AppColors.teal,
  ),
  SelfHelpCategory(
    id: 'government_schemes',
    title: 'Government Schemes for You',
    icon: Icons.account_balance_outlined,
    color: AppColors.navyBlue,
  ),
];
