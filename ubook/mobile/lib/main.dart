import 'package:flutter/material.dart';
import 'package:ubook/login.dart';
import 'package:ubook/home.dart';
import 'package:ubook/register.dart';
import 'package:ubook/user.dart';
import 'package:ubook/calendar.dart';

void main() {
  runApp(const ubook());
}

class ubook extends StatelessWidget {
  const ubook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/users': (context) => const UsersScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}
