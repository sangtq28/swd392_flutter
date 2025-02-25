import 'dart:convert';

import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/models/response_data.dart';
import 'package:flutter_swd392/models/user_model.dart';
import 'package:http/http.dart' as http;


class UserRepository{
  UserModel? _userModel;
  ResponseData<UserModel>? _responseData;
  /// User Login method
  Future<ResponseData<UserModel>> userLogin(String email, String password) async {
    //1. Call the API
    final http.Response response = await ApiService.userLogin(email, password);
    //2. Parse the response
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    //3. Check if the response is successful
    if(response.statusCode == 200 || response.statusCode == 201){
     //3.1 Parse the 'data' field into Model (depends on the API response)

      );
    } else {

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