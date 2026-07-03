import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import 'auth_screen.dart';
import 'email_verification_screen.dart';
import 'profile_picker_screen.dart';

class AppGate extends StatefulWidget {
  const AppGate({
    super.key,
    required this.auth,
    required this.storage,
  });

  final AuthService auth;
  final FinanceStorage storage;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
    widget.auth.authStateChanges.listen((_) async {
      await widget.auth.load();
      if (mounted) setState(() {});
    });
  }

  Future<void> _init() async {
    await widget.auth.load();
    if (widget.auth.isLoggedIn && widget.auth.isEmailVerified) {
      await _loadData();
    }
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _loadData() async {
    final userId = widget.auth.currentUserId!;
    await widget.storage.load(userId);
  }

  Future<void> _onLoggedIn() async {
    await widget.auth.load();
    if (widget.auth.isEmailVerified) {
      await _loadData();
    }
    setState(() {});
  }

  Future<void> _onVerified() async {
    await _loadData();
    setState(() {});
  }

  Future<void> _onLogout() async {
    await widget.auth.logout();
    widget.storage.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!widget.auth.isLoggedIn) {
      return AuthScreen(auth: widget.auth, onSuccess: _onLoggedIn);
    }

    if (!widget.auth.isEmailVerified) {
      return EmailVerificationScreen(
        auth: widget.auth,
        onVerified: _onVerified,
        onLogout: _onLogout,
      );
    }

    return ProfilePickerScreen(
      auth: widget.auth,
      storage: widget.storage,
    );
  }
}

Future<void> logout(
  BuildContext context,
  AuthService auth,
  FinanceStorage storage,
) async {
  final l10n = context.l10n;
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.logoutDialogTitle),
      content: Text(l10n.logoutDialogMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.logoutShort),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  await auth.logout();
  storage.clear();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => AppGate(auth: auth, storage: storage),
    ),
    (_) => false,
  );
}
