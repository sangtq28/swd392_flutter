import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
class ApiService {
  static const String baseUrl = 'https://swd39220250217220816.azurewebsites.net/api/';

  /// Login API
  static Future<http.Response> userLogin(String email, String password) async
  {
    final String url = '$baseUrl/Users/login';
    final Map<String, String> body = {
      "email": email,
      "password": password
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Register API
  static Future<http.Response> register(String email, String password) async {
    final String url = '$baseUrl/Users/register';
    final Map<String, String> body = {
      "email": email,
      "password": password,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return response;
  }

  ///Get Membership Package
  static Future<http.Response> getMembershipPackage() async {
    final String url = '$baseUrl/MembershipPackages/PricingPlan';
    final response = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    // print(response.body);
    return response;
  }
  static Future<http.Response> getUserProfile(String token) async {
    final String url = '$baseUrl/Users/self';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Lỗi kết nối đến server');
    }
  }

}

