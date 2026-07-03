import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.auth,
    required this.onVerified,
    required this.onLogout,
  });

  final AuthService auth;
  final VoidCallback onVerified;
  final VoidCallback onLogout;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _checking = false;
  bool _resending = false;
  String? _message;
  String? _error;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _initialized = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final warning = widget.auth.lastMailWarning;
    if (warning != null) {
      _error = warning;
      widget.auth.clearMailWarning();
      _startCooldown(90);
    } else {
      _message = context.l10n.emailVerifyInitial;
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _checkVerified() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    final verified = await widget.auth.refreshEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (verified) {
      widget.onVerified();
    } else {
      setState(() {
        _message = context.l10n.emailVerifyNotYet;
      });
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _resending = true;
      _error = null;
      _message = null;
    });

    final err = await widget.auth.resendVerificationEmail();

    if (!mounted) return;
    setState(() => _resending = false);

    if (err != null) {
      setState(() => _error = err);
      if (err.contains('Çok fazla deneme')) {
        _startCooldown(120);
      } else {
        _startCooldown(60);
      }
    } else {
      final l10n = context.l10n;
      setState(() => _message = l10n.emailVerifyResentSuccess);
      _startCooldown(60);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailVerifySnackbarSent)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = widget.auth.currentEmail ?? '';
    final canResend = !_resending && _resendCooldown == 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.mark_email_unread_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.emailVerifyTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.emailVerifySentTo(email),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.emailVerifyHelp,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: TextStyle(color: Colors.green.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: _checking ? null : _checkVerified,
                icon: _checking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(l10n.emailVerifyContinue),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: canResend ? _resend : null,
                icon: _resending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _resendCooldown > 0
                      ? l10n.emailVerifyResendCooldown(_resendCooldown)
                      : l10n.emailVerifyResend,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onLogout,
                child: Text(l10n.logout),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
