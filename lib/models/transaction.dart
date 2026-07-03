import 'expense_category.dart';

enum TransactionType { income, expense }

class FinanceTransaction {
  FinanceTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.description = '',
    this.expenseCategory,
    this.incomeCategory,
    this.cardId,
    this.profileId,
  }) : assert(
         (type == TransactionType.expense && expenseCategory != null) ||
             (type == TransactionType.income && incomeCategory != null),
       );

  final String id;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final String? cardId;
  final String? profileId;

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isMarket =>
      type == TransactionType.expense &&
      expenseCategory == ExpenseCategory.market;

  String get categoryLabel => isIncome
      ? incomeCategory!.label
      : expenseCategory!.label;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.name,
    'date': date.toIso8601String(),
    'description': description,
    'expenseCategory': expenseCategory?.name,
    'incomeCategory': incomeCategory?.name,
    'cardId': cardId,
    'profileId': profileId,
  };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    final type = TransactionType.values.byName(json['type'] as String);
    return FinanceTransaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: type,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String? ?? '',
      expenseCategory: json['expenseCategory'] != null
          ? ExpenseCategory.fromKey(json['expenseCategory'] as String)
          : null,
      incomeCategory: json['incomeCategory'] != null
          ? IncomeCategory.fromKey(json['incomeCategory'] as String)
          : null,
      cardId: json['cardId'] as String?,
      profileId: json['profileId'] as String?,
    );
  }
}
