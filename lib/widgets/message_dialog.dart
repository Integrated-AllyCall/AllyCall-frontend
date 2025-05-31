import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onContinue;

  const MessageDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: Colors.white,
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onContinue,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF6F55D3),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
