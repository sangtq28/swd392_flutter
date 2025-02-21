import 'dart:convert';

import 'package:flutter_swd392/api/api_service.dart';
import 'package:http/http.dart' as http;


class UserRepository{
  /// User Login method
  Future<String?> userLogin(String email, String password) async {
    final response = await ApiService.userLogin(email, password);
    if(response.statusCode == 200 || response.statusCode == 201){
      return null;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return errorData['message'] ?? "Login failed";
    }
  }
  /// User Register method
  Future<String?> userSignUp(String email, String password) async {
    final response  = await ApiService.register(email, password);
    if(response.statusCode == 200 || response.statusCode == 201){
      return null;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return errorData['message'] ?? "Registration failed";
    }
  }

}