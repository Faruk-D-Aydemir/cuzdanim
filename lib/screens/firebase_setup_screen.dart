import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({
    super.key,
    this.webMisconfigured = false,
  });

  final bool webMisconfigured;

  @override
  Widget build(BuildContext context) {
    if (!webMisconfigured) {
      return const _GenericSetup();
    }
    return const _WebSetup();
  }
}

class _GenericSetup extends StatelessWidget {
  const _GenericSetup();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.cloud_off, size: 64, color: Colors.orange.shade700),
              const SizedBox(height: 24),
              Text(
                l10n.firebaseSetupTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.firebaseSetupInstructions,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebSetup extends StatelessWidget {
  const _WebSetup();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.phone_android, size: 72, color: Colors.green.shade700),
              const SizedBox(height: 16),
              Text(
                l10n.firebaseWebTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.firebaseWebBody,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PowerShell:\n'
                  'cd C:\\Users\\muham\\deneme_app\n'
                  '.\\calistir.ps1',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.firebaseDetail,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
