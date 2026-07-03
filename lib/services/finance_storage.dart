import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/app_localizations.dart';
import '../models/credit_card.dart';
import '../models/expense_category.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import 'app_settings.dart';
import 'notification_service.dart';

class FinanceStorageException implements Exception {
  FinanceStorageException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Kullanıcı verileri Firestore'da saklanır:
/// users/{userId}/transactions, cards, recurring, children
/// users/{userId}.monthlyBudget
class FinanceStorage {
  FinanceStorage({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  String? _userId;
  List<FinanceTransaction> _transactions = [];
  List<CreditCardInfo> _cards = [];
  List<RecurringTransaction> _recurring = [];
  double? _monthlyBudget;

  List<FinanceTransaction> get transactions =>
      List.unmodifiable(_transactions);
  List<CreditCardInfo> get cards => List.unmodifiable(_cards);
  List<RecurringTransaction> get recurring => List.unmodifiable(_recurring);
  double? get monthlyBudget => _monthlyBudget;
  bool get isLoaded => _userId != null;
  String? get userId => _userId;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  String get _uid {
    final id = _userId;
    if (id == null) {
      throw FinanceStorageException('Oturum bulunamadı. Tekrar giriş yap.');
    }
    return id;
  }

  Future<T> _runWrite<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      throw FinanceStorageException(
        'Buluta kaydedilemedi: ${e.message ?? e.code}. '
        'İnternet bağlantını ve Firebase kurallarını kontrol et.',
      );
    }
  }

  Future<void> load(String userId) async {
    _userId = userId;
    final userRef = _userDoc(userId);

    final userSnap = await userRef.get();
    _monthlyBudget = (userSnap.data()?['monthlyBudget'] as num?)?.toDouble();

    final txSnap = await userRef.collection('transactions').get();
    _transactions = txSnap.docs
        .map((d) => FinanceTransaction.fromJson(d.data()))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final cardsSnap = await userRef.collection('cards').get();
    _cards = cardsSnap.docs.map((d) => CreditCardInfo.fromJson(d.data())).toList();

    final recSnap = await userRef.collection('recurring').get();
    _recurring = recSnap.docs
        .map((d) => RecurringTransaction.fromJson(d.data()))
        .toList();

    await NotificationService.instance.syncRecurringSchedules(_recurring);
  }

