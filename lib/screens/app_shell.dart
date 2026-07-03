import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/credit_card.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../services/notification_coordinator.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'analytics_screen.dart';
import 'add_transaction_screen.dart';
import 'app_gate.dart';
import 'cards_screen.dart';
import 'family_screen.dart';
import 'market_screen.dart';
import 'profile_picker_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.auth, required this.storage});

  final AuthService auth;
  final FinanceStorage storage;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    NotificationCoordinator.startParentMode(widget.storage).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    NotificationCoordinator.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final income = widget.storage.totalIncome(now);
    final expense = widget.storage.totalExpense(now);
    final balance = income - expense;
    final market = widget.storage.marketSpending(now);
    final upcomingCards = widget.storage.cards.toList()
      ..sort((a, b) => a.daysUntilDue().compareTo(b.daysUntilDue()));

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _DashboardTab(
            auth: widget.auth,
            storage: widget.storage,
            income: income,
            expense: expense,
            balance: balance,
            market: market,
            upcomingCards: upcomingCards,
            onRefresh: _refresh,
            onGoFamily: () => setState(() => _index = 4),
          ),
          AnalyticsScreen(storage: widget.storage, onChanged: _refresh),
          TransactionsScreen(
            auth: widget.auth,
            storage: widget.storage,
            onChanged: _refresh,
          ),
          MarketScreen(storage: widget.storage, onChanged: _refresh),
          CardsScreen(storage: widget.storage, onChanged: _refresh),
          FamilyScreen(
            auth: widget.auth,
            storage: widget.storage,
            onChanged: _refresh,
          ),
        ],
      ),
      floatingActionButton: _index == 2 || _index == 3
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(
                      auth: widget.auth,
                      storage: widget.storage,
                      preselectMarket: _index == 3,
                    ),
                  ),
                );
                _refresh();
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.navSummary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.navAnalytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: l10n.navMarket,
          ),
          NavigationDestination(
            icon: const Icon(Icons.credit_card_outlined),
            selectedIcon: const Icon(Icons.credit_card),
            label: l10n.navCards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.family_restroom_outlined),
            selectedIcon: const Icon(Icons.family_restroom),
            label: l10n.navFamily,
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.auth,
    required this.storage,
    required this.income,
    required this.expense,
    required this.balance,
    required this.market,
    required this.upcomingCards,
    required this.onRefresh,
    required this.onGoFamily,
  });

  final AuthService auth;
  final FinanceStorage storage;
  final double income;
  final double expense;
  final double balance;
  final double market;
  final List<CreditCardInfo> upcomingCards;
  final VoidCallback onRefresh;
  final VoidCallback onGoFamily;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final now = DateTime.now();
    final byCategory = storage.expensesByCategory(now);
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    auth: auth,
                    storage: storage,
                    onChanged: onRefresh,
                  ),
                ),
              );
              onRefresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: l10n.switchProfile,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ProfilePickerScreen(
                    auth: auth,
                    storage: storage,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => logout(context, auth, storage),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              formatMonth(now, locale: locale),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.remainingBalance,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(balance, locale: locale),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: l10n.income,
                    amount: income,
                    color: Colors.green,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: l10n.expense,
                    amount: expense,
                    color: Colors.red,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SummaryCard(
              title: l10n.marketSpending,
              amount: market,
              color: const Color(0xFF4CAF50),
              icon: Icons.shopping_cart,
            ),
            if (storage.monthlyBudget != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.savings, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.monthlyBudget,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatMoney(expense, locale: locale)} / ${formatMoney(storage.monthlyBudget!, locale: locale)}',
                          ),
                          Text(
                            expense > storage.monthlyBudget!
                                ? l10n.budgetExceeded
                                : l10n.budgetRemaining(
                                    formatMoney(
                                      storage.monthlyBudget! - expense,
                                      locale: locale,
                                    ),
                                  ),
                            style: TextStyle(
                              color: expense > storage.monthlyBudget!
                                  ? Colors.red
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (expense / storage.monthlyBudget!)
                              .clamp(0.0, 1.0),
                          minHeight: 8,
                          color: expense > storage.monthlyBudget!
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (auth.children.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(
                title: l10n.childSpending,
                action: l10n.seeAll,
                onAction: onGoFamily,
              ),
              const SizedBox(height: 8),
              ...auth.children.map((child) {
                final spent = storage.profileExpense(child.id, now);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: child.color.withValues(alpha: 0.15),
                      child: Icon(Icons.face, color: child.color),
                    ),
                    title: Text(child.name),
                    subtitle: Text(
                      l10n.thisMonth(formatMoney(spent, locale: locale)),
                    ),
                    trailing: child.weeklyLimit != null
                        ? Text(
                            l10n.weeklyShort(
                              formatMoney(
                                storage.profileWeeklyExpense(child.id),
                                locale: locale,
                              ),
                            ),
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            _SectionHeader(
              title: l10n.upcomingCardPayments,
              action: upcomingCards.isEmpty ? l10n.addCard : null,
              onAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CardsScreen(storage: storage, onChanged: onRefresh),
                  ),
                );
                onRefresh();
              },
            ),
            const SizedBox(height: 8),
            if (upcomingCards.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.grey),
                  title: Text(l10n.noCardsYet),
                  subtitle: Text(l10n.addCardHint),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CardsScreen(storage: storage, onChanged: onRefresh),
                      ),
                    );
                    onRefresh();
                  },
                ),
              )
            else
              ...upcomingCards.take(3).map((card) {
                final days = card.daysUntilDue();
                final cardExpense = storage.cardSpending(card.id, now);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: card.color.withValues(alpha: 0.2),
                      child: Icon(Icons.credit_card, color: card.color),
                    ),
                    title: Text(card.name),
                    subtitle: Text(
                      l10n.cardDueSubtitle(
                        '${card.dueDay}',
                        formatMoney(cardExpense, locale: locale),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: days <= 3
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        days == 0 ? l10n.today : l10n.daysLeft(days),
                        style: TextStyle(
                          color: days <= 3
                              ? Colors.red.shade700
                              : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.spendingBreakdown),
            const SizedBox(height: 8),
            if (sortedCategories.isEmpty)
              EmptyState(
                icon: Icons.pie_chart_outline,
                message: l10n.noExpensesThisMonth,
              )
            else
              ...sortedCategories.map((entry) {
                final percent = expense > 0 ? (entry.value / expense) * 100 : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(entry.key.icon, color: entry.key.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key.localizedLabel(l10n)),
                                Text(
                                  formatMoney(entry.value, locale: locale),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: expense > 0 ? entry.value / expense : 0,
                                backgroundColor: Colors.grey.shade200,
                                color: entry.key.color,
                                minHeight: 6,
                              ),
                            ),
                            Text(
                              '%${percent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}
