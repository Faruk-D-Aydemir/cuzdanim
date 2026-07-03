import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/finance_storage.dart';
import '../utils/cloud_save.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'add_transaction_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  final FinanceStorage storage;
  final VoidCallback onChanged;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final marketTotal = widget.storage.marketSpending(_selectedMonth);
    final marketTx = widget.storage.marketTransactions(_selectedMonth);
    final allExpense = widget.storage.totalExpense(_selectedMonth);
    final marketShare = allExpense > 0 ? marketTotal / allExpense : 0.0;

    final weeklySpending = <int, double>{};
    for (final tx in marketTx) {
      final week = ((tx.date.day - 1) ~/ 7) + 1;
      weeklySpending[week] = (weeklySpending[week] ?? 0) + tx.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    storage: widget.storage,
                    preselectMarket: true,
                  ),
                ),
              );
              widget.onChanged();
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                formatMonth(_selectedMonth, locale: locale),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.shopping_cart, color: Color(0xFF4CAF50), size: 36),
                const SizedBox(height: 8),
                Text(l10n.totalMarketSpending),
                Text(
                  formatMoney(marketTotal, locale: locale),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                if (allExpense > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.shareOfExpenses(
                      (marketShare * 100).toStringAsFixed(0),
                    ),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (weeklySpending.isNotEmpty) ...[
            Text(
              l10n.weeklyBreakdown,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklySpending.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          formatMoney(rod.toY, locale: locale),
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(l10n.weekLabel(value.toInt()));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklySpending.entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value,
                          color: const Color(0xFF4CAF50),
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            l10n.transactionsCount(marketTx.length),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (marketTx.isEmpty)
            EmptyState(
              icon: Icons.shopping_basket_outlined,
              message: l10n.marketEmpty,
            )
          else
            ...marketTx.map((tx) {
              return TransactionTile(
                title: tx.description.isNotEmpty
                    ? tx.description
                    : l10n.defaultMarketTitle,
                subtitle: formatDate(tx.date, locale: locale),
                amount: tx.amount,
                isIncome: false,
                icon: Icons.shopping_cart,
                color: const Color(0xFF4CAF50),
                onDelete: () async {
                  final ok = await saveToCloud(
                    context,
                    () => widget.storage.deleteTransaction(tx.id),
                    successMessage: l10n.expenseDeleted,
                  );
                  if (ok) {
                    widget.onChanged();
                    setState(() {});
                  }
                },
              );
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
