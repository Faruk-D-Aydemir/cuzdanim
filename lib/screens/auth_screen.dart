import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/cuzdanim_brand.dart';
import '../widgets/pin_pad.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.auth,
    required this.onSuccess,
  });

  final AuthService auth;
  final VoidCallback onSuccess;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              if (!keyboardOpen) ...[
                const SizedBox(height: 24),
                const CuzdanimBrand(),
                const SizedBox(height: 16),
              ] else ...[
                const SizedBox(height: 8),
                const CuzdanimBrand(compact: true, showTagline: false),
                const SizedBox(height: 8),
              ],
              TabBar(
                controller: _tabs,
                tabs: [
                  Tab(text: l10n.tabLogin),
                  Tab(text: l10n.tabRegister),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _LoginForm(auth: widget.auth, onSuccess: widget.onSuccess),
                    _RegisterForm(
                      auth: widget.auth,
                      onSuccess: widget.onSuccess,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.auth, required this.onSuccess});

  final AuthService auth;
  final VoidCallback onSuccess;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _userController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  void _goToPin() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LoginPinScreen(
          auth: widget.auth,
          username: _userController.text.trim(),
          onSuccess: widget.onSuccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _userController,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.usernameLabel,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
                hintText: l10n.usernameHintLogin,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.usernameRequired : null,
              onFieldSubmitted: (_) => _goToPin(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _goToPin,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.continueToPin),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.auth, required this.onSuccess});

  final AuthService auth;
  final VoidCallback onSuccess;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _emailController = TextEditingController();
  final _userController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _checkingUsername = false;

  @override
  void dispose() {
    _emailController.dispose();
    _userController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v, AppLocalizations l10n) {
    final email = v?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return l10n.emailRequired;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return l10n.emailInvalid;
    }
    return null;
  }

  String? _validateUsername(String? v, AppLocalizations l10n) {
    final user = v?.trim() ?? '';
    if (user.length < 3) return l10n.usernameMinLength;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(user)) {
      return l10n.usernameInvalidChars;
    }
    return null;
  }

  Future<void> _goToPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _checkingUsername = true);
    try {
      final taken = await widget.auth.isUsernameTaken(_userController.text.trim());
      if (!mounted) return;
      setState(() => _checkingUsername = false);

      if (taken) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.usernameTaken)),
        );
        return;
      }
    } on AuthServiceException catch (e) {
      if (!mounted) return;
      setState(() => _checkingUsername = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RegisterPinScreen(
          auth: widget.auth,
          email: _emailController.text.trim(),
          username: _userController.text.trim(),
          onSuccess: widget.onSuccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
                hintText: l10n.emailHint,
              ),
              validator: (v) => _validateEmail(v, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _userController,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.usernameLabel,
                prefixIcon: const Icon(Icons.alternate_email),
                border: const OutlineInputBorder(),
                hintText: l10n.usernameHintRegister,
              ),
              validator: (v) => _validateUsername(v, l10n),
              onFieldSubmitted: (_) {
                if (!_checkingUsername) _goToPin();
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _checkingUsername ? null : _goToPin,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _checkingUsername
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.continueCreatePin),
            ),
          ],
        ),
      ),
    );
  }
}

void _finishAuth(BuildContext context, VoidCallback onSuccess) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  onSuccess();
}

class _LoginPinScreen extends StatefulWidget {
  const _LoginPinScreen({
    required this.auth,
    required this.username,
    required this.onSuccess,
  });

  final AuthService auth;
  final String username;
  final VoidCallback onSuccess;

  @override
  State<_LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<_LoginPinScreen> {
  String? _error;
  int _resetKey = 0;
  bool _loading = false;

  Future<void> _onPin(String pin) async {
    if (_loading) return;
    setState(() => _loading = true);

    final err = await widget.auth.login(
      username: widget.username,
      pin: pin,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() {
        _error = err;
        _resetKey++;
      });
    } else {
      _finishAuth(context, widget.onSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.usernameAt(widget.username))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PinPad(
              key: ValueKey(_resetKey),
              title: l10n.pinEnterTitle,
              subtitle: l10n.pinEnterSubtitle,
              errorText: _error,
              onCompleted: _onPin,
            ),
    );
  }
}

class _RegisterPinScreen extends StatefulWidget {
  const _RegisterPinScreen({
    required this.auth,
    required this.email,
    required this.username,
    required this.onSuccess,
  });

  final AuthService auth;
  final String email;
  final String username;
  final VoidCallback onSuccess;

  @override
  State<_RegisterPinScreen> createState() => _RegisterPinScreenState();
}

class _RegisterPinScreenState extends State<_RegisterPinScreen> {
  String? _firstPin;
  String? _error;
  int _resetKey = 0;
  bool _loading = false;

  Future<void> _onPin(String pin) async {
    if (_loading) return;

    if (_firstPin == null) {
      setState(() {
        _firstPin = pin;
        _error = null;
        _resetKey++;
      });
      return;
    }

    if (pin != _firstPin) {
      setState(() {
        _error = context.l10n.pinMismatch;
        _firstPin = null;
        _resetKey++;
      });
      return;
    }

    setState(() => _loading = true);
    final err = await widget.auth.register(
      email: widget.email,
      username: widget.username,
      pin: pin,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() {
        _error = err;
        _firstPin = null;
        _resetKey++;
      });
    } else {
      _finishAuth(context, widget.onSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isConfirm = _firstPin != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isConfirm ? l10n.pinConfirmTitle : l10n.pinCreateTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    children: [
                      Text(
                        l10n.usernameAt(widget.username),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PinPad(
                    key: ValueKey(_resetKey),
                    title: isConfirm ? l10n.pinConfirmPadTitle : l10n.pinCreateTitle,
                    subtitle: isConfirm
                        ? l10n.pinConfirmSubtitle
                        : l10n.pinCreateSubtitle,
                    errorText: _error,
                    onCompleted: _onPin,
                  ),
                ),
              ],
            ),
    );
  }
}
