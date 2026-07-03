import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/credit_card.dart';
import '../models/expense_category.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../services/notification_coordinator.dart';
import '../utils/cloud_save.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    required this.storage,
    this.auth,
    this.preselectMarket = false,
    this.fixedProfileId,
  });

  final FinanceStorage storage;
  final AuthService? auth;
  final bool preselectMarket;
  final String? fixedProfileId;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TransactionType _type = TransactionType.expense;
  ExpenseCategory _expenseCategory = ExpenseCategory.market;
  IncomeCategory _incomeCategory = IncomeCategory.salary;
  DateTime _date = DateTime.now();
  String? _selectedCardId;
  String? _selectedProfileId;
  bool _saveAsRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectMarket) {
      _type = TransactionType.expense;
      _expenseCategory = ExpenseCategory.market;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: Localizations.localeOf(context),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final transaction = FinanceTransaction(
      id: const Uuid().v4(),
      amount: amount,
      type: _type,
      date: _date,
      description: _descriptionController.text.trim(),
      expenseCategory:
          _type == TransactionType.expense ? _expenseCategory : null,
      incomeCategory:
          _type == TransactionType.income ? _incomeCategory : null,
      cardId: _type == TransactionType.expense ? _selectedCardId : null,
      profileId: _type == TransactionType.expense
          ? (widget.fixedProfileId ?? _selectedProfileId)
          : null,
    );

    final ok = await saveToCloud(
      context,
      () async {
        await widget.storage.addTransaction(transaction);
        if (_saveAsRecurring) {
          await widget.storage.addRecurring(
            RecurringTransaction(
              id: const Uuid().v4(),
              amount: amount,
              type: _type,
              dayOfMonth: _date.day,
              description: _descriptionController.text.trim(),
              expenseCategory:
                  _type == TransactionType.expense ? _expenseCategory : null,
              incomeCategory:
                  _type == TransactionType.income ? _incomeCategory : null,
            ),
          );
          await NotificationCoordinator.applyRecurringNow(widget.storage);
        }
      },
      successMessage: _saveAsRecurring
          ? l10n.transactionAndRecurringSaved
          : l10n.transactionSaved,
    );
    if (mounted && ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeTagFromCode(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addTransactionTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(l10n.expense),
                  icon: const Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(l10n.income),
                  icon: const Icon(Icons.add),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 20),
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
                labelText: l10n.descriptionOptional,
                prefixIcon: const Icon(Icons.notes),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.date),
              subtitle: Text(formatDate(_date, locale: locale)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _saveAsRecurring,
              onChanged: (value) => setState(() => _saveAsRecurring = value),
              secondary: const Icon(Icons.repeat),
              title: Text(l10n.repeatMonthly),
              subtitle: Text(l10n.repeatMonthlySubtitle(_date.day)),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              _type == TransactionType.expense ? l10n.category : l10n.incomeType,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (_type == TransactionType.expense)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((cat) {
                  return CategoryChip(
                    label: cat.localizedLabel(l10n),
                    icon: cat.icon,
                    color: cat.color,
                    selected: _expenseCategory == cat,
                    onTap: () => setState(() => _expenseCategory = cat),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IncomeCategory.values.map((cat) {
                  return CategoryChip(
                    label: cat.localizedLabel(l10n),
                    icon: cat.icon,
                    color: cat.color,
                    selected: _incomeCategory == cat,
                    onTap: () => setState(() => _incomeCategory = cat),
                  );
                }).toList(),
              ),
            if (_type == TransactionType.expense &&
                widget.auth != null &&
                widget.auth!.children.isNotEmpty &&
                widget.fixedProfileId == null) ...[
              const SizedBox(height: 20),
              Text(
                l10n.whoseExpense,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _selectedProfileId,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.parentGeneral,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.parentGeneral)),
                  ...widget.auth!.children.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedProfileId = v),
              ),
            ],
            if (_type == TransactionType.expense &&
                widget.storage.cards.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.cardOptional,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _selectedCardId,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l10n.cashOrCard,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.cash)),
                  ...widget.storage.cards.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        '${c.name}${c.lastFourDigits.isNotEmpty ? ' •••• ${c.lastFourDigits}' : ''}',
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedCardId = v),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key, required this.storage});

  final FinanceStorage storage;

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _nameController = TextEditingController();
  final _digitsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _dueDay = 15;
  int _colorValue = 0xFF1565C0;

  static const _colors = [
    0xFF1565C0,
    0xFF6A1B9A,
    0xFFC62828,
    0xFF2E7D32,
    0xFFE65100,
    0xFF00695C,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _digitsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = context.l10n;
    final ok = await saveToCloud(
      context,
      () => widget.storage.addCard(
        CreditCardInfo(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          dueDay: _dueDay,
          lastFourDigits: _digitsController.text.trim(),
          colorValue: _colorValue,
        ),
      ),
      successMessage: l10n.cardSaved,
    );
    if (mounted && ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCard)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.cardNameLabel,
                hintText: l10n.cardNameHint,
                prefixIcon: const Icon(Icons.credit_card),
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.cardNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _digitsController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: l10n.lastFourLabel,
                prefixIcon: const Icon(Icons.pin),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dueDayLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _dueDay.toDouble(),
              min: 1,
              max: 28,
              divisions: 27,
              label: '$_dueDay',
              onChanged: (v) => setState(() => _dueDay = v.round()),
            ),
            Center(
              child: Text(
                l10n.dueDayMonthly(_dueDay),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.cardColor, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _colors.map((c) {
                final selected = _colorValue == c;
                return GestureDetector(
                  onTap: () => setState(() => _colorValue = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(l10n.saveCard),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
