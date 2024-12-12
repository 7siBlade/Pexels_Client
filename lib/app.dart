import 'package:flutter/material.dart';
import 'package:test_task/login_page.dart';
import 'package:test_task/main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}
