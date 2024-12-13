import 'package:flutter/material.dart';
import 'package:test_task/pages/login/login_page.dart';
import 'package:test_task/pages/main/main_page.dart';

class Navi extends StatelessWidget {
  const Navi({super.key});

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
