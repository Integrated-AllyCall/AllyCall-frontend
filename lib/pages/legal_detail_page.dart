import 'package:flutter/material.dart';
import 'dart:convert';

class LegalDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String countryName;

  const LegalDetailPage({super.key, required this.data, required this.countryName});

  @override
  Widget build(BuildContext context) {
    // Tokenize string or decode if it's an encoded array
    List<String> decodeList(dynamic input) {
      if (input is List) return input.map((e) => e.toString().trim()).toList();
      if (input is String && input.trim().startsWith('[')) {
        try {
          final parsed = jsonDecode(input);
          if (parsed is List) return parsed.map((e) => e.toString().trim()).toList();
        } catch (_) {}
      }
      return input
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final List<String> protects = decodeList(data['protects'] ?? '');
    final List<String> actions = decodeList(data['do_what'] ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F55D3),
        elevation: 0,
        title: const Text(''),
        leading: const BackButton(color: Colors.white),
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
          ),
        ),  
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Country Name
            Text(
              countryName,
              style: const TextStyle(
                color: Color(0xFF6F55D3),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              data['title'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 4),

            // Act Label
            if ((data['act'] ?? '').toString().isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Act: ${data['act']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Description
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 24),

            // Who It Protects
            const Text(
              "Who It Protects",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (protects.isEmpty)
              const Text("– No information available"),
            ...protects.map((p) => Text("• $p")),

            const SizedBox(height: 24),

            // What You Can Do
            const Text(
              "What You Can Do",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (actions.isEmpty)
              const Text("– No suggestions provided"),
            ...actions.map((a) => Text("• $a")),

            const SizedBox(height: 24),

            // Emergency Contacts
            const Text(
              "Emergency Contacts",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text("• 191 – Police"),
            const Text("• 1300 – Women/Children Help"),
            const Text("• 1669 – Medical Emergency"),
            const Text("• 1323 – Mental Health"),
            const Text("• 1155 – Tourist Police"),
          ],
        ),
      ),
    );
  }
}
