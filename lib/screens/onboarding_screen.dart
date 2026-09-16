import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: width < 400 ? 90 : 130,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: width < 400 ? 30 : 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Responsive Mobile UI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width < 400 ? 16 : 20,
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/home',
                          );
                        },
                        child: const Text('Get Started'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}