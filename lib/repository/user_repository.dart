import 'dart:convert';

import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/models/membership/membership_subscript.dart';
import 'package:flutter_swd392/models/response_data.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:http/http.dart' as http;

import '../models/user_profile.dart';
import '../services/storage.service.dart';


class UserRepository {
  UserModel? _userModel;

  /// User Login method
  Future<ResponseData<UserModel>> userLogin(String email,
      String password) async {
    //1. Call the API
    final http.Response response = await ApiService.userLogin(email, password);
    //3. Check if the response is successful
    if (response.statusCode == 200 || response.statusCode == 201) {
      //3.2 Parse the response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      //3.3 Parse the 'data' field into Model (depends on the API response)
      final user = UserModel.fromJson(responseData['data']);
      //Return a successful ResponseData<UserModel>
      return ResponseData<UserModel>.fromJson(
          responseData,
              (data) => UserModel.fromJson(data as Map<String, dynamic>)
      );
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return ResponseData<UserModel>(
        message: errorData['message'] ?? "Login failed",
        status: errorData['status'],
        data: null,
      );
    }
  }

  /// User Register method
  Future<String?> userSignUp(String email, String password) async {
    final response = await ApiService.register(email, password);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return null;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return errorData['message'] ?? "Registration failed";
    }
  }

  /// Get User Profile
  // static Future<ResponseData<UserModel>> getUserProfile(String token) async {
  //   try {
  //     print('UserRepository: getUserProfile token: $token');
  //     final response = await ApiService.getUserProfile(token);
  //     print('UserRepository: getUserProfile response: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //       print('statuscode == 200 $jsonResponse');
  //       return ResponseData<UserModel>.fromJson(jsonResponse,
  //               (data) => UserModel.fromJson(data as Map<String, dynamic>)
  //       );
  //     } else {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //       return ResponseData<UserModel>(
  //         status: "error",
  //         message: jsonResponse["message"] ?? "Failed to fetch user",
  //       );
  //     }
  //   } catch (e) {
  //     return ResponseData<UserModel>(
  //       status: "error",
  //       message: "Exception: $e",
  //     );
  //   }
  Future<UserProfile?> getUserProfile() async {
    final userAuth = await StorageService.getAuthData();
    String? token = userAuth?.token; // ❌ Không cần await nữa

    if (token == null) return null;

    final response = await ApiService.getUserProfile(token);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["status"] == "successful") {
        return UserProfile.fromJson(responseData["data"]);
      }
    }
    return null;
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    final userAuth = await StorageService.getAuthData();
    String? token = userAuth?.token;
    if (token == null) return false;

    final response = await ApiService.updateUserProfile(token, updatedData);

    return response.statusCode == 200;
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    final userAuth = await StorageService.getAuthData();
    String? token = userAuth?.token;
    if (token == null) return false;

    final response = await ApiService.updatePassword(
        token, oldPassword, newPassword);
    print('UserRepository: updatePassword response: ${response.body}');

    return response.statusCode == 200;
  }

  Future<void> forgotPassword(String email) async {
    final response = await ApiService.forgotPassword(email);
    print('UserRepository: forgotPassword response: ${response.body}');
  }

  Future<MembershipSubscriptionModel?> getCurrentPackage() async {
    try {
      // Lấy token từ StorageService
      final userAuth = await StorageService.getAuthData();
      String? token = userAuth?.token;

      if (token == null) {
        print('UserRepository: No token found');
        return null;
      }
      print('UserRepository: getCurrentPackage token: $token');

      // Gọi API để lấy gói hiện tại
      final response = await ApiService.getCurrentPackage(token);
      print('UserRepository: getCurrentPackage response: ${response.body}');

      // Kiểm tra status code
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          // Kiểm tra xem responseData có chứa key hợp lệ không
          if (responseData is Map<String, dynamic> && responseData.containsKey('membershipPackage')) {
            return MembershipSubscriptionModel.fromJson(responseData);
          } else {
            print("UserRepository: Invalid response format");
            return null;
          }
        } catch (e) {
          print("UserRepository: JSON decoding error: $e");
          return null;
        }
      } else {
        print("UserRepository: API error - Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("UserRepository: Unexpected error: $e");
      return null;
    }
  }


}

