import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/finance_storage.dart';

Future<bool> saveToCloud(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  final l10n = context.l10n;
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage ?? l10n.savedToCloud)),
      );
    }
    return true;
  } on FinanceStorageException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
    return false;
  }
}
