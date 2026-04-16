import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/widgets/cesizen_cards.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionCard(
            icon: Icons.warning_rounded,
            title: 'Urgence',
            content: '15 / 112 / 3114',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Votre email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _messageController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: 'Votre message'),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message envoye (simulation locale).')),
                      );
                    },
                    child: const Text('Envoyer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
