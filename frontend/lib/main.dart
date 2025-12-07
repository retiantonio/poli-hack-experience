import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Trip',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // Pornește direct în Login Page
      debugShowCheckedModeBanner: false,
    );
  }
}
