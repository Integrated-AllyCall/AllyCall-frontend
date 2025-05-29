import 'package:flutter/material.dart';
import 'package:allycall/services/api_service.dart';
import 'package:allycall/widgets/legal_card.dart';
import 'legal_detail_page.dart'; 

final api = ApiService();

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  List<Map<String, dynamic>> countries = [];
  List<Map<String, dynamic>> legalRights = [];
  String selectedCode = 'TH';

  @override
  void initState() {
    super.initState();
    fetchCountries();
    fetchLegalRights();
  }

  Future<void> fetchCountries() async {
    final response = await api.get('countries/with-legal');
    setState(() {
      countries = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fetchLegalRights() async {
    final response = await api.get('legals');
    final country = response.firstWhere(
      (c) => c['code'] == selectedCode,
      orElse: () => {'country_legals': []},
    );
    setState(() {
      legalRights = List<Map<String, dynamic>>.from(country['country_legals'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchedCountry = countries.firstWhere(
      (c) => c['code'] == selectedCode,
      orElse: () => {'name': selectedCode},
    );
    final countryName = matchedCountry['name'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F55D3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Know Your Rights',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),  
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF6F55D3), size: 18),
                const SizedBox(width: 8),
                const Text("Location", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedCode,
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(8),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCode = value;
                      });
                      fetchLegalRights();
                    }
                  },
                  items: countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Text(country['name']),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: legalRights.length,
                itemBuilder: (context, index) {
                  final item = legalRights[index];
                  return LegalCard(
                    countryName: countryName,
                    title: item['title'] ?? '',
                    description: item['description'] ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalDetailPage(data: item, countryName: countryName),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
