import 'dart:convert';                       // For jsonEncode, jsonDecode
import 'package:http/http.dart' as http;     // For http and Response
import '../config/app_config.dart';

class ApiService {
  final String baseUrl = AppConfig.supabaseUrl;
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'apikey': AppConfig.supabaseAnonKey,
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('❌ API Error [${response.statusCode}]: ${response.body}');
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
