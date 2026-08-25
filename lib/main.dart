import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/home_screen.dart';
import 'package:flutter_application_1/screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TasbaMairinApp());
}

class TasbaMairinApp extends StatelessWidget {
  const TasbaMairinApp({super.key});

  Future<bool> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TasbaMairin',

      home: FutureBuilder<bool>(
        future: verificarSesion(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data == true) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}