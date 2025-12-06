import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// PAGINI (le ai deja în proiect)
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touristic Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenu(),
    );
  }
}

// ------------------------- MAIN MENU -------------------------

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      username = prefs.getString("username");
    });
  }

  // Test GET JSON
  Future<void> testJson(BuildContext context) async {
    try {
      final url = Uri.parse('http://10.85.82.166:8000/get-route/?city=Sibiu');
      final response = await http.get(url);
      String message;

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);
        message = "JSON primit cu succes! Vezi consola.";
      } else {
        message = "Eroare la request: ${response.statusCode}";
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Test JSON"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Test JSON"),
          content: Text("Eroare: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Menu"),
        actions: [
          if (username != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green, // culoarea exact ca butonul
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      username!,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text("Start Tour"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                );
              },
            ),
            ElevatedButton(
              child: const Text("Settings"),
              onPressed: () => testJson(context),
            ),
            ElevatedButton(
              child: const Text("Login"),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                if (result == true) {
                  // Reîncarcă username-ul după login
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    username = prefs.getString("username");
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
