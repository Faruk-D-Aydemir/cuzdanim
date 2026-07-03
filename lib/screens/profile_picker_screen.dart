import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/child_profile.dart';
import '../services/auth_service.dart';
import '../services/finance_storage.dart';
import '../widgets/cuzdanim_brand.dart';
import 'app_gate.dart';
import 'app_shell.dart';
import 'child_home_screen.dart';

class ProfilePickerScreen extends StatelessWidget {
  const ProfilePickerScreen({
    super.key,
    required this.auth,
    required this.storage,
  });

  final AuthService auth;
  final FinanceStorage storage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.usernameAt(auth.currentUser!.username)),
        actions: [
          TextButton.icon(
            onPressed: () => logout(context, auth, storage),
            icon: const Icon(Icons.logout, size: 20),
            label: Text(l10n.logoutShort),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftHeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.whoUsing,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  auth.currentUser!.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileCard(
            name: l10n.parentName,
            subtitle: l10n.parentSubtitle,
            icon: Icons.supervisor_account,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              auth.loginAsParent();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AppShell(auth: auth, storage: storage),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (auth.children.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.child_care, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(l10n.noChildren),
                    const SizedBox(height: 4),
                    Text(
                      l10n.noChildrenHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ...auth.children.map((child) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ProfileCard(
                  name: child.name,
                  subtitle: l10n.childAccount,
                  icon: Icons.face,
                  color: child.color,
                  onTap: () {
                    auth.loginAsChild(child);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ChildHomeScreen(
                          auth: auth,
                          storage: storage,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _colorValue = 0xFF7B1FA2;

  static const _colors = [
    0xFF7B1FA2,
    0xFFE91E63,
    0xFF2196F3,
    0xFF4CAF50,
    0xFFFF9800,
    0xFF00BCD4,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final limitText = _limitController.text.trim();
    final limit = limitText.isEmpty
        ? null
        : double.tryParse(limitText.replaceAll(',', '.'));

    await widget.auth.addChild(
      ChildProfile(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        weeklyLimit: limit,
        colorValue: _colorValue,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addChild)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                hintText: l10n.nameHint,
                prefixIcon: const Icon(Icons.face),
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.weeklyLimitLabel,
                hintText: l10n.weeklyLimitHint,
                prefixIcon: const Icon(Icons.savings),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.profileColor, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
