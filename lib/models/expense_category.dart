import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum ExpenseCategory {
  market('Market', Icons.shopping_cart, Color(0xFF4CAF50)),
  food('Yemek', Icons.restaurant, Color(0xFFFF9800)),
  transport('Ulaşım', Icons.directions_car, Color(0xFF2196F3)),
  bills('Faturalar', Icons.receipt_long, Color(0xFF9C27B0)),
  entertainment('Eğlence', Icons.movie, Color(0xFFE91E63)),
  health('Sağlık', Icons.medical_services, Color(0xFF00BCD4)),
  clothing('Giyim', Icons.checkroom, Color(0xFF795548)),
  other('Diğer', Icons.more_horiz, Color(0xFF607D8B));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExpenseCategory.market:
        return l10n.categoryMarket();
      case ExpenseCategory.food:
        return l10n.categoryFood();
      case ExpenseCategory.transport:
        return l10n.categoryTransport();
      case ExpenseCategory.bills:
        return l10n.categoryBills();
      case ExpenseCategory.entertainment:
        return l10n.categoryEntertainment();
      case ExpenseCategory.health:
        return l10n.categoryHealth();
      case ExpenseCategory.clothing:
        return l10n.categoryClothing();
      case ExpenseCategory.other:
        return l10n.categoryOther();
    }
  }

  static ExpenseCategory fromKey(String key) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => ExpenseCategory.other,
    );
  }
}

enum IncomeCategory {
  salary('Maaş', Icons.work, Color(0xFF4CAF50)),
  freelance('Serbest', Icons.laptop, Color(0xFF2196F3)),
  investment('Yatırım', Icons.trending_up, Color(0xFF9C27B0)),
  gift('Hediye', Icons.card_giftcard, Color(0xFFE91E63)),
  other('Diğer', Icons.more_horiz, Color(0xFF607D8B));

  const IncomeCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case IncomeCategory.salary:
        return l10n.incomeSalary();
      case IncomeCategory.freelance:
        return l10n.incomeFreelance();
      case IncomeCategory.investment:
        return l10n.incomeInvestment();
      case IncomeCategory.gift:
        return l10n.incomeGift();
      case IncomeCategory.other:
        return l10n.incomeOther();
    }
  }

  static IncomeCategory fromKey(String key) {
    return IncomeCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => IncomeCategory.other,
    );
  }
}
