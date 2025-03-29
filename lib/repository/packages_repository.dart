import 'dart:convert';

import 'package:flutter_swd392/models/membership/mempackage_model.dart';
import 'package:flutter_swd392/models/response_data.dart';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';

class PackageRepository{
  /// Get Membership Package

  Future<ResponseData<List<MembershipPackageModel>>> getMembershipPackage() async {
    try {
      final http.Response response = await ApiService.getMembershipPackage();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);

        if (jsonMap['data'] is List) {
          final List<dynamic> responseData = jsonMap['data'];

          final List<MembershipPackageModel> packages = responseData
              .map((e) => MembershipPackageModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ResponseData<List<MembershipPackageModel>>(
            message: "Packages fetched successfully",
            status: "Successful",
            data: packages,
          );
        } else {
          return ResponseData<List<MembershipPackageModel>>(
            message: "Invalid data format",
            status: "Error",
            data: [],
          );
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return ResponseData<List<MembershipPackageModel>>(
          message: errorData['message']?.toString() ?? "Failed to get packages",
          status: errorData['status']?.toString() ?? "Error",
          data: [],
        );
      }
    } catch (e) {
      return ResponseData<List<MembershipPackageModel>>(
        message: "Error fetching packages: $e",
        status: "Error",
        data: [],
      );
    }
  }
  }




