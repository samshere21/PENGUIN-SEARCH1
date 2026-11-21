import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Messages',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Conversations about lost and found items.',
        ),
        const SizedBox(height: 24),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Messaging is not connected yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Contact will start from an item report. '
                  'The recipient can accept or decline the message request. '
                  'Once accepted, you can discuss the item privately.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}