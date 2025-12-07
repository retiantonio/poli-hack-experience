import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/pages/login_page.dart';

class ProducerSignUpPage extends StatefulWidget {
  const ProducerSignUpPage({super.key});

  @override
  State<ProducerSignUpPage> createState() => _ProducerSignUpPageState();
}

class _ProducerSignUpPageState extends State<ProducerSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nrTelefonController = TextEditingController();
  final TextEditingController _parolaController = TextEditingController();
  final TextEditingController _confirmParolaController =
      TextEditingController();
  final TextEditingController _latitudineController = TextEditingController();
  final TextEditingController _longitudineController = TextEditingController();
  final TextEditingController _descriereProdusController =
      TextEditingController();

  String? _selectedTipProdus;
  final List<String> _tipuriProduse = [
    'Artisanal',
    'Workshop',
    'Experiences',
    'Farms',
    'Gastronomy',
    'Nature',
    'Food products',
  ];

  bool _obscureParola = true;
  bool _obscureConfirmParola = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nrTelefonController.dispose();
    _parolaController.dispose();
    _confirmParolaController.dispose();
    _latitudineController.dispose();
    _longitudineController.dispose();
    _descriereProdusController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTipProdus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product type')),
        );
        return;
      }

      final Map<String, dynamic> registrationData = {
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone_number": _nrTelefonController.text.trim(),
        "password": _parolaController.text.trim(),
        "latitude": double.tryParse(_latitudineController.text.trim()) ?? 0.0,
        "longitude": double.tryParse(_longitudineController.text.trim()) ?? 0.0,
        "product_type": _selectedTipProdus,
        "description": _descriereProdusController.text.trim(),
        "role": "SELLER",
      };

      print("JSON to send: ${jsonEncode(registrationData)}");

      final url = Uri.parse("http://172.20.10.2:8000/register/");

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(registrationData),
        );

        print("Server response status: ${response.statusCode}");
        print("Server response body: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Oops! Something went wrong! Try again later"),
            ),
          );
        }
      } catch (e) {
        print("Connection error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double fieldWidth = 300;

    return Scaffold(
      backgroundColor: const Color(0xFF0C3B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.hiking, color: Colors.white, size: 32),
                    SizedBox(width: 10),
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

                // Username
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
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
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter username'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.email,
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
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter email';
                      if (!value.contains('@'))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Nr Telefon
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _nrTelefonController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Phone Number',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.phone,
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
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter phone number'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Parola
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _parolaController,
                    obscureText: _obscureParola,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.lock,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureParola
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            setState(() => _obscureParola = !_obscureParola),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Parola
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _confirmParolaController,
                    obscureText: _obscureConfirmParola,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Password Confirmation',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmParola
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmParola = !_obscureConfirmParola,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please confirm password';
                      if (value != _parolaController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Latitudine
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _latitudineController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Latitude',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.location_on,
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
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter latitude'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Longitudine
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _longitudineController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Longitude',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.location_on,
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
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter longitude'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<String>(
                    value: _selectedTipProdus,
                    dropdownColor: const Color(0xFF2E523D),

                    // AICI SE REZOLVĂ PROBLEMA:
                    hint: const Text(
                      'Product Type',
                      style: TextStyle(color: Colors.white70),
                    ),

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),

                      // aceste două sunt ignorate de dropdown, dar pot rămâne
                      hintText: 'Product Type',
                      hintStyle: TextStyle(color: Colors.white70),

                      prefixIcon: const SizedBox(
                        width: 24,
                        child: Icon(
                          Icons.category,
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
                      ),
                    ),

                    items: _tipuriProduse.map((tip) {
                      return DropdownMenuItem<String>(
                        value: tip,
                        child: Text(
                          tip,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),

                    onChanged: (value) =>
                        setState(() => _selectedTipProdus = value),

                    validator: (value) =>
                        (value == null) ? 'Please select product type' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Descriere produs
                SizedBox(
                  width: fieldWidth,
                  child: TextFormField(
                    controller: _descriereProdusController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2E523D),
                      hintText: 'Product Description',
                      hintStyle: const TextStyle(color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter product description'
                        : null,
                  ),
                ),
                const SizedBox(height: 32),

                // Register button
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
                        onTap: _submitForm,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              'Register',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
