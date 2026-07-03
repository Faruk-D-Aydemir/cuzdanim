import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/child_profile.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'profile_picker_screen.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({
    super.key,
    required this.auth,
    required this.storage,
    required this.onChanged,
  });

  final AuthService auth;
  final FinanceStorage storage;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final children = auth.children;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.familyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddChildScreen(auth: auth),
                ),
              );
              onChanged();
            },
          ),
        ],
      ),
      body: children.isEmpty
          ? EmptyState(
              icon: Icons.family_restroom,
              message: l10n.familyEmpty,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return _ChildSpendingCard(
                  child: child,
                  storage: storage,
                  month: now,
                  onDelete: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.deleteProfileTitle),
                        content: Text(l10n.deleteProfileMessage(child.name)),
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
                    if (ok == true) {
                      await auth.deleteChild(child.id);
                      onChanged();
                    }
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildDetailScreen(
                          child: child,
                          storage: storage,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: children.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddChildScreen(auth: auth),
                  ),
                );
                onChanged();
              },
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addChild),
            )
          : null,
    );
  }
}

class _ChildSpendingCard extends StatelessWidget {
  const _ChildSpendingCard({
    required this.child,
    required this.storage,
    required this.month,
    required this.onDelete,
    required this.onTap,
  });

  final ChildProfile child;
  final FinanceStorage storage;
  final DateTime month;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final monthExpense = storage.profileExpense(child.id, month);
    final weekExpense = storage.profileWeeklyExpense(child.id);
    final limit = child.weeklyLimit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: child.color.withValues(alpha: 0.15),
                    child: Icon(Icons.face, color: child.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.thisMonth(formatMoney(monthExpense, locale: locale)),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (limit != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.thisWeek),
                    Text(
                      '${formatMoney(weekExpense, locale: locale)} / ${formatMoney(limit, locale: locale)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: weekExpense > limit
                            ? Colors.red
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (weekExpense / limit).clamp(0.0, 1.0),
                    minHeight: 6,
                    color: weekExpense > limit ? Colors.red : child.color,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ChildDetailScreen extends StatelessWidget {
  const ChildDetailScreen({
    super.key,
    required this.child,
    required this.storage,
  });

  final ChildProfile child;
  final FinanceStorage storage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final now = DateTime.now();
    final transactions = storage.transactionsForProfile(child.id, now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.childDetailTitle(child.name)),
        backgroundColor: child.color,
        foregroundColor: Colors.white,
      ),
      body: transactions.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long,
              message: l10n.childNoExpenses,
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, i) {
                final tx = transactions[i];
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
              },
            ),
    );
  }
}
