import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maize_disease_app/screens/register_screen.dart';
import 'package:maize_disease_app/screens/splash_screen.dart';
import 'package:maize_disease_app/services/session_manager.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final loggedIn = await SessionManager.isLoggedIn();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(MaizeScanApp(isLoggedIn: loggedIn));
}

class MaizeScanApp extends StatelessWidget {
  final bool isLoggedIn;
  const MaizeScanApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaizeScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: SplashScreen(isLoggedIn: isLoggedIn),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
