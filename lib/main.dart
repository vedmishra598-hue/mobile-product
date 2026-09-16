import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/details_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive Mobile UI',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      initialRoute: '/',

      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => HomeScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: toggleTheme,
            ),
        '/profile': (context) => ProfileScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: toggleTheme,
            ),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final item = settings.arguments as String;

          return PageRouteBuilder(
            pageBuilder: (_, animation, __) {
              return DetailsScreen(itemName: item);
            },
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }

        return null;
      },
    );
  }
}