import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar & User Details
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user != null && user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : null,
                  child: user == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user != null ? user.name : 'Guest User',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user != null ? user.email : 'Not signed in',
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Preferences Section
          Text(
            'App Preferences',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                  title: const Text('Dark Theme'),
                  subtitle: const Text('Saved locally in preferences'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security & Storage State
          Text(
            'Offline Storage & Tokens',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: const Text('Auth Token'),
                  subtitle: Text(
                    user != null
                        ? '${user.token.substring(0, user.token.length > 25 ? 25 : user.token.length)}...'
                        : 'No token stored',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Offline Database (Hive)'),
                  subtitle: const Text('Cached products, cart, & favorites stored locally'),
                  trailing: TextButton(
                    onPressed: () async {
                      final cached = StorageService.getCachedProducts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hive contains ${cached.length} cached products.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Inspect'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Auth Action Button
          if (auth.isAuthenticated)
            FilledButton.tonalIcon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signed out successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          else
            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In / Demo Login'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
        ],
      ),
    );
  }
}