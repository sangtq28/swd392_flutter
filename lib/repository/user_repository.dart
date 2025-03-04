import 'dart:convert';

import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/models/response_data.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:http/http.dart' as http;


class UserRepository{
  UserModel? _userModel;
  /// User Login method
  Future<ResponseData<UserModel>> userLogin(String email, String password) async {
    //1. Call the API
    final http.Response response = await ApiService.userLogin(email, password);
    //3. Check if the response is successful
    if(response.statusCode == 200 || response.statusCode == 201){
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
    final response  = await ApiService.register(email, password);
    if(response.statusCode == 200 || response.statusCode == 201){
      return null;
    } else {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      return errorData['message'] ?? "Registration failed";
    }
  }

}