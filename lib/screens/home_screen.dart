import 'package:flutter/material.dart';

import '../widgets/item_card.dart';

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Feed'),

        actions: [
          IconButton(
            onPressed: onThemeChanged,
            icon: Icon(
              isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),

              child: GridView.count(
                padding: const EdgeInsets.all(16),

                crossAxisCount:
                    isLargeScreen ? 2 : 1,

                crossAxisSpacing: 16,
                mainAxisSpacing: 16,

                childAspectRatio: 3,

                children: [
                  ItemCard(
                    title: 'Mountain',
                    subtitle: 'Beautiful mountain view',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: 'Mountain',
                      );
                    },
                  ),

                  ItemCard(
                    title: 'Ocean',
                    subtitle: 'Relaxing ocean view',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: 'Ocean',
                      );
                    },
                  ),

                  ItemCard(
                    title: 'Forest',
                    subtitle: 'Green forest experience',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: 'Forest',
                      );
                    },
                  ),

                  ItemCard(
                    title: 'Desert',
                    subtitle: 'Amazing desert landscape',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: 'Desert',
                      );
                    },
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