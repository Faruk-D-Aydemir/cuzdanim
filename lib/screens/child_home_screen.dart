import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/expense_category.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../utils/cloud_save.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'app_gate.dart';
import 'profile_picker_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({
    super.key,
    required this.auth,
    required this.storage,
  });

  final AuthService auth;
  final FinanceStorage storage;

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  void _refresh() => setState(() {});

  Future<void> _addExpense() async {
    final child = widget.auth.activeChild!;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChildAddExpenseScreen(
          storage: widget.storage,
          profileId: child.id,
          childName: child.name,
        ),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final child = widget.auth.activeChild!;
    final now = DateTime.now();
    final monthExpense = widget.storage.profileExpense(child.id, now);
    final weekExpense = widget.storage.profileWeeklyExpense(child.id);
    final transactions = widget.storage.transactionsForProfile(child.id, now);
    final limit = child.weeklyLimit;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hello(child.name)),
        backgroundColor: child.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: l10n.switchProfile,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ProfilePickerScreen(
                    auth: widget.auth,
                    storage: widget.storage,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => logout(context, widget.auth, widget.storage),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: child.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: child.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.spentThisMonth),
                Text(
                  formatMoney(monthExpense, locale: locale),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: child.color,
                  ),
                ),
              ],
            ),
          ),
          if (limit != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.weeklyLimit),
                        Text(
                          '${formatMoney(weekExpense, locale: locale)} / ${formatMoney(limit, locale: locale)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (weekExpense / limit).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: weekExpense > limit ? Colors.red : child.color,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    if (weekExpense > limit) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.limitExceeded,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l10n.mySpending,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            EmptyState(
              icon: Icons.receipt_long,
              message: l10n.childEmpty,
            )
          else
            ...transactions.map((tx) {
              final cat = tx.expenseCategory!;
              return TransactionTile(
                title: tx.description.isNotEmpty
                    ? tx.description
                    : cat.localizedLabel(l10n),
                subtitle: formatDate(tx.date, locale: locale),
                amount: tx.amount,
                isIncome: false,
                icon: cat.icon,
                color: cat.color,
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.addExpense),
      ),
    );
  }
}

class _ChildAddExpenseScreen extends StatefulWidget {
  const _ChildAddExpenseScreen({
    required this.storage,
    required this.profileId,
    required this.childName,
  });

  final FinanceStorage storage;
  final String profileId;
  final String childName;

  @override
  State<_ChildAddExpenseScreen> createState() => _ChildAddExpenseScreenState();
}

class _ChildAddExpenseScreenState extends State<_ChildAddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ExpenseCategory _category = ExpenseCategory.market;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final ok = await saveToCloud(
      context,
      () async {
        await widget.storage.addTransaction(
          FinanceTransaction(
            id: const Uuid().v4(),
            amount: amount,
            type: TransactionType.expense,
            date: DateTime.now(),
            description: _descriptionController.text.trim(),
            expenseCategory: _category,
            profileId: widget.profileId,
          ),
        );
        await widget.storage.notifyChildExpense(
          childName: widget.childName,
          amount: amount,
          description: _descriptionController.text.trim(),
        );
      },
      successMessage: l10n.expenseSaved,
    );
    if (mounted && ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addExpense)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amountLabel,
                prefixIcon: const Icon(Icons.payments),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.amountRequired;
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return l10n.amountInvalid;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.whatBought,
                prefixIcon: const Icon(Icons.notes),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.category, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                return CategoryChip(
                  label: cat.localizedLabel(l10n),
                  icon: cat.icon,
                  color: cat.color,
                  selected: _category == cat,
                  onTap: () => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
