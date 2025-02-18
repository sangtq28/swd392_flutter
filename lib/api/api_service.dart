import 'dart:convert';
import 'package:http/http.dart' as http;
class ApiService {
  static const String baseUrl = 'https://swd39220250217220816.azurewebsites.net/api/';
  /// Register API
  static Future<bool> register(String email, String password) async {
    final String url = '$baseUrl/Users/register';
    final Map<String, String> body = {
      "email": email,
      "password": password,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? "Registration failed";
      }
    } catch (e) {
      return false;
    }
  }
}
