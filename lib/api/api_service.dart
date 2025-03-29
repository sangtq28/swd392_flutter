import 'dart:convert';
import 'package:flutter_swd392/models/children_model.dart';
import 'package:flutter_swd392/services/storage.service.dart';
import 'package:http/http.dart' as http;

import '../models/vaccine_model.dart';
import '../models/vaccine_schedule_model.dart';

class ApiService {
  static const String _geminiApiKey = "AIzaSyB7q4hFO8KQTDwDbrpq2I3S7ut363jo2y0";
  static const String _apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateText?key=$_geminiApiKey";
  static const String baseUrl = 'https://swd392-backend-fptu.growplus.hungngblog.com/api';

  static Future<void> sendRequest() async {
    final String url = _apiUrl;

    final Map<String, dynamic> body = {
      "contents": [
        {
          "parts": [
            {"text": "Explain how AI works"}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body), // 🔥 Quan trọng: Encode JSON trước khi gửi
      );

      if (response.statusCode == 200) {
        print("✅ Success: ${response.body}");
      } else {
        print("⚠️ Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

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

  static Future<http.Response> updateUserProfile(String token,
      Map<String, dynamic> updatedData) async {
    final String url = '$baseUrl/Users';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
        body: jsonEncode(updatedData),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  static Future<http.Response> updatePassword(String token, String oldPassword,
      String newPassword) async {
    final String url = '$baseUrl/Users/change-password';

    print('🔹 Sending API Request...');
    print('🔹 oldPassword: $oldPassword');
    print('🔹 newPassword: $newPassword');
    print('🔹 token: $token');

    final Map<String, dynamic> body = {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token, // Fix Authorization format
        },
        body: jsonEncode(body), // Ensure body is encoded correctly
      );

      print('🔹 API Response: ${response.statusCode}');
      print('🔹 Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception("Failed to update password: $e");
    }
  }

  static Future<http.Response> forgotPassword(String email) async {
    final String url = '$baseUrl/Users/forgot-password';
    final Map<String, dynamic> body = {
      "email": email,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to send email: $e");
    }
  }

  static Future<http.Response> getCurrentPackage(String token) async {
    final String url = '$baseUrl/UserMemberships/CurrentPackage';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": token,
      }, // <- Thiếu dấu đóng `}`
    );

    return response;
  }

  static Future<http.Response> addChild(String token,
      ChildrenModel child) async {
    final url = Uri.parse("$baseUrl/Children/add");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
        body: jsonEncode(child.toJson()),
      );

      return response;
    } catch (e) {
      print("Error adding child: $e");
      return http.Response(
          jsonEncode({"error": "Error adding child: $e"}), 500);
    }
  }

  static Future<http.Response> getAllChildren(String token) async {
    final url = Uri.parse("$baseUrl/Children?pageNumber=1&pageSize=999");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token,
        },
      );

      if (response.statusCode == 200) {
        print("Get all children success!");
      } else {
        print("Failed to get children: ${response.body}");
      }

      return response;
    } catch (e) {
      print("Error getting children: $e");
      return http.Response("Error getting children: $e", 500);
    }
  }
  static Future<http.Response> upgradeMembershipPackage(String token, int packageId, String paymentType) async {
    final url = Uri.parse("$baseUrl/BuyMembershipPackage/BuyMembershipPackage");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
        body: jsonEncode(
          {
            "idPackage": packageId,
            "paymentType": paymentType,
          },
        ),
      );

      return response;
    } catch (e) {
      print("Error upgrading package: $e");
      return http.Response(
          jsonEncode({"error": "Error upgrading package: $e"}), 500);
    }
  }

  static Future<http.Response> getChildById(String token, int id) async {
    final url = Uri.parse("$baseUrl/Children/child/$id");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
        },
      );

      if (response.statusCode == 200) {
        print("Get child success!");
      } else {
        print("Failed to get child: ${response.body}");
      }

      return response;
    } catch (e) {
      print("Error getting child: $e");
      return http.Response("Error getting child: $e", 500);
    }
  }
  static Future<List<VaccineModel>> getVaccines() async {
    final response = await http.get(Uri.parse("$baseUrl/Vaccines"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => VaccineModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load vaccines");
    }
  }

  static Future<VaccineScheduleModel?> getVaccinationSchedule(int vaccineId) async {
    print("Getting vaccine schedule for vaccine ID: $vaccineId");
    final userAuth = await StorageService.getAuthData();
    String? token = userAuth?.token;
    if (token == null) {
      throw Exception("Token is null");
    }
    final response = await http.get(Uri.parse("$baseUrl/VaccinationSchedules/$vaccineId",),
        headers: {"Content-Type": "application/json", "Authorization" : token});

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == "successful") {
        var data = jsonResponse['data']; // Không ép kiểu List<dynamic> ngay

        if (data is Map<String, dynamic>) {
          return VaccineScheduleModel.fromJson(data); // Trả về đối tượng duy nhất
        } else {
          throw Exception("Unexpected data format: expected Map<String, dynamic> but got ${data.runtimeType}");
        }
      } else {
        throw Exception("API returned unsuccessful status: ${jsonResponse['message']}");
      }
    } else {
      throw Exception("Failed to load vaccination schedules: ${response.statusCode}");
    }
  }



  static Future<List<ChildrenModel>> getChildren() async {
    final userAuth = await StorageService.getAuthData();
    String? token = userAuth?.token;
    if (token == null) {
      throw Exception("Token is null");
    }
    final response = await http.get(Uri.parse("$baseUrl/Children"),
        headers: {"Content-Type": "application/json", "Authorization" : token});
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Check if the status is successful
      if (jsonResponse['status'] == "successful") {
        // Extract the data array
        List<dynamic> data = jsonResponse['data'];
        return data.map((json) => ChildrenModel.fromJson(json)).toList();
      } else {
        throw Exception("API returned unsuccessful status: ${jsonResponse['message']}");
      }
    } else {
      throw Exception("Failed to load children: ${response.statusCode}");
    }
  }

  static Future<bool> createVaccineRecord(int childId, int vaccineId, String administeredDate, int dose) async {
    final response = await http.post(
      Uri.parse("$baseUrl/VaccineRecords"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "childId": childId,
        "vaccineId": vaccineId,
        "administeredDate": administeredDate,
        "dose": dose,
      }),
    );
    return response.statusCode == 201;
  }

}


