import '../l10n/app_localizations.dart';
import 'expense_category.dart';
import 'transaction.dart';

class RecurringTransaction {  RecurringTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.dayOfMonth,
    this.description = '',
    this.expenseCategory,
    this.incomeCategory,
    this.lastAppliedKey = '',
  });

  final String id;
  final double amount;
  final TransactionType type;
  final int dayOfMonth;
  final String description;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final String lastAppliedKey;

  String get categoryLabel => type == TransactionType.income
      ? incomeCategory!.label
      : expenseCategory!.label;

  String localizedCategoryLabel(AppLocalizations l10n) =>
      type == TransactionType.income
          ? incomeCategory!.localizedLabel(l10n)
          : expenseCategory!.localizedLabel(l10n);
  String monthKey(DateTime date) => '${date.year}-${date.month}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.name,
    'dayOfMonth': dayOfMonth,
    'description': description,
    'expenseCategory': expenseCategory?.name,
    'incomeCategory': incomeCategory?.name,
    'lastAppliedKey': lastAppliedKey,
  };

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    final type = TransactionType.values.byName(json['type'] as String);
    return RecurringTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: type,
      dayOfMonth: json['dayOfMonth'] as int,
      description: json['description'] as String? ?? '',
      expenseCategory: json['expenseCategory'] != null
          ? ExpenseCategory.fromKey(json['expenseCategory'] as String)
          : null,
      incomeCategory: json['incomeCategory'] != null
          ? IncomeCategory.fromKey(json['incomeCategory'] as String)
          : null,
      lastAppliedKey: json['lastAppliedKey'] as String? ?? '',
    );
  }

  RecurringTransaction copyWith({String? lastAppliedKey}) {
    return RecurringTransaction(
      id: id,
      amount: amount,
      type: type,
      dayOfMonth: dayOfMonth,
      description: description,
      expenseCategory: expenseCategory,
      incomeCategory: incomeCategory,
      lastAppliedKey: lastAppliedKey ?? this.lastAppliedKey,
    );
  }
}
