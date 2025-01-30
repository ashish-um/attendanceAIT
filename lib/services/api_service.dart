import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String baseUrl = "https://attendence-backend-zeta.vercel.app";

  Future<void> saveToken(String token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "jwt_token");
  }

  Future<void> registerTeacher(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data["token"]);
    } else {
      throw Exception(data["message"]);
    }
  }

  Future<void> loginTeacher(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      // Log the response status and body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if the response is a successful one (200 OK)
      if (response.statusCode == 200) {
        // Decode the response body
        final data = json.decode(response.body);

        // Extract the token from the response and save it securely
        await saveToken(data["token"]);

        print("Login successful. Token: ${data["token"]}");
      } else {
        // If the response is not successful, throw an exception
        final data = json.decode(response.body);
        throw Exception(data["message"] ?? 'Unknown error occurred');
      }
    } catch (e) {
      // Handle any errors that occur during the request or response parsing
      print('Error during login: $e');
      throw Exception("Failed to login: $e");
    }
  }
  
  Future<List<dynamic>> getClasses() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/classes"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = json.decode(response.body);
    return data;
  }

  Future<void> createClass(String className, List<Map<String, String>> students) async {
    final token = await getToken();
    await http.post(
      Uri.parse("$baseUrl/classes"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: json.encode({
        "className": className,
        "students": students,
      }),
    );
  }

  Future<void> markAttendance(String classId, List<String> absentRollNumbers) async {
    final token = await getToken();
    await http.post(
      Uri.parse("$baseUrl/attendance"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: json.encode({
        "classId": classId,
        "absentRollNumbers": absentRollNumbers,
      }),
    );
  }

  Future<List<dynamic>> getAttendance(String classId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/attendance/$classId"),
      headers: {"Authorization": "Bearer $token"},
    );
    final data = json.decode(response.body);
    return data;
  }
}
