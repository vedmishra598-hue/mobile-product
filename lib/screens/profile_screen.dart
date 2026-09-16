import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final large = constraints.maxWidth > 600;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              large ? 40 : 20,
            ),

            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: large ? 70 : 50,
                    child: Icon(
                      Icons.person,
                      size: large ? 70 : 50,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'User Profile',
                    style: TextStyle(
                      fontSize: large ? 30 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle:
                          const Text('user@example.com'),
                    ),
                  ),

                  Card(
                    child: SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: isDarkMode,
                      onChanged: (_) {
                        onThemeChanged();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}