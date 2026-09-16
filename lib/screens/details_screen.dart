import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final String itemName;

  const DetailsScreen({
    super.key,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 500,
                    ),

                    width: constraints.maxWidth > 600
                        ? 250
                        : 180,

                    height: constraints.maxWidth > 600
                        ? 250
                        : 180,

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(30),

                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                    ),

                    child: const Icon(
                      Icons.image,
                      size: 80,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'This is the detailed information '
                    'screen for the selected item.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    icon: const Icon(Icons.arrow_back),

                    label: const Text('Back'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}