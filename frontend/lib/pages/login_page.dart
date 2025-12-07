import 'package:flutter/material.dart';
import 'package:frontend/pages/scrollable_producers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/pages/signup_choice_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // --------------------- LOGICA LOGIN ---------------------
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loginData = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    final url = Uri.parse("http://172.20.10.2:8000/login/"); // ENDPOINT LOGIN

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userMap = data["user"] ?? {};
        final username = userMap["username"] ?? "User";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", username);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigare către MainMenu și resetarea stack-ului
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ScrollableBoxesPage(),
          ), // <--- aici pui pagina ta principală
          (Route<dynamic> route) => false,
        );
      } else {
        // optional: mesaj pentru login eșuat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Oops! Something went wrong! Try again later"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpChoicePage()),
    );
  }

  // --------------------- BUILD UI ---------------------
  @override
  Widget build(BuildContext context) {
    const double fieldWidth = 300;

    return Scaffold(
      backgroundColor: const Color(0xFF0C3B2E),
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color(0xFF0C3B2E),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo + Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.hiking, color: Colors.white, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'Local Trip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Username field
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.vpn_key,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Link "Contact us"
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Having problems logging in? Contact us.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),

                // Login button cu gradient
                SizedBox(
                  width: fieldWidth,
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6D9773), Color(0xFFA7C0AB)],
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isLoading ? null : _login,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Link Register cu cursor de mana
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    InkWell(
                      onTap: _goToSignUp,
                      mouseCursor: SystemMouseCursors.click,
                      child: const Text(
                        'Register here',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
