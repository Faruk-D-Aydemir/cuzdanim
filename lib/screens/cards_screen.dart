import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/finance_storage.dart';
import '../utils/cloud_save.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'add_transaction_screen.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  final FinanceStorage storage;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final cards = storage.cards.toList()
      ..sort((a, b) => a.daysUntilDue().compareTo(b.daysUntilDue()));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cardsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCardScreen(storage: storage),
                ),
              );
              onChanged();
            },
          ),
        ],
      ),
      body: cards.isEmpty
          ? EmptyState(
              icon: Icons.credit_card_off,
              message: l10n.cardsEmpty,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final days = card.daysUntilDue();
                final spending = storage.cardSpending(card.id, now);
                final dueDate = card.nextDueDate();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: card.color,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  card.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (card.lastFourDigits.isNotEmpty)
                                  Text(
                                    '•••• ${card.lastFourDigits}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.thisMonth(formatMoney(spending, locale: locale)),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.event,
                          color: days <= 3 ? Colors.red : Colors.orange,
                        ),
                        title: Text(
                          l10n.lastPayment(formatDate(dueDate, locale: locale)),
                        ),
                        subtitle: Text(l10n.dueDayMonthly(card.dueDay)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: days <= 3
                                ? Colors.red.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            days == 0
                                ? l10n.dueToday
                                : l10n.daysLeftLong(days),
                            style: TextStyle(
                              color: days <= 3
                                  ? Colors.red.shade700
                                  : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.deleteCardTitle),
                                  content: Text(
                                    l10n.deleteCardMessage(card.name),
                                  ),
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
                              if (confirm == true && context.mounted) {
                                final ok = await saveToCloud(
                                  context,
                                  () => storage.deleteCard(card.id),
                                  successMessage: l10n.cardDeleted,
                                );
                                if (ok) onChanged();
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(l10n.delete),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: cards.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddCardScreen(storage: storage),
                  ),
                );
                onChanged();
              },
              icon: const Icon(Icons.add_card),
              label: Text(l10n.addCard),
            )
          : null,
    );
  }
}
