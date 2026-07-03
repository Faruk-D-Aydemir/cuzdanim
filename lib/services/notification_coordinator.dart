import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'finance_storage.dart';
import 'notification_service.dart';

class NotificationCoordinator {
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _alertSub;
  static bool _skipInitialAlerts = true;
  static final Set<String> _shownAlertIds = {};

  static Future<void> startParentMode(FinanceStorage storage) async {
    await NotificationService.instance.init();
    await applyRecurringNow(storage);
    await NotificationService.instance.syncRecurringSchedules(storage.recurring);
    await _showUnreadAlerts(storage);
    _listenChildAlerts(storage);
  }

  static Future<void> applyRecurringNow(FinanceStorage storage) async {
    final applied = await storage.applyDueRecurring();
    for (final notice in applied) {
      await NotificationService.instance.showRecurringApplied(notice);
    }
  }

  static Future<void> _showUnreadAlerts(FinanceStorage storage) async {
    final alerts = await storage.getUnreadAlerts();
    for (final alert in alerts) {
      final id = alert['id'] as String;
      if (_shownAlertIds.contains(id)) continue;

      await NotificationService.instance.show(
        id: id.hashCode,
        title: alert['title'] as String? ?? 'Bildirim',
        body: alert['body'] as String? ?? '',
      );
      _shownAlertIds.add(id);
      await storage.markAlertRead(id);
    }
  }

  static void _listenChildAlerts(FinanceStorage storage) {
    _alertSub?.cancel();
    _skipInitialAlerts = true;

    _alertSub = storage.watchAlerts().listen((snapshot) async {
      if (_skipInitialAlerts) {
        _skipInitialAlerts = false;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) continue;
        final data = change.doc.data();
        if (data == null || data['read'] == true) continue;

        final id = change.doc.id;
        if (_shownAlertIds.contains(id)) continue;

        await NotificationService.instance.show(
          id: id.hashCode,
          title: data['title'] as String? ?? 'Bildirim',
          body: data['body'] as String? ?? '',
        );
        _shownAlertIds.add(id);
        await storage.markAlertRead(id);
      }
    });
  }

  static void dispose() {
    _alertSub?.cancel();
    _alertSub = null;
    _shownAlertIds.clear();
    _skipInitialAlerts = true;
  }
}
