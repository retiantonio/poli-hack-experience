import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  final double rating = 4.7; // exemplu rating, poate veni din API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B2E),
        elevation: 0,
        title: const Text('User Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<String>(
          future: _getUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            String username = snapshot.data!;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 50, // mai mare
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person,
                    size: 60, // mai mare
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28, // mai mare
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 20, // mai mare
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 24, // mai mare
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
