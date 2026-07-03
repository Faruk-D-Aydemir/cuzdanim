import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../utils/cloud_save.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    required this.storage,
    required this.onChanged,
    this.auth,
  });

  final FinanceStorage storage;
  final VoidCallback onChanged;
  final AuthService? auth;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  TransactionType? _typeFilter;
  ExpenseCategory? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(dynamic cat, AppLocalizations l10n) {
    if (cat is ExpenseCategory) return cat.localizedLabel(l10n);
    if (cat is IncomeCategory) return cat.localizedLabel(l10n);
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final transactions = widget.storage.searchTransactions(
      query: _searchController.text,
      typeFilter: _typeFilter,
      expenseFilter: _categoryFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    auth: widget.auth,
                    storage: widget.storage,
                  ),
                ),
              );
              widget.onChanged();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.filterAll),
                  selected: _typeFilter == null && _categoryFilter == null,
                  onSelected: (_) => setState(() {
                    _typeFilter = null;
                    _categoryFilter = null;
                  }),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.income),
                  selected: _typeFilter == TransactionType.income,
                  onSelected: (_) => setState(() {
                    _typeFilter = TransactionType.income;
                    _categoryFilter = null;
                  }),
                ),
                const SizedBox(width: 6),
                FilterChip(
                  label: Text(l10n.expense),
                  selected: _typeFilter == TransactionType.expense &&
                      _categoryFilter == null,
                  onSelected: (_) => setState(() {
                    _typeFilter = TransactionType.expense;
                    _categoryFilter = null;
                  }),
                ),
                ...ExpenseCategory.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FilterChip(
                      label: Text(cat.localizedLabel(l10n)),
                      selected: _categoryFilter == cat,
                      onSelected: (_) => setState(() {
                        _typeFilter = TransactionType.expense;
                        _categoryFilter = cat;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long,
                    message: l10n.transactionsEmpty,
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final cat = tx.isIncome
                          ? tx.incomeCategory!
                          : tx.expenseCategory!;
                      final catLabel = _categoryLabel(cat, l10n);
                      String subtitle =
                          '${formatDate(tx.date, locale: locale)} • $catLabel';
                      if (tx.cardId != null) {
                        final card = widget.storage.cards
                            .where((c) => c.id == tx.cardId)
                            .firstOrNull;
                        if (card != null) subtitle += ' • ${card.name}';
                      }
                      if (tx.profileId != null && widget.auth != null) {
                        final child =
                            widget.auth!.childById(tx.profileId);
                        if (child != null) subtitle += ' • ${child.name}';
                      }
                      if (tx.description.isNotEmpty) {
                        subtitle += '\n${tx.description}';
                      }

                      return TransactionTile(
                        title: catLabel,
                        subtitle: subtitle,
                        amount: tx.amount,
                        isIncome: tx.isIncome,
                        icon: categoryIcon(cat),
                        color: categoryColor(cat),
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.deleteTransactionTitle),
                              content: Text(l10n.deleteTransactionMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                          if (!context.mounted || confirm != true) return;
                          final ok = await saveToCloud(
                            context,
                            () => widget.storage.deleteTransaction(tx.id),
                            successMessage: l10n.transactionDeleted,
                          );
                          if (!mounted) return;
                          if (ok) {
                            widget.onChanged();
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
