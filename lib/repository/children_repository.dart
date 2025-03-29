import 'dart:convert';

import 'package:flutter_swd392/api/api_service.dart';
import 'package:flutter_swd392/models/children_model.dart';
import 'package:flutter_swd392/services/storage.service.dart';

class ChildrenRepository {


  Future<ChildrenModel> addChildren(ChildrenModel children) async {
    try {
      final userAuth = await StorageService.getAuthData();
      String? token = userAuth?.token;

      if (token == null) {
        throw Exception("Token is null");
      }

      final response = await ApiService.addChild(token, children);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ChildrenModel.fromJson(responseData['data']);
      } else {
        throw Exception("Failed to add child: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error in addChildren: $e");
    }
  }
  Future<List<ChildrenModel>> getAllChildren() async {
    try {
      final userAuth = await StorageService.getAuthData();
      String? token = userAuth?.token;

      if (token == null) {
        throw Exception("Token is null");
      }

      final response = await ApiService.getAllChildren(token);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> childrenData = responseData['data'];

        return childrenData.map((child) => ChildrenModel.fromJson(child)).toList();
      } else {
        throw Exception("Failed to get children: ${response.body}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ChildrenModel> getChildById(int id) async {
    try {
      final userAuth = await StorageService.getAuthData();
      String? token = userAuth?.token;

      if (token == null) {
        throw Exception("Token is null");
      }

      final response = await ApiService.getChildById(token, id);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ChildrenModel.fromJson(responseData['data']);
      } else {
        throw Exception("Failed to get child: ${response.body}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

}