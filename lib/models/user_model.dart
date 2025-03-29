import 'package:flutter_swd392/models/user_auth.dart';

class UserModel {
  final int userId;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String avatar;
  final String role;
  final String status;
  final String createdAt;
  final int membershipPackageId;
  final String uid;
  final String? token;
  final String emailActivation;

  UserModel({
    required this.userId,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    required this.avatar,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.membershipPackageId,
    required this.uid,
    this.token, // Token có thể null
    required this.emailActivation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] as String?, // Xử lý null an toàn
      fullName: json['fullName'] ?? 'N/A',
      avatar: json['avatar'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      membershipPackageId: json['membershipPackageId'] is int
          ? json['membershipPackageId']
          : int.tryParse(json['membershipPackageId'].toString()) ?? 0,
      uid: json['uid'] ?? '',
      token: json['token'], // Token có thể null
      emailActivation: json['emailActivation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'avatar': avatar,
      'role': role,
      'status': status,
      'createdAt': createdAt,
      'membershipPackageId': membershipPackageId,
      'uid': uid,
      'token': token, // Không bỏ token để tránh lỗi khi gửi lên server
      'emailActivation': emailActivation,
    };
  }

  /// Convert UserModel to UserAuth
  UserAuth toUserAuth() {
    return UserAuth(
      userId: userId,
      email: email,
      token: token ?? '', // Tránh lỗi nếu token null
      role: role,
    );
  }
}
