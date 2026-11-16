import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LocalService.init();
  runApp(const SpaceNewsApp());
}

class SpaceNewsApp extends StatefulWidget {
  const SpaceNewsApp({super.key});

  @override
  State<SpaceNewsApp> createState() => _SpaceNewsAppState();
}

class _SpaceNewsAppState extends State<SpaceNewsApp> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final login = await LocalService.checkLogin();
    if (mounted) setState(() => isLoggedIn = login);
  }

  void loginSuccess() {
    setState(() => isLoggedIn = true);
  }

  void logoutSuccess() {
    setState(() => isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' SpaceNews Explorer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF247A58),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF173D2D),
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: isLoggedIn == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : isLoggedIn!
          ? MainScreen(onLogout: logoutSuccess)
          : AuthScreen(onLogin: loginSuccess),
    );
  }
}
