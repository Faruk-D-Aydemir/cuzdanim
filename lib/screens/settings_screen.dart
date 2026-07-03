import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/expense_category.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../services/app_settings.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../services/notification_coordinator.dart';
import '../utils/cloud_save.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/pin_pad.dart';
import 'app_gate.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.auth,
    required this.storage,
    required this.onChanged,
  });

  final AuthService auth;
  final FinanceStorage storage;
  final VoidCallback onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final b = widget.storage.monthlyBudget;
    if (b != null) _budgetController.text = b.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final l10n = context.l10n;
    final text = _budgetController.text.trim();
    final ok = await saveToCloud(
      context,
      () async {
        if (text.isEmpty) {
          await widget.storage.setMonthlyBudget(null);
        } else {
          final v = double.tryParse(text.replaceAll(',', '.'));
          if (v == null || v <= 0) return;
          await widget.storage.setMonthlyBudget(v);
        }
      },
      successMessage: l10n.budgetSaved,
    );
    if (ok) widget.onChanged();
  }

  Future<void> _exportCsv() async {
    final l10n = context.l10n;
    final csv = widget.storage.exportCsv();
    await Clipboard.setData(ClipboardData(text: csv));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.csvCopied)),
      );
    }
  }

  Future<void> _addRecurring() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AddRecurringScreen(storage: widget.storage),
      ),
    );
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);
    final recurring = widget.storage.recurring;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (context, _) {
              final settings = AppSettings.instance;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appearance,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<AppThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: AppThemeMode.light,
                            label: Text(l10n.themeLight),
                            icon: const Icon(Icons.light_mode, size: 18),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.dark,
                            label: Text(l10n.themeDark),
                            icon: const Icon(Icons.dark_mode, size: 18),
                          ),
                          ButtonSegment(
                            value: AppThemeMode.system,
                            label: Text(l10n.themeSystem),
                            icon: const Icon(Icons.settings_brightness, size: 18),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (s) =>
                            settings.setThemeMode(s.first),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.language,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'tr',
                            label: Text(l10n.languageTurkish),
                          ),
                          ButtonSegment(
                            value: 'en',
                            label: Text(l10n.languageEnglish),
                          ),
                        ],
                        selected: {settings.locale.languageCode},
                        onSelectionChanged: (s) {
                          final code = s.first;
                          settings.setLocale(
                            code == 'en'
                                ? const Locale('en', 'US')
                                : const Locale('tr', 'TR'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            child: ListTile(
              leading: Icon(Icons.cloud_done, color: colorScheme.primary),
              title: Text(l10n.cloudBackupTitle),
              subtitle: Text(l10n.cloudBackupSubtitle),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.monthlyBudget,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.budgetLimitLabel,
              hintText: l10n.budgetLimitHint,
              prefixIcon: const Icon(Icons.savings),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _saveBudget,
            child: Text(l10n.saveBudget),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recurringTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _addRecurring,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recurringHint,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (recurring.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.repeat, color: Colors.grey),
                title: Text(l10n.noRecurring),
              ),
            )
          else
            ...recurring.map((r) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    r.type == TransactionType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: r.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    r.description.isNotEmpty
                        ? r.description
                        : r.localizedCategoryLabel(l10n),
                  ),
                  subtitle: Text(
                    l10n.recurringSubtitle(
                      r.dayOfMonth,
                      formatMoney(r.amount, locale: locale),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final ok = await saveToCloud(
                        context,
                        () => widget.storage.deleteRecurring(r.id),
                        successMessage: l10n.recurringDeleted,
                      );
                      if (ok) {
                        widget.onChanged();
                        setState(() {});
                      }
                    },
                  ),
                ),
              );
            }),
          const Divider(height: 32),
          Text(
            l10n.exportTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _exportCsv,
            icon: const Icon(Icons.download),
            label: Text(l10n.exportCsv),
          ),
          const Divider(height: 32),
          Text(
            l10n.legalSection,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LegalScreen(document: LegalDocument.privacy),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.termsOfUse),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LegalScreen(document: LegalDocument.terms),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Text(
            l10n.dangerZone,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
              title: Text(
                l10n.deleteAccount,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(l10n.deleteAccountHint),
              onTap: () => _confirmDeleteAccount(context),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountDialogTitle),
        content: Text(l10n.deleteAccountDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteAccountConfirmButton),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _DeleteAccountPinScreen(auth: widget.auth),
      ),
    );
  }
}

class _DeleteAccountPinScreen extends StatefulWidget {
  const _DeleteAccountPinScreen({required this.auth});

  final AuthService auth;

  @override
  State<_DeleteAccountPinScreen> createState() =>
      _DeleteAccountPinScreenState();
}

class _DeleteAccountPinScreenState extends State<_DeleteAccountPinScreen> {
  String? _error;
  int _resetKey = 0;
  bool _loading = false;

  Future<void> _onPin(String pin) async {
    if (_loading) return;
    setState(() => _loading = true);

    final err = await widget.auth.deleteAccount(pin: pin);

    if (!mounted) return;

    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
        _resetKey++;
      });
      return;
    }

    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deleteAccountSuccess)),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AppGate(auth: widget.auth, storage: FinanceStorage()),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteAccount)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PinPad(
              key: ValueKey(_resetKey),
              title: l10n.deleteAccountPinTitle,
              subtitle: l10n.deleteAccountPinSubtitle,
              errorText: _error,
              onCompleted: _onPin,
            ),
    );
  }
}

class _AddRecurringScreen extends StatefulWidget {
  const _AddRecurringScreen({required this.storage});

  final FinanceStorage storage;

  @override
  State<_AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends State<_AddRecurringScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  TransactionType _type = TransactionType.income;
  ExpenseCategory _expenseCat = ExpenseCategory.bills;
  IncomeCategory _incomeCat = IncomeCategory.salary;
  DateTime _selectedDate = DateTime.now();

  int get _day => _selectedDate.day;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickRecurringDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: Localizations.localeOf(context),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) return;

    final ok = await saveToCloud(
      context,
      () async {
        await widget.storage.addRecurring(
          RecurringTransaction(
            id: const Uuid().v4(),
            amount: amount,
            type: _type,
            dayOfMonth: _day,
            description: _descController.text.trim(),
            expenseCategory:
                _type == TransactionType.expense ? _expenseCat : null,
            incomeCategory:
                _type == TransactionType.income ? _incomeCat : null,
          ),
        );
        await NotificationCoordinator.applyRecurringNow(widget.storage);
      },
      successMessage: l10n.recurringSaved,
    );
    if (mounted && ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addRecurring)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.income,
                label: Text(l10n.income),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text(l10n.expense),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.amountLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: l10n.descriptionExample,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_repeat),
            title: Text(l10n.whichDay),
            subtitle: Text(
              l10n.recurringDaySelected(
                formatDate(_selectedDate, locale: locale),
                _day,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickRecurringDate,
          ),
          const SizedBox(height: 8),
          if (_type == TransactionType.income)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: IncomeCategory.values.map((c) {
                return CategoryChip(
                  label: c.localizedLabel(l10n),
                  icon: c.icon,
                  color: c.color,
                  selected: _incomeCat == c,
                  onTap: () => setState(() => _incomeCat = c),
                );
              }).toList(),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((c) {
                return CategoryChip(
                  label: c.localizedLabel(l10n),
                  icon: c.icon,
                  color: c.color,
                  selected: _expenseCat == c,
                  onTap: () => setState(() => _expenseCat = c),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}
