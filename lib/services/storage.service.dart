import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_swd392/models/user_auth.dart';

class StorageService {
  static const String authKey = 'auth_data';

  /// Save User Authentication Data
  static Future<void> saveAuthData(UserAuth user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authKey, jsonEncode(user.toJson()));
  }

  /// Retrieve User Authentication Data
  static Future<UserAuth?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(authKey);
    if (jsonString == null) return null;
    return UserAuth.fromJson(jsonDecode(jsonString));
  }

  /// Clear Authentication Data (For Logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authKey);
  }
}
