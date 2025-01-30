import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? _token;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadToken(); // Load token when the provider is initialized
  }

  Future<void> _loadToken() async {
    _token = await _secureStorage.read(key: 'auth_token');
    print("🔹 Token loaded during initialization: $_token");
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse('https://attendence-backend-zeta.vercel.app/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];

        await _secureStorage.write(key: 'auth_token', value: _token);
        print("🔹 Token saved successfully: $_token");

        notifyListeners();
      } else {
        throw Exception("Login failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error during login: $e");
      throw Exception("Error during login: $e");
    }
  }

  Future<String?> getToken() async {
    // Ensure token is always up-to-date (optional safety check)
    _token ??= await _secureStorage.read(key: 'auth_token');
    return _token;
  }

  Future<void> logout() async {
    _token = null;
    await _secureStorage.delete(key: 'auth_token');
    notifyListeners();
  }
}