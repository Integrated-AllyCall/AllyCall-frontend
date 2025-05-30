import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://localhost:3000/api/'});

  // auth token from Firebase
  Future<String?> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  // request handler
  Future<dynamic> _handleRequest(
    Future<http.Response> Function(String url, Map<String, String> headers)
    method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _getAuthToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('$baseUrl$endpoint');
      final response = await method(url.toString(), headers);

      final statusCode = response.statusCode;
      final decoded = jsonDecode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        return decoded;
      } else {
        throw Exception(decoded['error'] ?? 'API Error $statusCode');
      }
    } catch (error) {
      print('API Error on $endpoint: $error');
      rethrow;
    }
  }

  // GET
  Future<dynamic> get(String endpoint) {
    return _handleRequest(
      (url, headers) => http.get(Uri.parse(url), headers: headers),
      endpoint,
    );
  }

  // POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) {
    return _handleRequest(
      (url, headers) =>
          http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      endpoint,
      body: body,
    );
  }

  // PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) {
    return _handleRequest(
      (url, headers) =>
          http.put(Uri.parse(url), headers: headers, body: jsonEncode(body)),
      endpoint,
      body: body,
    );
  }

  // DELETE
  Future<dynamic> delete(String endpoint) {
    return _handleRequest(
      (url, headers) => http.delete(Uri.parse(url), headers: headers),
      endpoint,
    );
  }

  // GET Image Binary
  Future<http.Response> getImage(String endpoint) async {
    try {
      final token = await _getAuthToken();

      final headers = {if (token != null) 'Authorization': 'Bearer $token'};

      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw Exception('Failed to load image. Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Image fetch error on $endpoint: $error');
      rethrow;
    }
  }
}
