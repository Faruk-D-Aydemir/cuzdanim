import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../services/app_settings.dart';
import '../utils/formatters.dart';

class AppliedRecurringNotice {
  const AppliedRecurringNotice({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
  });

  final String id;
  final String title;
  final double amount;
  final bool isIncome;
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  AppLocalizations get _l10n =>
      AppLocalizations(AppSettings.instance.locale);

  String get _localeTag =>
      AppSettings.instance.locale.languageCode == 'en' ? 'en_US' : 'tr_TR';

  Future<void> init() async {
    if (_ready) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_launcher_foreground');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _ready = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready || kIsWeb) return;

    final l10n = _l10n;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'cuzdanim_main',
        l10n.notificationChannelMain,
        channelDescription: l10n.notificationChannelMainDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(id, title, body, details);
  }

  Future<void> showRecurringApplied(AppliedRecurringNotice notice) async {
    final l10n = _l10n;
    final money = formatMoney(notice.amount, locale: _localeTag);
    final label = notice.title;

    if (notice.isIncome) {
      await show(
        id: notice.id.hashCode,
        title: l10n.incomeAddedTitle,
        body: l10n.incomeAddedBody(money, label),
      );
      return;
    }

    await show(
      id: notice.id.hashCode,
      title: l10n.paymentMadeTitle,
      body: l10n.paymentMadeBody(money, label),
    );
  }

  Future<void> syncRecurringSchedules(List<RecurringTransaction> items) async {
    if (!_ready || kIsWeb) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.requestExactAlarmsPermission();

    for (final item in items) {
      await _scheduleRecurring(item);
    }
  }

  Future<void> cancelRecurring(String recurringId) async {
    if (!_ready || kIsWeb) return;
    await _plugin.cancel(_recurringNotificationId(recurringId));
  }

  Future<void> _scheduleRecurring(RecurringTransaction item) async {
    final l10n = _l10n;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      _clampDay(now.year, now.month, item.dayOfMonth),
      9,
    );
    if (scheduled.isBefore(now)) {
      final nextMonth = DateTime(now.year, now.month + 1);
      scheduled = tz.TZDateTime(
        tz.local,
        nextMonth.year,
        nextMonth.month,
        _clampDay(nextMonth.year, nextMonth.month, item.dayOfMonth),
        9,
      );
    }

    final money = formatMoney(item.amount, locale: _localeTag);
    final label = item.description.isNotEmpty
        ? item.description
        : item.localizedCategoryLabel(l10n);
    final title = item.type == TransactionType.income
        ? l10n.monthlyIncomeTodayTitle
        : l10n.monthlyPaymentTodayTitle;
    final body = item.type == TransactionType.income
        ? l10n.monthlyIncomeTodayBody(money, label)
        : l10n.monthlyPaymentTodayBody(money, label);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'cuzdanim_recurring',
        l10n.notificationChannelRecurring,
        channelDescription: l10n.notificationChannelRecurringDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      _recurringNotificationId(item.id),
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  int _recurringNotificationId(String recurringId) =>
      recurringId.hashCode.abs() % 100000000;

  int _clampDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return day.clamp(1, lastDay);
  }
}
