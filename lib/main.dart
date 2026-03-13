import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/app_state.dart';
import 'services/supabase_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/merchant/merchant_dashboard.dart';
import 'screens/customer/customer_view.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0f172a),
  ));

  await SupabaseService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const RepwardApp(),
    ),
  );
}

class RepwardApp extends StatelessWidget {
  const RepwardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repward OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _splashComplete = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashComplete) {
      return SplashScreen(
        onComplete: () {
          setState(() {
            _splashComplete = true;
          });
        },
      );
    }
    return const AppShell();
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    switch (appState.currentView) {
      case 'onboarding':
        return const OnboardingScreen();
      case 'merchant':
        return const MerchantDashboard();
      case 'customer':
        return const CustomerView();
      default:
        return const OnboardingScreen();
    }
  }
}
