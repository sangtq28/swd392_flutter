
class UserProfile {
  final int userId;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String avatar;
  final String role;
  final String status;
  final DateTime createdAt;
  final int membershipPackageId;
  final String uid;
  final String emailActivation;
  final String? address;
  final String? zipcode;
  final String? state;
  final String? country;

  UserProfile({
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
    required this.emailActivation,
    this.address,
    this.zipcode,
    this.state,
    this.country,
  });

  // Chuyển từ JSON sang Object
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json["userId"],
      email: json["email"],
      phoneNumber: json["phoneNumber"],
      fullName: json["fullName"],
      avatar: json["avatar"] ?? "",
      role: json["role"],
      status: json["status"],
      createdAt: DateTime.parse(json["createdAt"]),
      membershipPackageId: json["membershipPackageId"],
      uid: json["uid"],
      emailActivation: json["emailActivation"],
      address: json["address"],
      zipcode: json["zipcode"],
      state: json["state"],
      country: json["country"],
    );
  }

  // Chuyển từ Object sang JSON
  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "email": email,
      "phoneNumber": phoneNumber,
      "fullName": fullName,
      "avatar": avatar,
      "role": role,
      "status": status,
      "createdAt": createdAt.toIso8601String(),
      "membershipPackageId": membershipPackageId,
      "uid": uid,
      "emailActivation": emailActivation,
      "address": address,
      "zipcode": zipcode,
      "state": state,
      "country": country,
    };
  }
}
