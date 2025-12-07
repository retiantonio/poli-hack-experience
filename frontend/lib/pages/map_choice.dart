import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/pages/map.dart';

class MapChoicePage extends StatefulWidget {
  const MapChoicePage({super.key});

  @override
  State<MapChoicePage> createState() => _MapChoicePageState();
}

class _MapChoicePageState extends State<MapChoicePage> {
  final double fieldWidth = 300;

  List<String> _firstDropdownItems = [];
  final List<String> _secondDropdownItems = [
    'Artisanal',
    'Workshop',
    'Experiences',
    'Farms',
    'Gastronomy',
    'Nature',
    'Food products',
  ];

  String? _selectedFirst;
  String? _selectedSecond;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  // Păstrăm GET-ul pentru a popula lista de orașe
  Future<void> _fetchDropdownData() async {
    try {
      final response1 = await http.get(
        Uri.parse("http://172.20.10.2:8000/locations"),
      );

      if (response1.statusCode == 200) {
        final data = jsonDecode(response1.body) as List<dynamic>;
        setState(() {
          _firstDropdownItems = data
              .map((item) => item['name'].toString())
              .toList();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Oops! Could not load locations.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Oops! Something went wron! Try again later")),
      );
    }
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return SizedBox(
      width: fieldWidth,
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2E523D),
        hint: Text(hint, style: const TextStyle(color: Colors.white70)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF2E523D),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const SizedBox(
            width: 24,
            child: Icon(Icons.category, color: Colors.white70, size: 20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map(
              (tip) => DropdownMenuItem<String>(
                value: tip,
                child: Text(tip, style: const TextStyle(color: Colors.white)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: (value) => (value == null) ? 'Please select $hint' : null,
      ),
    );
  }

  // Logica nouă: Navigare directă către MapScreen
  void _navigateToMap() {
    if (_selectedFirst == null || _selectedSecond == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigăm direct la MapScreen și îi dăm orașul selectat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(selectedCity: _selectedFirst!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B2E),
        title: const Text("Map Choice"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdown(
                value: _selectedFirst,
                items: _firstDropdownItems,
                hint: 'Location',
                onChanged: (val) => setState(() => _selectedFirst = val),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedSecond,
                items: _secondDropdownItems,
                hint: 'Desired Trip',
                onChanged: (val) => setState(() => _selectedSecond = val),
              ),
              const SizedBox(height: 24),

              // Butonul care acum duce la hartă
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
                      onTap: _navigateToMap,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Start Tour',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