  void clear() {
    _userId = null;
    _transactions = [];
    _cards = [];
    _recurring = [];
    _monthlyBudget = null;
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    await _runWrite(() async {
      await _userDoc(_uid)
          .collection('transactions')
          .doc(transaction.id)
          .set({
            ...transaction.toJson(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      _transactions.insert(0, transaction);
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _runWrite(() async {
      await _userDoc(_uid).collection('transactions').doc(id).delete();
      _transactions.removeWhere((t) => t.id == id);
    });
  }

  Future<void> addCard(CreditCardInfo card) async {
    await _runWrite(() async {
      await _userDoc(_uid).collection('cards').doc(card.id).set({
        ...card.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      _cards.add(card);
    });
  }

  Future<void> deleteCard(String id) async {
    await _runWrite(() async {
      await _userDoc(_uid).collection('cards').doc(id).delete();
      _cards.removeWhere((c) => c.id == id);
    });
  }

  Future<void> setMonthlyBudget(double? limit) async {
    await _runWrite(() async {
      await _userDoc(_uid).set(
        {'monthlyBudget': limit},
        SetOptions(merge: true),
      );
      _monthlyBudget = limit;
    });
  }

  Future<void> addRecurring(RecurringTransaction item) async {
    await _runWrite(() async {
      await _userDoc(_uid)
          .collection('recurring')
          .doc(item.id)
          .set({
            ...item.toJson(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      _recurring.add(item);
    });
    await NotificationService.instance.syncRecurringSchedules(_recurring);
  }

  Future<void> deleteRecurring(String id) async {
    await _runWrite(() async {
      await _userDoc(_uid).collection('recurring').doc(id).delete();
      _recurring.removeWhere((r) => r.id == id);
    });
    await NotificationService.instance.cancelRecurring(id);
  }

  Future<List<AppliedRecurringNotice>> applyDueRecurring() async {
    final now = DateTime.now();
    final key = _monthKey(now);
    final applied = <AppliedRecurringNotice>[];

    for (var i = 0; i < _recurring.length; i++) {
      final r = _recurring[i];
      final dueDay = _effectiveDayOfMonth(now.year, now.month, r.dayOfMonth);
      if (r.lastAppliedKey == key || now.day < dueDay) continue;

      final tx = FinanceTransaction(
        id: '${r.id}_$key',
        amount: r.amount,
        type: r.type,
        date: DateTime(now.year, now.month, dueDay),
        description: r.description.isNotEmpty
            ? r.description
            : '${r.categoryLabel} (otomatik)',
        expenseCategory: r.expenseCategory,
        incomeCategory: r.incomeCategory,
      );

      if (!_transactions.any((t) => t.id == tx.id)) {
        await _userDoc(_uid)
            .collection('transactions')
            .doc(tx.id)
            .set({
              ...tx.toJson(),
              'createdAt': FieldValue.serverTimestamp(),
            });
        _transactions.insert(0, tx);
        applied.add(
          AppliedRecurringNotice(
            id: r.id,
            title: r.description.isNotEmpty ? r.description : r.categoryLabel,
            amount: r.amount,
            isIncome: r.type == TransactionType.income,
          ),
        );
      }

      final updated = r.copyWith(lastAppliedKey: key);
      await _userDoc(_uid)
          .collection('recurring')
          .doc(r.id)
          .update({'lastAppliedKey': key});
      _recurring[i] = updated;
    }

    return applied;
  }

  Future<void> notifyChildExpense({
    required String childName,
    required double amount,
    String description = '',
  }) async {
    final l10n = AppLocalizations(AppSettings.instance.locale);
    final money = '${amount.toStringAsFixed(0)} ₺';
    final detail = description.isNotEmpty ? ' — $description' : '';
    final title = l10n.childExpenseAlert(childName);
    final body = '$money$detail';

    await _runWrite(() async {
      await _userDoc(_uid).collection('alerts').doc().set({
        'type': 'child_expense',
        'title': title,
        'body': body,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAlerts() {
    return _userDoc(_uid)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getUnreadAlerts() async {
    final snap = await _userDoc(_uid)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snap.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .where((alert) => alert['read'] != true)
        .toList();
  }

  Future<void> markAlertRead(String alertId) async {
    await _userDoc(_uid).collection('alerts').doc(alertId).update({
      'read': true,
    });
  }

  String _monthKey(DateTime date) => '${date.year}-${date.month}';

  int _effectiveDayOfMonth(int year, int month, int targetDay) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return targetDay.clamp(1, lastDay);
  }

  List<FinanceTransaction> searchTransactions({
    String query = '',
    TransactionType? typeFilter,
    ExpenseCategory? expenseFilter,
  }) {
    final q = query.trim().toLowerCase();
    return _transactions.where((t) {
      if (typeFilter != null && t.type != typeFilter) return false;
      if (expenseFilter != null && t.expenseCategory != expenseFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      final cat =
          t.isIncome ? t.incomeCategory!.label : t.expenseCategory!.label;
      return cat.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.amount.toString().contains(q);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String exportCsv() {
    final buffer = StringBuffer('Tarih,Tür,Kategori,Tutar,Açıklama\n');
    final sorted = _transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      final type = t.isIncome ? 'Gelir' : 'Gider';
      final cat =
          t.isIncome ? t.incomeCategory!.label : t.expenseCategory!.label;
      final desc = t.description.replaceAll(',', ' ');
      buffer.writeln(
        '${t.date.toIso8601String().split('T').first},$type,$cat,${t.amount},$desc',
      );
    }
    return buffer.toString();
  }

  double expenseChangePercent(DateTime month) {
    final prev = DateTime(month.year, month.month - 1);
    final current = totalExpense(month);
    final previous = totalExpense(prev);
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  List<FinanceTransaction> transactionsForMonth(DateTime month) {
    return _transactions.where((t) {
      return t.date.year == month.year && t.date.month == month.month;
    }).toList();
  }

  double totalIncome([DateTime? month]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    return list.where((t) => t.isIncome).fold(0.0, (total, t) => total + t.amount);
  }

  double totalExpense([DateTime? month]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    return list.where((t) => t.isExpense).fold(0.0, (total, t) => total + t.amount);
  }

  double marketSpending([DateTime? month]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    return list.where((t) => t.isMarket).fold(0.0, (total, t) => total + t.amount);
  }

  Map<ExpenseCategory, double> expensesByCategory([DateTime? month]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    final map = <ExpenseCategory, double>{};
    for (final t in list.where((t) => t.isExpense)) {
      final cat = t.expenseCategory!;
      map[cat] = (map[cat] ?? 0) + t.amount;
    }
    return map;
  }

  double cardSpending(String cardId, [DateTime? month]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    return list
        .where((t) => t.isExpense && t.cardId == cardId)
        .fold(0.0, (total, t) => total + t.amount);
  }

  List<FinanceTransaction> marketTransactions([DateTime? month]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    return list.where((t) => t.isMarket).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<FinanceTransaction> transactionsForProfile(
    String profileId, [
    DateTime? month,
  ]) {
    final list = month == null ? _transactions : transactionsForMonth(month);
    return list.where((t) => t.profileId == profileId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double profileExpense(String profileId, [DateTime? month]) {
    return transactionsForProfile(profileId, month)
        .where((t) => t.isExpense)
        .fold(0.0, (total, t) => total + t.amount);
  }

  double profileWeeklyExpense(String profileId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return _transactions
        .where(
          (t) =>
              t.profileId == profileId &&
              t.isExpense &&
              !t.date.isBefore(start),
        )
        .fold(0.0, (total, t) => total + t.amount);
  }
}
