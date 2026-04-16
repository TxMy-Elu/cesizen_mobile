import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(content, style: const TextStyle(height: 1.4)),
          ),
        ),
      ),
    );
  }
}
