import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/app_gate.dart';
import 'screens/firebase_setup_screen.dart';
import 'services/app_settings.dart';
import 'services/auth_service.dart';
import 'services/finance_storage.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await initializeDateFormatting('en_US');
  await AppSettings.instance.load();
  await PurchaseService.instance.init();

  if (DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.setLanguageCode(
      AppSettings.instance.locale.languageCode,
    );
    await NotificationService.instance.init();
  } else if (kDebugMode) {
    debugPrint(
      '⚠️ Firebase yapılandırılmadı. FIREBASE_KURULUM.md adımlarını uygula.',
    );
  }

  final auth = AuthService();
  if (DefaultFirebaseOptions.isConfigured) {
    await auth.load();
    final uid = auth.currentUserId;
    if (uid != null) {
      await PurchaseService.instance.identify(uid);
    }
  }

  runApp(
    PhoneShell(
      child: CuzdanimApp(
        auth: auth,
        firebaseReady: DefaultFirebaseOptions.isConfigured,
      ),
    ),
  );
}

class CuzdanimApp extends StatefulWidget {
  const CuzdanimApp({
    super.key,
    required this.auth,
    required this.firebaseReady,
  });

  final AuthService auth;
  final bool firebaseReady;

  @override
  State<CuzdanimApp> createState() => _CuzdanimAppState();
}

class _CuzdanimAppState extends State<CuzdanimApp> {
  final _storage = FinanceStorage();

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (DefaultFirebaseOptions.isConfigured) {
      FirebaseAuth.instance.setLanguageCode(
        AppSettings.instance.locale.languageCode,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: AppLocalizations(settings.locale).appName,
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.materialThemeMode,
          home: !widget.firebaseReady
              ? FirebaseSetupScreen(
                  webMisconfigured: DefaultFirebaseOptions.isWebMisconfigured,
                )
              : AppGate(auth: widget.auth, storage: _storage),
        );
      },
    );
  }
}
