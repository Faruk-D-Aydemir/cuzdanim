import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/finance_storage.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  final FinanceStorage storage;
  final VoidCallback onChanged;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final income = widget.storage.totalIncome(_month);
    final expense = widget.storage.totalExpense(_month);
    final change = widget.storage.expenseChangePercent(_month);
    final byCategory = widget.storage.expensesByCategory(_month);
    final budget = widget.storage.monthlyBudget;
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.analyticsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _shiftMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                formatMonth(_month, locale: locale),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _shiftMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.income,
                  value: formatMoney(income, locale: locale),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: l10n.expense,
                  value: formatMoney(expense, locale: locale),
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                change >= 0 ? Icons.trending_up : Icons.trending_down,
                color: change >= 0 ? Colors.red : Colors.green,
              ),
              title: Text(l10n.expenseVsLastMonth),
              subtitle: Text(
                change >= 0
                    ? l10n.expenseIncrease(change.toStringAsFixed(0))
                    : l10n.expenseDecrease(change.abs().toStringAsFixed(0)),
              ),
            ),
          ),
          if (budget != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.monthlyBudget,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatMoney(expense, locale: locale)} / ${formatMoney(budget, locale: locale)}',
                        ),
                        Text(
                          '%${((expense / budget) * 100).clamp(0, 999).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: expense > budget
                                ? Colors.red
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (expense / budget).clamp(0.0, 1.0),
                        minHeight: 10,
                        color: expense > budget
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (expense > budget)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.budgetExceededBy(
                            formatMoney(expense - budget, locale: locale),
                          ),
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l10n.categoryBreakdown,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            EmptyState(
              icon: Icons.pie_chart,
              message: l10n.noExpenseData,
            )
          else ...[
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: sorted.map((e) {
                    final pct = expense > 0 ? (e.value / expense) * 100 : 0;
                    return PieChartSectionData(
                      value: e.value,
                      title: '%${pct.toStringAsFixed(0)}',
                      color: e.key.color,
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...sorted.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(e.key.icon, color: e.key.color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key.localizedLabel(l10n))),
                    Text(
                      formatMoney(e.value, locale: locale),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
