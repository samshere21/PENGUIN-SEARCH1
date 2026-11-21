import 'package:flutter/material.dart';

class DemoEntryScreen extends StatelessWidget {
  const DemoEntryScreen({
    super.key,
    required this.onOpenDemo,
  });

  final VoidCallback onOpenDemo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.travel_explore,
                  size: 64,
                  color: Color(0xFFBD263C),
                ),
                const SizedBox(height: 24),
                Text(
                  'Penguin Search',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'A little help finding your way back to your belongings.',
                ),
                const SizedBox(height: 24),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'DEVELOPMENT DEMO\n\n'
                      'Sample data only. Changes reset when the app restarts. '
                      'University sign-in and ID verification are not connected. '
                      'Do not enter real IDs or private information.',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onOpenDemo,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Open local demo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
