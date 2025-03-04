import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_swd392/models/user_auth.dart';

class StorageService {
  static const String authKey = 'auth_data';

  /// Save User Authentication Data
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('🔑 Token đã lưu vào Storage: $token'); // Debug
  }


  /// Retrieve User Authentication Data
  static Future<UserAuth?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // ✅ Lấy token thẳng, không decode JSON

    if (token == null) return null;

    print('🟢 Token từ Storage: $token');

    return UserAuth(token: token);
  }

  /// Clear Authentication Data (For Logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authKey);
  }
}
