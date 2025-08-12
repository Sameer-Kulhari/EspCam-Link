import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/session_login_screen.dart';  // new login screen
import 'screens/session_screen.dart';

void main() {
  runApp(const EspCamLinkApp());
}

class EspCamLinkApp extends StatelessWidget {
  const EspCamLinkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EspCamLink',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/menu': (context) => const MenuScreen(),
        '/session_login': (context) => const SessionLoginScreen(),
        '/session': (context) => const SessionScreen(),
      },
    );
  }
}
